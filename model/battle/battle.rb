module Battle
  class Unit
    attr_accessor :manager

    def initialize(org)
      %w(name lv hp abilities slots).each do |k|
        instance_variable_set "@#{k}", org.__send__(k)
        self.class.__send__ :attr_reader, k
      end
      @max_hp = @hp
    end

    def act
      skill = Skill.new(slots.sample, self)
      skill.act
    end
  end

  class Skill
    def initialize(name, unit)
      @name = name || '硬直'
      @unit = unit
    end

    def act
      __send__ @name
    end

    def 攻撃
      'attack'
    end

    def 回復
      'heal'
    end

    def 防御
      '身を守る'
    end

    def 硬直
      'じっとしている'
    end
  end

  class Manager
    attr_reader :units
  
    def initialize(units)
      @units = units
    end
  
    def act
      logs = []
      @units.flatten.each do |u|
        logs << "#{u.name}: -#{u.act}-アクションを実行"
      end
      logs
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
