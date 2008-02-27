class HTTPAuth < ActiveRecord::Base
  acts_as_secure :crypto_provider => $crypt

  belongs_to :user
end
