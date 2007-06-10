class Collection < ActiveRecord::Base
  belongs_to :user

  def title
    (super or self.url)
  end
end
