require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'

enable :sessions#セッション機能

helpers do
    def current_user
        User.find_by(id: session[:user])
    end
end

get '/' do
    if current_user.nil?
        @tasks = Task.none
    else
        @tasks = current_user.tasks
    end
    erb :index #これだとログインしてなくても作れてしまうから問題
end

get '/signup' do
    erb :sign_up
end

post '/signup' do
    user = User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation]
        )
    if user.persisted?
        session[:user] = user.id
    end
    redirect '/'
end

get '/signin' do
    erb :sign_in
end

post '/signin' do
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/'
end

get '/signout' do
    session[:user] =nil
    redirect '/'
end

get '/tasks/new' do
    erb :new
end

before '/tasks' do
    if current_user.nil?
        redirect '/'
    end#ログインしてない時にtodoを押すとtopページに戻るように
end

post '/tasks' do
    current_user.tasks.create(title: params[:title])
    #Userクラスのインスタンス.tasks.create()であるユーザーの所属するtodoリストを作れる
    redirect '/'
end