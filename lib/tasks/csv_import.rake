namespace :csv_import do
  desc "Import articles from a CSV file"
  task articles: :environment do
    require 'csv'

    CSV.foreach('/Users/luhaomeng/Downloads/rails/forem_1/csv/test.csv', headers: true) do |row|
      article_attributes = row.to_hash.except('tags')
      article_attributes['status'] ||= 'public' # Default status
      tags = row['tags'].split('|') # Split the tags by comma

      begin
        Article.transaction do
          article = Article.create!(article_attributes)
          tags.each do |tag_name|
            tag = Tag.find_or_create_by!(name: tag_name.strip) # Create the tag if it doesn't exist
            article.tags << tag # Associate the tag with the article
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        puts "Unable to save article: #{article_attributes['title']}. Error: #{e.message}"
      end
    end
  end
end

