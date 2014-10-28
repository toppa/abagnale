#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'sinatra/content_for'
require 'pry'
require 'pg'
require 'active_record'
require 'nokogiri'
require 'logger'
require 'slim'
require 'will_paginate'
require 'will_paginate/active_record'
require 'uri'

logger = Logger.new(STDOUT)

db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/abagnale')

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :port     => db.port,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
  # :min_messages => 'warning'
)

# ActiveRecord::Base.logger = Logger.new(STDOUT)

require './cc'
require './transaction'

helpers do
  def commify(num)
    num =~ /([^\.]*)(\..*)?/
    int, dec = $1.reverse, $2 ? $2 : ""
    while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
    end
    int.reverse + dec
  end
  def to_dollars(num, args = {})
    string = num.abs.to_s
    string.insert(0, "0") while string.length < 3
    string.insert(-3, '.')
    string.insert(0, '-') if (num < 0)
    string = string.chop.chop.chop if args[:hide_cents]
    (args[:commify] == false) ? string : commify(string)
  end
  def litle_batch_response(transactions, xml_template)
    doc =  Nokogiri::XML(xml_template)
    first_response = doc.at_css('captureResponse')
    transactions.each_with_index do |transaction, i|
      new_response = first_response.dup(1)
      new_response['id'] = transaction.original_id.to_s
      new_response.at_css('litleTxnId').content = "abagnale-#{transaction.id}"
      new_response.at_css('orderId').content = transaction.order
      first_response.before(new_response)
    end
    (doc.xpath('//xmlns:captureResponse').size - transactions.size).times {
      doc.xpath('//xmlns:captureResponse').last.remove }
    doc.to_xml
  end
  def process_litle(type)
    xml = request.body.read
    logger.info("Litle headers: '#{Hash[request.env.select{|k,v| k =~ /HTTP_/}].inspect}'")
    logger.info("Content-Length: #{request.content_length} User-Agent: '#{request.user_agent}'")
    logger.info("Litle request: '#{xml}'")
    begin
      doc =  Nokogiri::XML(xml)
      ns = doc.children.first.namespace.href # dumbass xml namespaces

      requests = if type == :online
          doc.xpath("//ns:litleOnlineRequest/*", 'ns' => ns)
        else
          doc.xpath("//ns:litleRequest/*", 'ns' => ns)
        end
      case request_name = requests.last.name
      when "authorization"
        fullccnum = doc.xpath('//ns:card/ns:number', 'ns' => ns).inner_text
        name = doc.xpath('//ns:name', 'ns' => ns).inner_text
        order = doc.xpath('//ns:orderId', 'ns' => ns).inner_text
        amount = doc.xpath('//ns:amount', 'ns' => ns).inner_text

        result = Cc.result(fullccnum, amount)
        tx = Transaction.create!(:fullccnum => fullccnum, :name => name, :auth_result => result, :order => order, :amount => amount)
        body = File.read(File.dirname(__FILE__) + "/fixtures/litle/auth_#{result}.xml")
        body.gsub!(/BADFOODDEADBEE-LITLE/, "abagnale-#{tx.id}")
      when "capture"
        txrefnum = doc.xpath('//ns:litleTxnId', 'ns' => ns).inner_text
        tx_id = txrefnum.split('-').last
        Transaction.find(tx_id).update_attributes(:settled_at => Time.now)
        body = File.read(File.dirname(__FILE__) + "/fixtures/litle/capture_success.xml")
      when "credit"
        txrefnum = doc.xpath('//ns:litleTxnId', 'ns' => ns).inner_text
        tx_id = txrefnum.split('-').last
        if transaction = Transaction.find_by_id(tx_id)
          transaction.update_attributes(:refunded_at => Time.now)
        end
        body = File.read(File.dirname(__FILE__) + "/fixtures/litle/credit_success.xml")
      when "batchRequest"
        transactions = []
        doc.css('capture').each do |capture|
          txrefnum = capture.at_xpath('ns:litleTxnId', 'ns' => ns).text
          amount = capture.at_xpath('ns:amount', 'ns' => ns).text.to_i
          tx_id = txrefnum.split('-').last
          transaction = Transaction.find(tx_id)
          transaction.update_attributes(settled_at: Time.now, amount: amount, original_id: capture['id'])
          transactions << transaction
        end
        body = litle_batch_response(transactions,
                                    File.read(File.dirname(__FILE__) + "/fixtures/litle/capture_batch_success.xml"))
      else
        logger.warn("Unrecognized litle request #{request_name}")
        halt 400, "What are you talking about?"
      end
      headers "Content-Type" => 'application/xml'
      body
    rescue => err
      logger.warn("Bogus litle request: #{err}")
      halt 400, "What's the matter with you?"
    end
  end
end

get '/hi' do
  "Hello World\n"
end

get '/' do
  @transactions = Transaction.paginate(:page => params[:page], :order => 'created_at DESC')
  slim :index
end

post '/parrot' do
  request.body.read
end

# Chase Paymentech Orbital
post '/authorize' do
  xml = request.body.read
  begin
    doc =  Nokogiri::XML(xml)
    case (request_name = doc.xpath('/Request/*').first.name)
    when "NewOrder"
      fullccnum = doc.xpath('//AccountNum').inner_text
      name = doc.xpath('//AVSname').inner_text
      order = doc.xpath('//OrderID').inner_text
      amount = doc.xpath('//Amount').inner_text

      result = Cc.result(fullccnum, amount)
      tx = Transaction.create!(:fullccnum => fullccnum, :name => name, :auth_result => result, :order => order, :amount => amount)
      body = File.read(File.dirname(__FILE__) + "/fixtures/orbital/auth_#{result}.xml")
      body.gsub!(/BADFOODDEADBEEFDECAFBAD123456789-ORBITAL/, "abagnale-#{tx.id}")
    when "MarkForCapture"
      txrefnum = doc.xpath('//TxRefNum').inner_text
      tx_id = txrefnum.split('-').last
      Transaction.find(tx_id).update_attributes(:settled_at => Time.now)
      body = File.read(File.dirname(__FILE__) + "/fixtures/orbital/capture_success.xml")
    else
      logger.warn("Unrecognized orbital request #{request_name}")
    end
    headers "Content-Type" => 'application/xml'
    body
  rescue => err
    logger.warn("Bogus orbital request: #{err}")
    halt 400, "What's the matter with you?"
  end
end

# Litle
post '/vap/communicator/online' do
  process_litle(:online)
end

post '/' do
  process_litle(:batch)
end
