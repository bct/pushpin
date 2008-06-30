require_dependency "openid_login_system"

require 'lib/collection_types'

class NeedAuthSub < RuntimeError; end

class RemoteFailure < RuntimeError
  attr_reader :res

  def initialize(res, *args)
    @res = res

    super *args
  end
end

class ApplicationController < ActionController::Base
  include OpenidLoginSystem

  before_filter :find_user

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_pushpin2_session_id'

  layout "base"

  # get the logged in user object
  def find_user
    @user = if session[:user_id].nil?
              nil
            else
              User.find(session[:user_id])
            end

    true
  end

  # finds a collection and prepares it for HTTP stuff
  def find_coll(url)
    c = Collection.find_or_initialize_by_url_and_user_id(url, @user)
    c.http = new_atom_http
    c
  end

  def obtain_authorization method, continue_params = {}
    @title = 'you need to authenticate.'
    @failed = params[:user]

    @continue_path ||= ''
    @continue_method = method
    @continue_params = continue_params
    render :template => 'static/authorization'
  end

  # normalize a user-entered URL
  def n_url url
    url.strip!

    # if we don't see ':/' in the first 10 characters of the URL,
    #  prefix it with http://
    url = "http://" + url unless url.match(/^.{1,9}:\//)
    url
  end

  # entry: a complete Atom Entry
  # original: an Atom Entry that other parameters are filled into
  # title
  # tags: space separated categories
  # summary
  # content
  # summary_type, content_type:
  #   - text
  #   - html
  #   - xhtml
  #   - markdown
  # author:
  #   name
  #   uri
  #   email
  # links:
  #   rel
  #   href
  # extra: name of a method to be called on EntryConstructor
  def make_entry(params)
    unless params
      return Atom::Entry.new
    end

    if params[:complete]
      return Atom::Entry.parse(params[:complete])
    end

    entry = if params[:original]
              Atom::Entry.parse(params[:original], params[:base_url])
            else
              Atom::Entry.new
            end

    entry.id = "urn:uuid:#{UUID.create}" unless entry.id

    entry.title = params[:title]

    if params[:tags] and not params[:tags].empty?
      entry.categories.clear
      entry.tag_with params[:tags]
    end

    if params[:draft] and not params[:draft].empty?
      entry.draft = true
    elsif params[:publish] and not params[:publish].empty?
      entry.draft = false
    end

    if author = params[:author]
      a_auth = entry.authors.new
      a_auth.name = author[:name] if author[:name]
      a_auth.email = author[:email] if author[:email]

      if uri = author[:uri]
        a_auth.uri = n_url uri
      end
    end

    if links = params[:links]
      links.each do |l|
        a_link = entry.links.new
        a_link['href'] = n_url l[:href]
        a_link['rel'] = l[:rel] if l[:rel]
      end
    end

    [:content, :summary].each do |sym|
      if ptext = params[sym]
        ptype = params[(sym.to_s + '_type').to_sym]

        case ptype
        when 'text', 'html', 'xhtml'
          text = ptext
          text = PushPin::HTML::xmlize_entities(ptext) if ptype == 'xhtml'
        when 'markdown'
          text = BlueCloth.new(ptext.to_s).to_html
          type = 'html'
        else
          raise "don't know text construct type #{ptype.inspect}"
        end

        entry.send(sym.to_s + '=', text)
        entry.send(sym)['type'] = (type or ptype)
      end
    end

    # extension mechanism
    if EntryConstructor.singleton_methods.member? params['extra']
      EntryConstructor.send params['extra'].to_sym, entry, params
    end

    entry
  end

  # return an Atom::HTTP object for controllers to use
  # despite this method's name, it will return the same object if called twice
  def new_atom_http
    @http ||= PushpinHTTP.new(@user, params)
  end

  # creates a URL for the user to be redirected to for AuthSub
  def authsub_url(ps = {})
    spp = request.symbolized_path_parameters
    c = spp[:controller]
    a = spp[:action]
    dr = DelayedRequest.create(:method => request.method.to_s,
                               :controller => c,
                               :action => a,
                               :params => ps)

    next_url = url_for :controller => :authsub, :action => :show, :id => dr.id
    scope = "http://partners-test.blogger.com/feeds/"

    "https://www.google.com/accounts/AuthSubRequest?next=#{CGI.escape next_url}&scope=#{CGI.escape scope}&session=1"
  end

  # wraps a request that might need to go back to the user for authorization
  def maybe_needs_authorization ps
    begin
      yield
    rescue Atom::Unauthorized
      if ps['deferred_media']
        ps['deferred_media'] = write_deferred_media(ps['deferred_media'])
      end
      @last_url = @http.last_url
      obtain_authorization(request.method, ps)
    rescue NeedAuthSub
      if ps['deferred_media']
        ps['deferred_media'] = write_deferred_media(ps['deferred_media'])
      end
      redirect_to authsub_url(ps)
    rescue Errno::ECONNREFUSED
      @last_url = @http.last_url
      render :template => 'static/conn-refused'
    end
  end

  # temporarily saves a media file so a request can be tried again later
  # returns a token that can be used to retrieve the file
  def write_deferred_media media
    begin
      token = rand(2 ** 32).to_s(36)
      filename = './db/deferred/' + token
    end while File.exists?(filename)

    File.open(filename, 'w') { |f| f.write media }

    token
  end

  # returns the contents. deletes the temporary file.
  def read_deferred_media token
    filename = './db/deferred/' + token

    media = File.read(filename)
    File.delete filename

    media
  end
end

class PushpinHTTP < Atom::HTTP
  # the last URL we made a request to
  attr_reader :last_url

  # how long the last request took
  attr_reader :took

  def initialize(user, params)
    super $http_cache_dir

    @user = user

    if params[:token]
      @token = params[:token]
    end

    self.when_auth do |abs_url, realm|
      if @user
        auth = @user.auth_for(abs_url, realm)
      end

      if params[:user] and params[:pass]
        if @user and params[:store_auth] == 'yes'
          auth ||= HTTPAuth.new

          auth.user_id = @user.id
          auth.abs_url = abs_url
          auth.realm = realm
          auth.username = params[:user]
          auth.password = params[:pass]
          auth.save
        end

        [ params[:user], params[:pass] ]
      elsif auth
        [ auth.username, auth.password ]
      else
        nil
      end
    end
  end

  def authsub_authenticate(req, url, params = {})
    if @user and not @token
      @token = AuthsubToken.find_by_user_id(@user.id).token
    end

    raise NeedAuthSub unless @token

    req['Authorization'] = %{AuthSub token="#{@token}"}
  end

  def http_request(url_s, *args)
    began = Time.now

    @last_url = url_s

    r = super

    @took = Time.now - began

    r
  end
end
