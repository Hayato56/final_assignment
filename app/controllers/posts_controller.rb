require "open-uri"

class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all

    # キーワード検索
    if params[:search].present?
      @posts = @posts.where("artist ILIKE ? OR title ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # ジャンル絞り込み (追加)
    if params[:genre].present?
      @posts = @posts.where(genre: params[:genre])
    end

    @posts = @posts.page(params[:page]).per(10)
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)

    # 【重要】もしリモート画像URLがあり、かつ手動でファイルが選択されていない場合
    if params[:post][:remote_image_url].present? && !@post.image.attached?
      begin
        downloaded_image = URI.open(params[:post][:remote_image_url])
        @post.image.attach(io: downloaded_image, filename: "discogs_#{Time.now.to_i}.jpg")
      rescue => e
        logger.error "画像ダウンロードエラー: #{e.message}"
      end
    end

    if @post.save
      redirect_to @post, notice: t('posts.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: t('posts.updated'), status: :see_other }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, notice: t('posts.destroyed'), status: :see_other }
      format.json { head :no_content }
    end
  end

  def fetch_discogs
    # トークンを使って初期化
    wrapper = Discogs::Wrapper.new(DISCOGS_CONFIG[:app_name], user_token: DISCOGS_CONFIG[:token])

    results = wrapper.search(params[:title], artist: params[:artist], type: :release)

    if results&.results&.any?
      result = results.results.first
      render json: {
        success: true,
        image_url: result.cover_image,
        year: result.year,
        genre: result.genre&.first
      }
    else
      render json: { success: false }
    end
  rescue => e
    # ここでエラー内容をログに出力します
    logger.error "---------- Discogs API Error ----------"
    logger.error e.message
    logger.error e.backtrace.join("\n")
    render json: { success: false, message: e.message }, status: :internal_server_error
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      # :artist, :genre, :release_year を追加して許可します
      params.require(:post).permit(:title, :body, :artist, :genre, :release_year, :image, :remote_image_url, :obi, :cleaning_history)
    end
end
