class AddOidToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :Oid, :integer
  end
end
