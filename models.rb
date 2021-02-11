require 'bundler/setup'
Bundler.require

if development?
    ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class User < ActiveRecord::Base#大文字の単数形(History)で定義
    has_secure_password
    validates :name,
        presence: true,#空欄はだめ
        format: {with:/\A\w+\z/}#
        # format: {with:/.+@.+/}#@を含む必要がある
    validates :password,
        length: {in: 5..10}#5文字以上10文字以下
    has_many :tasks#ユーザーが複数のtaskを持つ
end

class Task < ActiveRecord::Base#大文字の単数形(History)で定義
    validates :title,
        presence: true#空欄はだめ
    belongs_to :user#1つタスクが1人のユーザーに所属する
    # has_secure_password
    # validates :name,
    #     presence: true,#空欄はだめ
    #     format: {with:/\A\w+\z/}#
    #     # format: {with:/.+@.+/}#@を含む必要がある
    # validates :password,
    #     length: {in: 5..10}#5文字以上10文字以下
end