require 'yaml'
require 'ostruct'

require './lib/rpg_model/manager.rb'
require './lib/rpg_model/battle.rb'
require './lib/api/api.rb'

def dice(n, t = 1)
  Array.new(t) { rand(n) + 1 }.inject :+
end
