require 'yaml'

require './lib/rpg_model/user.rb'
require './lib/rpg_model/unit.rb'
require './lib/rpg_model/battle.rb'

class RpgModel
  class Trial
    attr_reader :master, :name, :text
  
    def initialize(master)
      @master = master
      @name = master[:name]
      @text = master[:text]
    end
  end

  attr_reader :user, :units

  def initialize(master, login)
    @user =
      begin
        User.load(login)
      rescue Errno::ENOENT
        User.new(login).save
      end
    @units = @user.units_hash
  end

  # API
  def unit_name(unit_id, name)
    @units[unit_id].name = name
  end

  def trial_battle(name)
    @trial = Trial.new(master[:trials][name]) # todo: 毎回生成で良い？
    @logs = battle
  end
  
  # local methods --
  def battle
    c = Battle::Controller.new [
      @units.values.map {|e| e.battle_unit 0 },
      @units.values.map {|e| e.battle_unit 1 }.map.with_index {|e, i| e.name = "ゴブリン#{i + 1}" ; e }, # todo
    ]
    c.act
    c.logs
  end
end
