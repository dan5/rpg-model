require './lib/rpg_model/basic_model.rb'

class RpgModel
  class User < BasicModel
    attr_reader :units

    def initialize(id, manager)
      super
      params = {
        name: id,
        gold: 100 + dice(100),
      }
      default_params params
      init_units
    end

    def init_units
      @units = {}
      ids = scope { Unit.ids }
      ids = %w(1 2 3) if ids.empty?
      ids.each do |unit_id|
        @units[unit_id] = create_unit(unit_id)
      end
    end

    def create_unit(unit_id)
      scope { Unit.load unit_id, self }
    rescue Errno::ENOENT
      scope { Unit.new(unit_id, self).save }
    end
  end
end
