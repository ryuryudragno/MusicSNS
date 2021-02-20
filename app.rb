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
end

before do
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
    end
end

# before '/tasks' do
#     if current_user.nil?
#         redirect '/'
#     end#ログインしてない時にtodoを押すとtopページに戻るように
# end

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
	end
    
    
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

get '/signin' do #サインインの情報入力ページに飛ばす
    erb :sign_in
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

get '/search' do #検索フォームと検索結果が表示されるページ
    erb :search
end

post '/search' do #検索語からAPIでJSONを取得し必要なデータを格納する
    
    redirect '/search'
end

get '/home' do #ユーザー情報のページに飛ばす
    erb :home
end


post '/new' do  #コメントを取得し投稿
    task = Task.find(params[:id])
    task.completed = true
    task.save
    #Userクラスのインスタンス.tasks.create()であるユーザーの所属するtodoリストを作れる
    redirect '/home'
end

get '/:post_id/edit' do #編集ページ機能
    task = Task.find(params[:id])
    task.star = !task.star
    task.save
    #Userクラスのインスタンス.tasks.create()であるユーザーの所属するtodoリストを作れる
    redirect '/'
end

post '/:post_id/edit' do  #編集された値を受け取る機能
    task = Task.find(params[:id])
    task.destroy
    #Userクラスのインスタンス.tasks.create()であるユーザーの所属するtodoリストを作れる
    redirect '/home'
end

post '/:post_id/delete'  do #投稿削除機能
    @task = Task.find(params[:id])
    redirect '/home'
end



post '/:post_id/like' do#いいね機能
    date = params[:due_date].split('-')#String型のものを-できって配列にする
    list = List.find(params[:list])
    if Date.valid_date?(date[0].to_i,date[1].to_i,date[2].to_i)
        current_user.tasks.create(
            title: params[:title],
            due_date: Date.parse(params[:due_date]),
            list_id: list.id
        )
        redirect '/'
    #Userクラスのインスタンス.tasks.create()であるユーザーの所属するtodoリストを作れる
    else
        redirect '/home'
    end
end