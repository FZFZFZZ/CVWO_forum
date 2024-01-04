class AddYearToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :year, :integer
  end
end
