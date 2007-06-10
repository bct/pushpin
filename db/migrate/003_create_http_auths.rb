class CreateHttpAuths < ActiveRecord::Migration
  def self.up
    create_table :http_auths do |t|
      t.column :user_id, :integer, :null => false
      t.column :abs_url, :string, :null => false
      t.column :realm, :string, :null => false

      t.column :username, :string, :null => false
      t.column :password, :string, :null => false
    end
  end

  def self.down
    drop_table :http_auths
  end
end
