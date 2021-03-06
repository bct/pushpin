require "enumerator" # for each_slice

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Sanitize

  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options), block.binding)
  end

  def _text_editor(name, html)
    editor =  if @user
                @user.editor
              else
                'basic_markdown'
              end

    render :partial => "text/#{editor}", :locals => { :name => name, :html => html }
  end

  # input to this MUST be UTF-8
  def html_to_markdown(html)
    IO.popen("python ./vendor/html2text.py", "w+") do |p|
      p.puts html
      p.close_write
      p.read
    end
  end

  def hash_to_hidden_inputs(hash)
    ret = ""
    hash._inputize.each_slice(2) do |k,v|
      ret += %{<input name="#{h k}" value="#{h v}" type='hidden' />\n}
    end
    ret
  end

  def _display_remote_response(response)
    if response.content_type and response.content_type.match /html/
      sanitize_html(response.body.to_s)
    else
      '<pre>' + h(response.body.to_s) + '</pre>'
    end
  end

  def _url url
    '<span class="url">' + h(url) + '</span>'
  end

  INPUT_TYPES = {
              :slug => ['Slug', 'url_in', "a short name for your entry for the server to put in the URL it generates"],

             }

  def _infoed_input name, default = ''
    short, klass, explanation = INPUT_TYPES[name]
    return <<END
<label class='#{klass} infoed' 
      title='#{explanation}'>#{short}:
<input name='#{name}' value='#{ h(default) }'></label>
END
  end
end

class Hash
  # {'a' => {'b' => 'c', 'd' => 'e'}} =>
  #   [ "a[b]", "c", "a[d]", "e" ]
  def _inputize(namespace = nil)
    collect do |key, value|
      key = namespace ? "#{namespace}[#{key}]" : key
      if value.is_a? Hash
        value._inputize(key)
      else
        [key, value]
      end
    end.flatten
  end
end
