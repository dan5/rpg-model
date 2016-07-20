module RpgModel
  class Api
    class Result < OpenStruct
    end

    attr_reader :master, :user

    def initialize(master, login)
      @master = master
      @manager = Manager.new(master, login)
      @user = @manager.user
    end

    def unit_name(unit_id, name)
      user.units[unit_id].name = name
    end

    def unit_slot_set(unit_id, slot_idx, skill_idx)
      u = user.units[unit_id]
      u.set_slot slot_idx, skill_idx
      u.save
    end

    def unit_remove(unit_id)
      u = user.units[unit_id]
      user.delete_unit u.id
    end

    def unit_recruit
      3.times { user.create_new_unit }
    end

    def unit_join(new_unit_id)
      n = user.new_units[new_unit_id]
      user.create_unit# todo: n
      user.delete_new_unit n.id
    end

    def unit_swap_order(id0, id1)
      a = user.units[id0]
      b = user.units[id1]
      a.order_index, b.order_index = b.order_index, a.order_index
      if (a.order_index <= 9 and b.order_index > 9) or (b.order_index <= 9 and a.order_index > 9)
        a.position_index, b.position_index = b.position_index, a.position_index
      end
      a.save
      b.save
    end

    def unit_swap_position(id0, id1)
      a = user.units[id0]
      b = user.units[id1]
      a.position_index, b.position_index = b.position_index, a.position_index
      a.save
      b.save
    end

    def trial_battle(name)
      trial = Trial.new(master[:trials][name]) # todo: 毎回生成で良い？
      r = Result.new(status: :ok, logs: battle, trial: trial)
      user.trial_finish name if true
      user.save
      r
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
