class Collection < ActiveRecord::Base
  belongs_to :user

  def title
    (super or self.url)
  end
  
  validates_uniqueness_of :url, :on => :create, :scope => [ :user_id ]
end
