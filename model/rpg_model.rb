load 'model/basic_model.rb'

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
    ids = unit_ids
    ids = %w(1 2 3) if ids.empty?
    ids.each do |unit_id|
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

  class BattleUnit
    def initialize(org)
      %w(name lv hp abilities slots).each do |k|
        instance_variable_set "@#{k}", org.__send__(k)
        self.class.__send__ :attr_reader, k
      end
      @max_hp = @hp
    end

    def act
      skill = slots.sample
      skill
    end
  end

  def battle_unit
    BattleUnit.new self
  end
end

def dice(n, t = 1)
  Array.new(t) { rand(n) + 1 }.inject :+
end

def battle
  logs = []
  units = @units.values.map(&:battle_unit)
  units.each do |u|
    logs << "#{u.name}: -#{u.act}-アクションを実行"
  end
  logs
end
