
# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base
  def collections
    Collection.find_all_by_user_id(self.id)
  end
 
  def auth_for abs_url, realm
    HTTPAuth.find :first, :conditions => [ 'user_id = ? and abs_url = ? and realm = ?', self.id, abs_url, realm ]
  end

  def self.get(openid_url)
    find(:first, :conditions => ["openid_url = ?", openid_url])
  end  
  
  protected
  
  validates_uniqueness_of :openid_url, :on => :create
  validates_presence_of :openid_url
end
