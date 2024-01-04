require 'csv'

namespace :users do
  desc "Import users from a CSV file"
  task import: :environment do
    file_path = '/Users/luhaomeng/Downloads/rails/forem_1/csv/user.csv'

    CSV.foreach(file_path, headers: true) do |row|
      user_attributes = row.to_h.merge({ password: 'testtest', password_confirmation: 'testtest' })
      User.create!(user_attributes)
      end
  end
end
