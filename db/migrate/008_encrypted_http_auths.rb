class EncryptedHttpAuths < ActiveRecord::Migration
  def self.up
    remove_column :http_auths, :password

    add_column :http_auths, :password, :binary, :null => false, :default => ''
  end

  def self.down
    remove_column :http_auths, :password

    add_column :http_auths, :password, :string, :null => false, :default => ''
  end
end
