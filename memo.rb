# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

##################################################
# GET
##################################################
enable :method_override
get '/' do
  redirect '/memo'
end

get '/memo' do
  @title = 'memo'
  @memo_list = read_memo_json
  erb :index
end

get '/memo/new' do
  @title = 'new'
  erb :new
end

get %r{/memo/([0-9])} do
  id = params['captures'].first.to_i
  @title = 'show'
  @memo = self_memo(read_memo_json,id)
  @memo["contents"].gsub!(/\r\n/,'<br>')
  erb :show
end

get %r{/memo/([0-9])/edit} do
  id = params['captures'].first.to_i
  @title = 'edit'
  @memo = self_memo(read_memo_json,id)
  @memo["contents"].gsub!(/\r\n/,'<br>')
  erb :edit
end

##################################################
# POST
##################################################
post '/memo/new' do
  add_memo(**params)
  redirect '/memo'
end

# post %r{/memo/([0-9])} do
#   id = params['captures'].first.to_i
#   delete_memo(id)
#   redirect '/memo'
# end

delete %r{/memo/([0-9])} do
  erb "delete"
  # id = params['captures'].first.to_i
  # delete_memo(id)
  # redirect '/memo'
end

post %r{/memo/([0-9])/edit} do
  edit_memo(**params)
  redirect '/memo'
end

##################################################
# 関数
##################################################
MEMO_JSON = "json/memo.json"

def append_memo_json(params)
  File.open("json/memo.json","a") do |file|
    file.puts(JSON.generate(params))
  end
end

def max_id(contents)
  max_id = contents.map { |content| content['id'] }.max.to_i
end

def read_memo_json
  file_path = File.expand_path(MEMO_JSON)
  File.read(file_path).split(/\n/).map { |content| JSON.load(content) }
end

def self_memo(memo_list, id)
  memo_list.map { |memo| memo['id'] == id ? memo : nil }.compact[0]
end

def add_memo(params)
  params["id"] = max_id(read_memo_json) + 1
  append_memo_json(**params)
end

def delete_memo(memo_id)
  memo_list = read_memo_json
  File.new(MEMO_JSON,'w')
  memo_list.each do |memo|
    if memo['id'] != memo_id
      append_memo_json(memo)
    end
  end
end

def edit_memo(params)
  id = params['captures'].first.to_i
  memo_list = read_memo_json
  File.new(MEMO_JSON,'w')
  memo_list.each do |memo|
    if memo['id'] == id
      memo["title"] = params["title"]
      memo["contents"] = params["contents"]
    end
    append_memo_json(memo)
  end
end