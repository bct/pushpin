class CreateDelayedRequests < ActiveRecord::Migration
  def self.up
    create_table :delayed_requests do |t|
      t.column :method, :string, :null => false
      t.column :controller, :string, :null => false
      t.column :action, :string, :null => false
      t.column :params, :string, :null => false
    end
  end

  def self.down
    drop_table :delayed_requests
  end
end
