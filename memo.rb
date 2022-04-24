# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

##################################################
# GET
##################################################
get '/' do
  redirect to('/memo')
end

get '/memo' do
  @title = 'Top'
  @memo_list = get_memos
  erb :top
end

get '/memo/new' do
  @title = 'New memo'
  erb :new
end

get %r{/memo/([0-9]*)} do
  id = params['captures'].first.to_i
  @title = 'Show memo'
  @memo = edit_memos(id)
  @memo['contents'].gsub!(/\r\n/, '<br>')
  erb :show
end

get %r{/memo/([0-9]*)/edit} do
  id = params['captures'].first.to_i
  @title = 'Edit memo'
  @memo = edit_memos(id)
  @memo['contents'].gsub!(/\r\n/, '<br>')
  erb :edit
end

not_found do
  'This is nowhere to be found.'
end
##################################################
# POST
##################################################
post '/memo/new' do
  # add_memo(**params)
  add_memos(**params)
  redirect to('/memo')
end

patch %r{/memo/([0-9])*/edit} do
  edit_memo(**params)
  redirect to('/memo')
end

delete %r{/memo/([0-9]*)} do
  id = params['captures'].first.to_i
  #delete_memo(id)
  #redirect '/memo'
  delete_memos(id)
  redirect to('/memo')
end

##################################################
# 関数
##################################################
MEMO_JSON = 'json/memo.json'
SANITIZE_WORDS = [
  { 'before_string': '<', 'after_string': '&lt;' },
  { 'before_string': '>', 'after_string': '&gt;' },
  { 'before_string': '&', 'after_string': '&amp;' },
  { 'before_string': '“', 'after_string': '&quot;' },
  { 'before_string': '`', 'after_string': '&#x27;' }
].freeze

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
  sanitize(**params)
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
  sanitize(**params)
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

def sanitize(sanitize_strings)
  SANITIZE_WORDS.each do |sanitize_word|
    sanitize_strings[:title].gsub!(sanitize_word[:before_string], sanitize_word[:after_string])
    sanitize_strings[:contents].gsub!(sanitize_word[:before_string], sanitize_word[:after_string])
  end
end

def get_memos
  connect = PG::Connection.open(dbname: "sinatra", user: "choco")
  results = connect.exec("select * from memos")
  results.map { |result| result}
end

# def edit_memos(id)
#   connect = PG::connect(dbname: "sinatra", user: "choco")
#   results = connect.exec("select * from memos where id = #{id}")
#   connect.finish
#   results.map { |result| result}[0]
# end

# def delete_memos(id)
#   connect = PG::connect(dbname: "sinatra", user: "choco")
#   results = connect.exec("delete from memos where id = #{id}")
#   connect.finish
# end

# def add_memos(id)
#   sanitize(**params)
#   params['id'] = max_id(read_memo_json) + 1
# end