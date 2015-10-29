require 'yaml'
require 'ostruct'

load './lib/rpg_model/user.rb'
load './lib/rpg_model/unit.rb'
load './lib/rpg_model/api.rb'
load './lib/rpg_model/battle.rb'

class RpgModel
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
    attr_reader :master, :user

    def initialize(master, login)
      @master = master
      @user = create_user(login)
    end

    def create_user(login)
      User.load(login, self)
    rescue Errno::ENOENT
      User.new(login, self).save
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
