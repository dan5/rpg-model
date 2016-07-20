require 'haml'
require 'yaml'
require 'sinatra'
require 'sinatra/reloader' if development?

require './lib/rpg_model.rb'
require './master/master.rb'

enable :sessions

helpers do
  def link_to(url, txt = url)
    %Q(<a href="#{url}">#{txt}</a>)   
  end

  def api() @api end
end

if development?
  before do
    Dir.glob('./lib/**/*.rb').each {|e| load e }
  end
end

before /^(?!.*login).+$/ do
  if login = session[:login]
    @api = RpgModel::Api.new(master, 'testman')
    @user = api.user
    @units = @user.units
  else
    redirect to '/login'
  end
end

get '/login' do
  session[:login] = 'hello'
  redirect to '/'
end

get '/battle' do
  @logs = battle
  haml :battle
end

get '/games' do
  @games = @user.games
  haml :games
end

get '/games/:id' do
  @game = @user.games[params[:id]]
  haml :games_show
end

get '/trials' do
  @trials = master[:trials].map {|name, e| RpgModel::Trial.new e }
  haml :trials
end

get '/trials/:name' do
  name = params[:name]
  @trial = RpgModel::Trial.new(master[:trials][name])
  haml :trials_show
end

get '/trials/:name/battle' do
  r = api.trial_battle(params[:name])
  @trial = r.trial
  @logs = r.logs
  haml :trials_battle
end

get '/units' do
  haml :units_list
end

get '/units/:id' do
  @unit = @units[params[:id]]
  haml :units_show
end

get '/units/:id/slots/:slot_idx' do
  @unit = @units[params[:id]]
  @slot_idx = params[:slot_idx]
  haml :units_slots
end

get '/api.game_create' do
  api.game
  redirect to "/games"
end

get '/api.unit_slot_set/:id/:slot_idx/:skill_idx' do
  id = params[:id]
  api.unit_slot_set id, params[:slot_idx].to_i, params[:skill_idx].to_i
  redirect to "/units/#{id}"
end

get '/api.unit_recruit' do
  api.unit_recruit
  redirect to '/'
end

get '/api.unit_join/:id' do
  api.unit_join params[:id]
  redirect to '/'
end

get '/api.unit_swap_order/:unit_id' do
  if session[:swap_unit_id]
    api.unit_swap_order session[:swap_unit_id], params[:unit_id]
    session.delete :swap_unit_id
  else
    session[:swap_unit_id] = params[:unit_id]
  end
  redirect to '/units'
end

get '/api.unit_swap_position/:unit_id' do
  if session[:swap_position_unit_id]
    api.unit_swap_position session[:swap_position_unit_id], params[:unit_id]
    session.delete :swap_position_unit_id
  else
    session[:swap_position_unit_id] = params[:unit_id]
  end
  redirect to '/units'
end

get '/' do
  haml :index
end

__END__

@@ layout
%html
  %title rm api
  = yield
  %p
    = '--'
    footer...
    - if @user
      = @user.name
      GOLD: #{@user.gold}
    = link_to '/', 'home'
    = link_to '/units', 'units'
    = link_to '/games', 'games'
    = link_to '/trials', 'trials'
    = link_to '/api.unit_recruit', 'recruit'
    = '--'

  - @user.new_units.each do |id, u|
    = link_to "/api.unit_join/#{id}", u.name
    %br

@@ index
%p hello!!
= link_to "/units"
= link_to "/trials"
= link_to "/battle"

@@ battle
- @logs.each do |e|
  = e
  %br

@@ games
%p
  = link_to '/api.game_create', 'new game'
- @games.each do |id, e|
  = link_to "/games/#{e.id}", e.name
  %br

@@ games_show
%p= @game.name
%p= @game.logs

@@ trials_battle
= @trial.name
@@ trials
- @trials.each do |e|
  = link_to "/trials/#{e.name}", e.name
  %br

@@ trials_show
= @trial.name
%br
%p= @trial.text
= link_to "/trials/#{@trial.name}/battle", '退治する'
%br

@@ trials_battle
= @trial.name
%br
- @logs.each do |e|
  = e
  %br
= link_to "/trials/#{@trial.name}", 'ok'

@@ units_list
- if session[:swap_unit_id]
  %p unit:#{session[:swap_unit_id]}と打順を入れ替える相手（番号）を選んでください
- position_names = %w(- 投 捕 一 二 三 遊 外 外 外)
%table
  %tr
    %th 打順
    %th 守備
    %th name
    %th 守備
    %th 打撃
    %th パワー
    %th 走
    %th 肩
    %th 守
    %th 魅
  %tr
    %th
  - @units.values.sort_by(&:order_index).each do |unit|
    - if unit.order_index == 10
      %tr
        %td
          %hr
    %tr
      %td=link_to "api.unit_swap_order/#{unit.id}", "##{unit.order_index}"
      %td=link_to "api.unit_swap_position/#{unit.id}", position_names[unit.position_index]
      %td=link_to "/units/#{unit.id}", unit.name
      %td= position_names[unit.position]
      %td= unit.atk
      %td= unit.power
      - unit.abilities.each do |e|
        - grades = %w(G F E D C B A S)
        %td= grades[e]

@@ units_show
= @unit.name
%br
= @unit.abilities.join('/')
%br
- @unit.slots.each.with_index do |slot, i|
  #{i + 1}:
  = link_to "/units/#{@unit.id}/slots/#{i}", slot || '---'
  %br

@@ units_slots
= @unit.name
%br
%p #{@unit.name}の slots ##{@slot_idx}
- @unit.skills.each.with_index do |slot, i|
  = link_to "/api.unit_slot_set/#{@unit.id}/#{@slot_idx}/#{i}", slot
  %br
