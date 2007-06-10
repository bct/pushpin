class User < ActiveRecord::Base
  def collections
    Collection.find_all_by_user_id(self.id)
  end

  def auth_for abs_url, realm
    HTTPAuth.find :first, :conditions => [ 'user_id = ? and abs_url = ? and realm = ?', self.id, abs_url, realm ]
  end
end
