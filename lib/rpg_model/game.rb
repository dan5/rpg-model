module RpgModel
  class Game < BasicModel
    attr_reader :name, :text
  
    # 打撃 パワー 走 守 肩 魅
    def initialize(id, manager)
      super id, manager
      params = {
        name: "game#{id}",
        slots: -> { Array.new(6) },
        logs: -> { [] }
      }
      default_params params
    end
  end
end
