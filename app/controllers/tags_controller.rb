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
end
