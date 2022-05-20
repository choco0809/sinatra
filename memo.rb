# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'cgi'

##################################################
# GET
##################################################
get '/' do
  redirect to('/memos')
end

get '/memos' do
  @title = 'Top'
  @memo_list = memos
  erb :top
end

get '/memos/new' do
  @title = 'New memo'
  erb :new
end

get %r{/memos/([0-9]*)} do
  id = params['captures'].first.to_i
  @title = 'Show memo'
  @memo = show_memo(id)
  @memo['contents'].gsub!(/\r\n/, '<br>')
  erb :show
end

get %r{/memos/([0-9]*)/edit} do
  id = params['captures'].first.to_i
  @title = 'Edit memo'
  @memo = show_memo(id)
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
  id = params['captures'].first.to_i
  edit_memo(id, **params)
  redirect to('/memos')
end

delete %r{/memos/([0-9]*)} do
  id = params['captures'].first.to_i
  delete_memo(id)
  redirect to('/memos')
end

##################################################
# 関数
##################################################

def memos
  results = Memo.memos
  results.map { |result| result }
end

def add_memo(params)
  Memo.add_memo([params['title'], params['contents']])
end

def edit_memo(id, params)
  Memo.update_memo([id, params['title'], params['contents']])
end

def show_memo(id)
  results = Memo.show_memo(id)
  results.map { |result| result }[0]
end

def delete_memo(id)
  Memo.delete_memo(id)
end

class Memo
  @con = PG.connect(dbname: 'sinatra')

  def self.memos
    @con.exec('select * from memos')
  end

  def self.show_memo(id)
    @con.exec('select * from memos where id = $1', [id])
  end

  def self.delete_memo(id)
    @con.exec('delete from memos where id = $1', [id])
  end

  def self.add_memo(params)
    @con.exec('insert into memos(title,contents) values($1,$2)', params)
  end

  def self.update_memo(params)
    @con.exec('update memos set title = $2, contents = $3 where id = $1', params)
  end
end
