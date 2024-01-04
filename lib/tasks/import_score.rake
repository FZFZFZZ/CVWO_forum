require 'csv'

namespace :data_import do
  desc "Import scores from a CSV file"
  task import_scores: :environment do

  csv_file_path = '/Users/luhaomeng/Downloads/rails/forem_1/csv/rating.csv'

# Reading CSV file
  CSV.foreach(csv_file_path, headers: true) do |row|
    username = row['username']
    oid = row['Oid']
    score = row['Score'].to_f

    user = User.find_by(username: username)
    article = Article.find_by(Oid: oid)

    if user && article
      user.ratings.create(article: article, score: score)
    else
    end
  end
end
end