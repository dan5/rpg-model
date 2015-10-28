class RpgModel
  class Api
    class Result < OpenStruct
    end

    attr_reader :master, :user

    def initialize(manager)
      @manager = manager
      @master = manager.master
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
end
