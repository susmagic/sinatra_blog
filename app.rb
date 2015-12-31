require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
    @db = SQLite3::Database.new 'dof.db'
    @db.results_as_hash = true
end

before do
    #инициализация бд
    init_db
end

#configure вызывается каждый раз при конфигураций приложения:
#когда изменился код программы и перезагрузилась страница

configure do
    #инициализация бд
    init_db
    #создает таблицу если таблица не существует
    @db.execute 'CREATE TABLE IF NOT EXISTS Posts 
    (
    id INTEGER PRIMARY KEY AUTOINCREMENT , 
    created_date DATE, 
    content TEXT
    )'
end

get '/' do
	erb :index
end

get '/new' do
    erb :new
end

post '/new' do
    # получаем переменную из post-запрсоа
    @content = params[:content]

    if @content.length <= 0
        @error = 'Type post text'
        return erb :new
    end

    #сохранение данных в БД
    @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [@content]

    erb "You typed: #{@content}"
end