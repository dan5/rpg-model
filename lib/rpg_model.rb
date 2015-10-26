require 'yaml'

#$LOAD_PATH << 'lib'
load 'lib/rpg_model/basic_model.rb'
load 'lib/rpg_model/user.rb'
load 'lib/rpg_model/unit.rb'
load 'lib/rpg_model/battle.rb'

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
    begin
      @user = User.load(login)
    rescue Errno::ENOENT
      @user = User.new(login)
      @user.save
    end
    @units = @user.units
  end

  # API
  def unit_name(unit_id, name)
    @units[unit_id].name = name
  end
end
