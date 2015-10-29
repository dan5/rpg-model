require 'yaml'
require 'ostruct'

require './lib/rpg_model/manager.rb'
require './lib/rpg_model/api.rb'
require './lib/rpg_model/battle.rb'

class RpgModel
  attr_reader :api

  def initialize(master, login)
    @manager = Manager.new(master, login)
    @api = Api.new(@manager)
  end
end

def dice(n, t = 1)
  Array.new(t) { rand(n) + 1 }.inject :+
end
