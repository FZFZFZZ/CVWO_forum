class RemoveFkFromLikesToPost < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :likes, :articles
  end
end
