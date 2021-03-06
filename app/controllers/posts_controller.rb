class PostsController < ApplicationController
  def index
    @posts = Post.all.order(created_at: :desc)
  end

  def new
    @post = Post.new
  end

  def show
    @post = Post.find_by(slug: params[:slug])
  end

  def edit
    @post = Post.find_by(slug: params[:slug])
  end

  def create
    @post = Post.new(post_params)
     
    if @post.save
      redirect_to @post
    else
      render 'new'
    end
  end

  def update
    @post = Post.find_by(slug: params[:slug])

    if @post.update(post_params)
      redirect_to @post
    else
      render 'edit'
    end
  end
  
  private

  def post_params
    params.require(:post).permit(:title, :text)
  end
end
