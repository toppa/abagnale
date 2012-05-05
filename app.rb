require 'sinatra'
require 'pry'

require 'cc'

get '/hi' do
  "Hello World\n"
end

# Chase Paymentech Orbital
post '/authorize' do
  xml = request.body.read
  fullccnum = $1 if xml =~ /<AccountNum>(\d*)<\/AccountNum>/
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
  fullccnum = $1 if xml =~ /<number>(\d*)<\/number>/
  result = case fullccnum
  when /<capture/
    'capture_success'
  else
    'auth_' + Cc.result(fullccnum)
  end
  puts "card #{fullccnum} litle #{result}"
  headers "Content-Type" => 'application/xml'
  File.read(File.dirname(__FILE__) + "/fixtures/litle/#{result}.xml")
end
