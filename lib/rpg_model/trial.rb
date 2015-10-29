module RpgModel
  class Trial
    attr_reader :master, :name, :text
  
    def initialize(master)
      @master = master
      @name = master[:name]
      @text = master[:text]
    end
  end
end
