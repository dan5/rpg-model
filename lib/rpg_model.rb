require 'yaml'
require 'ostruct'

load './lib/rpg_model/user.rb'
load './lib/rpg_model/unit.rb'
load './lib/rpg_model/battle.rb'

class RpgModel
  class Result < OpenStruct
  end

  class NewUnit < Unit
  end

  class Trial
    attr_reader :master, :name, :text
  
    def initialize(master)
      @master = master
      @name = master[:name]
      @text = master[:text]
    end
  end

  class Manager
    attr_reader :user

    def initialize(master, login)
      @user =
        begin
          User.load(login, self)
        rescue Errno::ENOENT
          User.new(login, self).save
        end
    end

    #def init_new_units
    #  @new_units = NewUnit.all
    #end

  end

  class Api
    attr_reader :user

    def initialize(manager)
      @manager = manager
      @user = manager.user
    end

    def unit_name(unit_id, name)
      user.units[unit_id].name = name
    end

    def unit_slot_set(unit_id, slot_idx, skill_idx)
      unit = user.units[unit_id]
      unit.set_slot slot_idx, skill_idx
      unit.save
    end

    # test: trial_battle(trial_name)
    def trial_battle(name)
      @trial = Trial.new(master[:trials][name]) # todo: 毎回生成で良い？
      Result.new status: :ok, logs: battle
    end

    # local methods --
    def battle
      c = Battle::Controller.new [
        user.units.values.map {|e| e.battle_unit 0 },
        user.units.values.map {|e| e.battle_unit 1 }.map.with_index {|e, i| e.name = "ゴブリン#{i + 1}" ; e }, # todo
      ]
      c.act
      c.logs
    end
  end

  attr_reader :api

  def initialize(master, login)
    @manager = Manager.new(master, login)
    @api = Api.new(@manager)
  end
end

def dice(n, t = 1)
  Array.new(t) { rand(n) + 1 }.inject :+
end
