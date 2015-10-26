class RpgModel
  class Unit < BasicModel
    attr_reader :skills

    def initialize(id)
      super id
      params = {
        name: -> { %w(アベル カイン シーダ ドーガ ジェイガン).sample },
        lv: 1,
        exp: 0,
        hp: 10,
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

    def battle_unit(team_id)
      Battle::Unit.new self, team_id
    end
  end
end
