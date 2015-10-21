require 'haml'
require 'yaml'
require 'sinatra'
require 'sinatra/reloader' if development?

enable :sessions

helpers do
  def link_to(url, txt = url)
    %Q(<a href="#{url}">#{txt}</a>)   
  end
end

before do
  load './model/rpg_model.rb'
end

before /^(?!.*login).+$/ do
  if login = session[:login]
    if false
      @user = User.new(login)
      @user.save
    else
      @user = User.load(login)
    end
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
  @unit.set_slot params[:slot_idx].to_i, params[:skill_idx].to_i
  @unit.save
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
    = link_to '/units', 'list'
    = '--'

@@ index
%p hello!!
= link_to "/units"
= link_to "/battle"

@@ battle
- @logs.each do |e|
  = e
  %br

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
