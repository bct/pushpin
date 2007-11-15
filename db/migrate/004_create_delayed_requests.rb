class CreateDelayedRequests < ActiveRecord::Migration
  def self.up
    create_table :delayed_requests do |t|
      t.column :user_id, :integer, :null => false
      t.column :method, :string, :null => false
      t.column :url, :string, :null => false
      t.column :params, :string, :null => false
    end
  end

  def self.down
    drop_table :delayed_requests
  end
end
