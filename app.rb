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

    @db.execute 'CREATE TABLE IF NOT EXISTS Comments 
    (
    id INTEGER PRIMARY KEY AUTOINCREMENT , 
    created_date DATE, 
    content TEXT,
    post_id INTEGER
    )'
end

get '/' do
    #выбираем список постов из БД
    @results = @db.execute 'select * from Posts order by id desc'
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
    #перенаправление на главную страницу
    redirect to '/'
end

#вывод информаций о посте
get '/details/:post_id' do
    #получаем переменную из utl'a
    post_id = params[:post_id]

    #получаем список постов
    #у нас будет только 1 пост
    results = @db.execute 'select * from Posts where id = ?', [post_id]
    #выбираем этот 1 пост в переменную @row
    @row = results[0]

    #возвращаем представление /details
    erb :details
end

post '/details/:post_id' do
    #получаем переменную из utl'a
    post_id = params[:post_id]
    content = params[:content]

    erb "ok #{content} for post #{post_id}"
end
