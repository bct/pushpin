class Collection < ActiveRecord::Base
  belongs_to :user

  def title
    (super or get_atom.title or self.url)
  end

  validates_uniqueness_of :url, :on => :create, :scope => [ :user_id ]

  # #http= must be set to use any of the HTTP stuff
  attr_accessor :http

  def next_feed_url
    if @atom.feed.prev
      @atom.feed.prev.uri
    end
  end

  def get_atom url = self.url
    @atom ||= Atom::Collection.new url, @http
  end

  def update! feed_url
    feed_url ||= self.url

    get_atom feed_url

    @atom.feed.update!

    unless new_record? or not @atom.title or (@atom.title.html == self.title)
      self.title = @atom.title.html
      self.save
    end
  end

  def post! *args
    get_atom

    res = @atom.post! *args

    unless res.code == '201'
      raise RemoteFailure.new(res, 'expected 201 in response to POST')
    end

    res
  end

  def post_media! *args
    get_atom

    mres = @atom.post_media! *args

    unless mres.code == '201'
      raise RemoteFailure.new(mres, 'expected 201 in response to POST')
    end

    entry = if mres['Content-Type'] and mres['Content-Type'].match /atom\+xml/
              yield mres.body
            else
              yield nil
            end

    ares = @http.put mres['Location'], entry.to_s

    unless ares.code == '200'
      raise RemoteFailure.new(mres, 'expected 200 in response to PUT')
    end

    ares
  end

  include Enumerable

  def each &block
    @atom.feed.each &block
  end

  def empty?
    @atom.feed.empty?
  end

  def self.kinds
    ['basic entry', 'link', 'comment', 'media']
  end
end
