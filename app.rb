require 'haml'
require 'yaml'
require 'sinatra'
require 'sinatra/reloader' if development?

enable :sessions

helpers do
  def link_to(url, txt = url)
    %Q(<a href="#{url}">#{txt}</a>)   
  end

  def api() @api end
end

before do
  load './lib/rpg_model.rb'
  load './master/master.rb'
end

before /^(?!.*login).+$/ do
  if login = session[:login]
    @api = RpgModel.new(master, 'testman').api
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

get '/trials' do
  @trials = master[:trials].map {|name, e| Trial.new e }
  haml :trials
end

get '/trials/:name' do
  name = params[:name]
  @trial = RpgModel::Trial.new(master[:trials][name])
  haml :trials_show
end

get '/trials/:name/battle' do
  trial_battle(params[:name])
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

get '/units/:id/slots/:slot_idx/set/:skill_idx' do
  @unit = @units[params[:id]]
  api.unit_slot_set @unit.id, params[:slot_idx].to_i, params[:skill_idx].to_i
  redirect to "/units/#{@unit.id}"
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
    = link_to '/trials', 'trials'
    = '--'

@@ index
%p hello!!
= link_to "/units"
= link_to "/trials"
= link_to "/battle"

@@ battle
- @logs.each do |e|
  = e
  %br

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
- @units.each do |id, unit|
  = link_to "/units/#{id}", unit.name
  lv:#{unit.lv}
  exp:#{unit.exp}
  %br

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
  = link_to "/units/#{@unit.id}/slots/#{@slot_idx}/set/#{i}", slot
  %br
