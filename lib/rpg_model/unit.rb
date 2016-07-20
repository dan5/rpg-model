require './lib/rpg_model/basic_model.rb'

module RpgModel
  class Unit < BasicModel
    attr_reader :skills

    # 打撃 パワー 走 守 肩 魅
    def initialize(id, manager)
      super id, manager
      params = {
        name: -> { name_sample },
        atk: dice(220, 2),
        power: rand(40),
        abilities: -> { Array.new(4) { dice(6, 1) } },
        position: rand(9) + 1,
        order_index: 0,
        position_index: 0,
        str: rand(20) + 1,
        slots: -> { Array.new(6) },
      }
      default_params params
      @skills = %w(攻撃 回復 防御)
    end

    def set_slot(idx, skill_idx)
      @slots[idx] = @skills[skill_idx]
    end

    def battle_unit(team_id)
      Battle::Unit.new self, team_id
    end

    def name_sample
      File.read('player_names.txt').split(/\s/).sample
    end
  end
end
