class AddSharingPreferencesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :favshare, :boolean, default: true
    add_column :users, :contactshare, :boolean, default: true
    add_column :users, :historyshare, :boolean, default: true
  end
end
