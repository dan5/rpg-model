require './lib/rpg_model/user.rb'
require './lib/rpg_model/unit.rb'
require './lib/rpg_model/new_unit.rb'
require './lib/rpg_model/trial.rb'

class RpgModel
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
end
