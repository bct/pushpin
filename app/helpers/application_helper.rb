require "enumerator" # for each_slice

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Sanitize

  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options), block.binding)
  end

  # a <textarea> for atom:summary
  def _summary_editor(content)
    return %{<div class="content><label for="entry[summary]">Summary:</label><textarea name="summary" id="summary" cols="56" rows="16">#{CGI.escapeHTML(content)}</textarea></div>}
  end

  # a <textarea> for atom:content
  def _content_editor(content)
    return %{<div class="content">
  <label for="content">Content:</label>
  <textarea name="entry[content]" id="content" cols="56" rows="16">#{CGI.escapeHTML(content)}</textarea>
</div>}
  end

  # converts existing content to markdown
  #   XXX maybe we should depend on the server for this?
  def _markdown_content(entry)
    markdown = entry.content ? html_to_markdown(entry.content.html) : ''

    return _content_editor(markdown) + %{<p class="info">you can use <a href="http://daringfireball.net/projects/markdown/syntax">Markdown</a> syntax here.</p>
<input type="hidden" name="entry[content_type]" value="markdown" />}
  end

  # input to this MUST be UTF-8
  def html_to_markdown(html)
    p = IO.popen("python ./vendor/html2text.py", "w+")
    p.puts html
    p.close_write
    p.read
  end

  def hash_to_hidden_inputs(hash)
    ret = ""
    hash._inputize.each_slice(2) do |k,v|
      ret += %{<input name="#{h k}" value="#{h v}" type='hidden' />\n}
    end
    ret
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
