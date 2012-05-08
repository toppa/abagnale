require 'rubygems'
require 'sinatra'
require 'pry'
require 'pg'
require 'active_record'

ActiveRecord::Base.establish_connection(
   :adapter => 'postgresql',
   :database =>  'abagnale'
)
# ActiveRecord::Base.logger = Logger.new(STDOUT)

require './cc'

get '/hi' do
  "Hello World\n"
end

# Chase Paymentech Orbital
post '/authorize' do
  xml = request.body.read
  fullccnum = $1 if xml =~ /<AccountNum>(.*)<\/AccountNum>/
  result = case xml
  when /<MarkForCapture>/
    'capture_success'
  else
    'auth_' + Cc.result(fullccnum)
  end
  puts "card #{fullccnum} orbital #{result}"
  headers "Content-Type" => 'application/xml'
  File.read(File.dirname(__FILE__) + "/fixtures/orbital/#{result}.xml")
end

# Litle
post '/vap/communicator/online' do
  xml = request.body.read
  fullccnum = $1 if xml =~ /<number>(.*)<\/number>/
  result = case xml
  when /<capture/
    'capture_success'
  else
    'auth_' + Cc.result(fullccnum)
  end
  puts "card #{fullccnum} litle #{result}"
  headers "Content-Type" => 'application/xml'
  File.read(File.dirname(__FILE__) + "/fixtures/litle/#{result}.xml")
end
