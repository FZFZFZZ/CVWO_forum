namespace :update_article_bodies do
  desc 'Update article bodies with TMDB overviews'

  task :run => :environment do
    api_key = '02b5038b15929363b9e32356dc01dad8'
    articles = Article.all

    articles.each do |article|
      movie_title = article.title
      movie_id = fetch_movie_id(api_key, movie_title)

      if movie_id.present?
        overview = fetch_movie_overview(api_key, movie_id)
        article.update(body: overview)
        puts "Updated article #{article.id} with overview from TMDB."
      else
        puts "No movie found for title '#{movie_title}' on TMDB."
      end
    end
  end

  def fetch_movie_id(api_key, movie_title)
    search_url = URI("https://api.themoviedb.org/3/search/movie?query=#{CGI.escape(movie_title)}&api_key=#{api_key}")
    search_response = Net::HTTP.get(search_url)
    search_result = JSON.parse(search_response)

    if search_result['results'].present?
      return search_result['results'].first['id']
    else
      return nil
    end
  end

  def fetch_movie_overview(api_key, movie_id)
    details_url = URI("https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{api_key}")
    details_response = Net::HTTP.get(details_url)
    movie_data = JSON.parse(details_response)

    return movie_data['overview']
  end
end
