require "active_function"

class BlogPostFunction < ActiveFunction::Base
  PERMITTED_PARAMS = %i[title body]

  before_action :set_blog_post, only: %i[show update], if: :authorized?

  def index
    @blog_posts = DB[:blog_posts].all

    render json: @blog_posts
  end

  def show
    render json: @blog_post
  end

  def create
    blog_post = DB[:blog_posts].create(blog_post_attributes)

    if blog_post.errors.blank?
      render json: blog_post
    else
      render json: { errors: blog_post.errors }, status: 422
    end
  end

  def update
    @blog_post.update(blog_post_attributes)

    if @blog_post.errors.blank?
      render json: @blog_post
    else
      render json: { errors: @blog_post.errors }, status: 422
    end
  end

  def destroy
    @blog_post.destroy

    render json: @blog_post
  end

  private

  def authorized?
    true
  end

  def blog_post_attributes
    request_data
      .require(:blog_post)
      .permit(PERMITTED_PARAMS)
      .to_h
  end

  def request_data
    params.require(:body).permit(data: {})
  end

  def set_blog_post
    @blog_post = DB[:blog_posts].where(id: params.require(:id)).first
  end
end