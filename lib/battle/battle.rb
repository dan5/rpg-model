module Battle
  class Skill
    attr_reader :logs

    def initialize(name, unit)
      @name = name || '硬直'
      @unit = unit
      @logs = []
    end

    def act
      __send__ @name
    end

    def 攻撃
      target = @unit.opp_units.sample
      d = dice(20)
      target.hp -= d
      log '攻撃', target.name, "ダメージ #{d}"
      log "#{target.name}を倒した" if target.dead?
    end

    def 回復
      target = @unit.own_units.sample
      d = dice(6)
      target.hp += d
      log '回復', target.name, "回復 #{d}"
    end

    def 防御
      log '身を守る'
    end

    def 硬直
      log 'じっとしている'
    end

    def log(*args)
      @logs += args
    end
  end

  class Unit
    attr_accessor :manager
    attr_reader :team_id

    def logs() @skill.logs end
    def dead?() !alive? end
    def alive?() hp > 0 end
    def opp_team_id() 1 - @team_id end

    def initialize(org, team_id)
      @team_id = team_id
      %w(name lv hp abilities slots).each do |k|
        instance_variable_set "@#{k}", org.__send__(k)
        self.class.__send__ :attr_accessor, k
      end
      @max_hp = @hp
    end

    def act
      @skill = Skill.new(slots.sample, self)
      @skill.act
    end

    def damage(v)
      @hp = [@hp - v, 0].max
    end

    def heal(v)
      @hp = [@hp + v, @max_hp].min
    end

    def own_units
      @manager.units[@team_id].select &:alive?
    end

    def opp_units
      @manager.units[opp_team_id].select &:alive?
    end
  end

  class Manager
    attr_reader :units
  
    def initialize(units)
      @units = units
      units.flatten.each {|u| u.manager = self }
    end
  
    def act
      logs = []
      20.times do
        _act(logs) and break
        logs << '--'
      end
      logs
    end

    def _act(logs)
      @units.flatten.each do |u|
        u.alive? or next
        u.act
        logs << "#{u.name}: #{u.logs.join(' » ')}"
        if u.opp_units.all?(&:dead?)
          logs << "#{u.name}達は勝利した！"
          return true
        end
      end
      false
    end
  end

  class Controller
    attr_reader :logs
  
    def initialize(units)
      @manager = Manager.new units
    end
  
    def act
      @logs = @manager.act
    end
  end
end
