class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :openid_url, :string, :null => false
      t.column :name, :string
      t.column :uri, :string
    end

    add_index :users, :openid_url, :unique => true
  end

  def self.down
    drop_table :users
  end
end
