class TagsController < ApplicationController
  before_action :set_tag, only: %i[ show edit update destroy ]
  before_action :check_admin, only: [:new, :edit, :create, :update, :destroy]
  
  def index
    @tags = Tag.all
  end

  def show

    @tag = Tag.find(params[:id])
    @top_rated_articles = Article.joins(:ratings, :taggables)
                                 .where(taggables: { tag_id: @tag.id })
                                 .select('articles.*, AVG(ratings.score) as average_rating')
                                 .group('articles.id')
                                 .order('average_rating DESC')
                                 .limit(10)
    @top_rated_articles.each do |article|
      article_data, article_poster_url = fetch_movie_data_and_poster(article.title)
      article.poster_url = article_poster_url
    end
  end

  def new
    @tag = Tag.new
  end

  def edit
  end

  def create
    @tag = Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to tag_url(@tag), notice: "Tag was successfully created." }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to tag_url(@tag), notice: "Tag was successfully updated." }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @tag.destroy!

    respond_to do |format|
      format.html { redirect_to articles_url, notice: "Tag was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.require(:tag).permit(:name)
    end

    def check_admin
      unless admin_user?
        flash[:alert] = "You are not authorized to access this page."
        redirect_to articles_path
      end
    end

    def fetch_movie_data_and_poster(movie_title)

      api_key = '02b5038b15929363b9e32356dc01dad8'
      search_url = URI("https://api.themoviedb.org/3/search/movie?query=#{CGI.escape(movie_title)}&api_key=#{api_key}")
      search_response = Net::HTTP.get(search_url)
      search_result = JSON.parse(search_response)
  
      if search_result['results'].present?
        movie_id = search_result['results'].first['id']
  
        details_url = URI("https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{api_key}")
        details_response = Net::HTTP.get(details_url)
        movie_data = JSON.parse(details_response)
  
        poster_url = fetch_movie_poster_url(movie_data['poster_path'])
        return movie_data, poster_url
      else
        return nil, nil
      end

    end



    def fetch_movie_poster_url(poster_path)
  
      return "https://image.tmdb.org/t/p/original#{poster_path}" if poster_path.present?
  
    end
end
