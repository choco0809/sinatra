# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'cgi'

##################################################
# GET
##################################################
get '/' do
  redirect to('/memos')
end

get '/memos' do
  @title = 'Top'
  @memo_list = read_memo_json
  erb :top
end

get '/memos/new' do
  @title = 'New memo'
  erb :new
end

get %r{/memos/([0-9]*)} do
  id = params['captures'].first.to_i
  @title = 'Show memo'
  @memo = self_memo(read_memo_json, id)
  @memo['contents'].gsub!(/\r\n/, '<br>')
  erb :show
end

get %r{/memos/([0-9]*)/edit} do
  id = params['captures'].first.to_i
  @title = 'Edit memo'
  @memo = self_memo(read_memo_json, id)
  @memo['contents'].gsub!(/\r\n/, '<br>')
  erb :edit
end

not_found do
  'This is nowhere to be found.'
end
##################################################
# POST
##################################################
post '/memos/new' do
  add_memo(**params)
  redirect to('/memos')
end

patch %r{/memos/([0-9])*/edit} do
  edit_memo(**params)
  redirect to('/memos')
end

delete %r{/memos/([0-9]*)} do
  id = params['captures'].first.to_i
  delete_memo(id)
  redirect '/memos'
end

##################################################
# 関数
##################################################
MEMO_JSON = 'json/memo.json'

def append_memo_json(params)
  File.open('json/memo.json', 'a') do |file|
    file.puts(JSON.generate(params))
  end
end

def max_id(contents)
  contents.map { |content| content['id'] }.max.to_i
end

def read_memo_json
  file_path = File.expand_path(MEMO_JSON)
  File.read(file_path).split(/\n/).map { |content| JSON.parse(content) }
end

def self_memo(memo_list, id)
  memo_list.map { |memo| memo['id'] == id ? memo : nil }.compact[0]
end

def add_memo(params)
  params['id'] = max_id(read_memo_json) + 1
  append_memo_json(**params)
end

def delete_memo(memo_id)
  memo_list = read_memo_json
  File.new(MEMO_JSON, 'w')
  memo_list.each do |memo|
    memo['id'] != memo_id && append_memo_json(memo)
  end
end

def edit_memo(params)
  id = params['captures'].first.to_i
  memo_list = read_memo_json
  File.new(MEMO_JSON, 'w')
  memo_list.each do |memo|
    if memo['id'] == id
      memo['title'] = params['title']
      memo['contents'] = params['contents']
    end
    append_memo_json(memo)
  end
end
