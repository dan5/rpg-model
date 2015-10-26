require 'yaml'

require './lib/rpg_model/user.rb'
require './lib/rpg_model/unit.rb'
require './lib/rpg_model/battle.rb'

class RpgModel
  class Trial
    attr_reader :master, :name, :text
  
    def initialize(master)
      @master = master
      @name = master[:name]
      @text = master[:text]
    end
  end

  attr_reader :user, :units

  def initialize(login)
    @user =
      begin
        User.load(login)
      rescue Errno::ENOENT
        User.new(login).save
      end
    @units = @user.units
  end

  # API
  def unit_name(unit_id, name)
    @units[unit_id].name = name
  end
end
