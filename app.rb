require 'haml'
require 'yaml'
require 'sinatra'
require 'sinatra/reloader' if development?

def dice(n, t = 1)
  Array.new(t) { rand(n) + 1 }.inject :+
end

class BasicModel
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def default_params(params)
    params.each do |k, v|
      value = v.respond_to?(:call) ? v.call : v
      instance_variable_set "@#{k}", value
      self.class.__send__ :attr_reader, k
    end
    @default_params = params
  end

  def data_name
    "data/#{self.class.to_s.downcase}_#{@id or raise}"
  end

  def save
    values = {}
    @default_params.keys.each do |k|
      values[k] = instance_variable_get "@#{k}"
    end
    File.write data_name, values.to_yaml
    self
  end

  def load
    data = _load
    @default_params.keys.each do |k|
      if value = data[k]
        instance_variable_set("@#{k}", value)
      end
    end
    self
  end

  def _load
    YAML.load_file data_name
  end

  def self.load(id)
    new(id).load
  end
end

class User < BasicModel
  attr_reader :units

  def initialize(id)
    super id
    params = {
      name: id,
      gold: 100,
    }
    default_params params
    init_units
  end

  def init_units
    @units = {}
    unit_ids.each do |unit_id|
      @units[unit_id] = create_unit(unit_id)
    end
  end

  def unit_ids
    Dir.glob("data/unit_#{id}_*").map {|e| e.sub 'data/unit_', '' }
  end

  def create_unit(unit_id)
    Unit.load unit_id
  rescue Errno::ENOENT
    Unit.new(unit_id).save
  end
end

class Unit < BasicModel
  attr_reader :skills

  def initialize(id)
    super id
    params = {
      name: -> { %w(アベル カイン シーダ ドーガ ジェイガン).sample },
      lv: 1,
      exp: 0,
      abilities: -> { Array.new(6) { dice(6, 3) } },
      str: rand(20) + 1,
      slots: -> { Array.new(6) },
    }
    default_params params
    @skills = %w(攻撃 回復 防御)
  end

  def set_slot(idx, skill_idx)
    @slots[idx] = @skills[skill_idx]
  end
end

def battle
  logs = []
  @units.each do |k, e|
    logs << "#{k}: -#{e.slots.sample}-アクションを実行"
  end
  logs
end

enable :sessions

helpers do
  def link_to(url, txt = url)
    %Q(<a href="#{url}">#{txt}</a>)   
  end
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
