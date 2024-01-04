class ExportsController < ApplicationController
  def export_ratings_to_csv
    users = User.all
    articles = Article.all

    # Define the file path
    file_path = Rails.root.join('csv', "article-ratings-#{Date.today}.csv")

    # Generate and write CSV data to the file
    CSV.open(file_path, 'wb') do |csv|
      header = ['Article / User'] + users.map(&:id)
      csv << header

      articles.each do |article|
        row = [article.id]
        users.each do |user|
          rating = Rating.find_by(user: user, article: article)
          row << (rating ? rating.score : 0)
        end
        csv << row
      end
    end
  end


  def export_user_ratings
    user = User.find_by(username: 'test') # Assuming the username is 'test'
    return unless user

    ratings = user.ratings.includes(:article)

    # Define the CSV file headers
    headers = ['Article ID', 'Rating Score', 'Oid']

    # Generate CSV data
    csv_data = CSV.generate(headers: true) do |csv|
      csv << headers
      ratings.each do |rating|
        csv << [rating.article_id, rating.score, rating.article.Oid]
      end
    end

    # Send the CSV data as a file
    send_data csv_data, filename: "user-#{user.id}-ratings.csv"
  end

end