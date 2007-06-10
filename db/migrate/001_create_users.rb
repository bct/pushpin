class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :openid, :string, :null => false
      t.column :name, :string
      t.column :uri, :string
    end

    add_index :users, :openid, :unique => true
  end

  def self.down
    drop_table :users
  end
end
