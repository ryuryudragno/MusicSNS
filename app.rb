require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'



enable :sessions#セッション機能

helpers do
    def current_user
        User.find_by(id: session[:user])#idがsession[:user]の人を1人だけ見つける
    end
    
    def like
       Like.all 
    end
end

before do
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
    end
end

before '/home,/search,/:post_id' do
    if current_user.nil?
        redirect '/'
    end#ログインしてない時にtodoを押すとtopページに戻るように
end

get '/' do #最初のページ
#ログインしてるかを判断し、それぞれに応じた値を格納
    @posts = Post.all
    
    erb :index#これだとログインしてなくても作れてしまうから問題
end

get '/signup' do #新規登録の情報入力ページに飛ばす
    erb :sign_up
end

post '/signup' do
    img_url = ""
    if params[:file]
        img = params[:file]
        tempfile = img[:tempfile]
        upload = Cloudinary::Uploader.upload(tempfile.path)
        img_url = upload['url']
	end#写真をCloudinaryにアップロード
    
    
    user = User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        img: img_url
        )
    
    if user.persisted?
        session[:user] = user.id #userと言うキーにuser.idを入れる
    end
    redirect '/'
end

post '/signin' do #サインインのデータを受け取りパスワード正しいか認証
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/'
end

get '/signout' do #サインアウト
    session[:user] =nil
    redirect '/'
end


get '/search' do #検索語からAPIでJSONを取得し必要なデータを格納する
    searchTerm = params[:searchTerm]
    @limits = 10
    uri = URI("https://itunes.apple.com/search")
    uri.query = URI.encode_www_form({
        term: searchTerm,#検索語句
        country: "jp",
        limit: @limits
    })#クエリ指定
    # @uri = uri #日本語だと検索後は文字化けするが検索結果はちゃんと返ってくる
    res = Net::HTTP.get_response(uri)#上のuriから情報を手に入れる
    json = JSON.parse(res.body)#JSONの型にする,ここまでok
    @searchResults = json["results"]#そこから情報を取り出す
    
    erb :search
end

get '/home' do #ユーザー情報のページに飛ばす
    @posts = Post.where(user_id: current_user.id)
    erb :home
end


post '/new' do  #コメントを取得し投稿
    _post = Post.create(
        user_id: current_user.id,
        img: params[:imgUrl],
        artist: params[:artist],
        music: params[:musicUrl],
        comment: params[:comment]
    )
    _post.save
    redirect '/home'
end

get '/:post_id/edit' do #編集ページ機能
    @post = Post.find(params[:post_id])
    erb :edit
end

post '/:post_id/edit' do  #編集された値を受け取る機能
    _post = Post.find(params[:post_id])
    _post.comment = params[:comment]
    _post.save
    
    redirect '/home'
end

get '/:post_id/delete'  do #投稿削除機能
    _post = Post.find(params[:post_id])
    _post.destroy
    redirect '/home'
end



get '/:post_id/like' do#いいね機能
    Like.create(
        user_id: current_user.id,
        post_id: params[:post_id]
    )
    
    redirect '/'
end