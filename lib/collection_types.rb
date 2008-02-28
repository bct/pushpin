# this module contains methods for customizing an Atom::Entry for different
# types of collections based on form input parameters
module EntryConstructor
  module_function

  # a microformatted review of something
  def hreview entry, params
    review = <<END
<div class="hreview">
  <div class="item">
END

    review << if params['item']['url'].empty?
                "<span class='fn'>" + CGI.escapeHTML(params['title']) + "</span>"
              else
                "<a class='url fn' href='" +
                    CGI.escapeHTML(params['item']['url']) + "'>" +
                    CGI.escapeHTML(params['title'])       + "</a>"
              end

    unless params['rating'].empty?
      # 'rating' filled stars out of 5 hollow ones
      rating = params['rating'].to_i
      stars = ('★' * rating) + ('☆' * (5 - rating))

      review << "<div>Rating: <abbr class='rating' title='#{rating}'>#{stars}</abbr></div>"
    end

    if entry.content
      review << "<div class='description'>#{entry.content.html}</div>"
    end

    review <<<<END
  </div>
</div>
END

    entry.content = review
    entry.content['type'] = 'html'
  end
end
