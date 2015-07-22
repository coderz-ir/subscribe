require 'sinatra'
require 'data_mapper'
require 'haml'
require 'sass'
require 'sinatra/reloader'
require 'digest/sha1'

#Settings
$settings = {
  :db_address => "sqlite3://#{Dir.pwd}/dbname.db",
  :salt => "@ l0nG $TreeNg"
  }

#Assets
set :public_folder, '/assets'
get('/style.css'){ scss :'scss/style' }


#Database
DataMapper::setup(:default,$settings[:db_address])

class User
  include DataMapper::Resource
  property :id, Serial
  property :email, Text , :required => true 
  property :isactive, Boolean , :default  => false
  property :activecode, Text
  
  attr_accessor :isactivate
end

DataMapper.finalize
User.auto_upgrade!


#Routes
get '/' do
  haml :index
end


post '/' do
  user = User.new(:email => params[:email], :isactive => false, :activecode => Digest::SHA1.hexdigest(params[:email] + $settings[:salt]))
  
  if user.save
    redirect '/'
  else
    redirect '/403'
  end
end


get '/list' do
  @users = User.all(:order => [ :id.desc ], :limit => 20)
  haml :list
end


get '/active' do
  haml :active
end

get '/active' do
  puts params[:email]
  user = User.all(:activecode => params[:ac], :email => params[:email])
  user.update :isactive => true
  
end
