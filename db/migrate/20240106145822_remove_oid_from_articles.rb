class RemoveOidFromArticles < ActiveRecord::Migration[7.1]
  def change
    remove_column :articles, :Oid
  end
end
