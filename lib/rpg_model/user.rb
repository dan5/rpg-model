require './lib/rpg_model/basic_model.rb'

class RpgModel
  class User < BasicModel
    attr_reader :units, :new_units

    def initialize(id, manager)
      super
      params = {
        name: id,
        gold: 100 + dice(100),
      }
      default_params params
      init_units
      init_new_units
    end

    def init_new_units
      @new_units = scope { NewUnit.all @manager }
    end

    def create_new_unit
      unit_id = ((scope { NewUnit.ids }.map(&:to_i).max or 0) + 1).to_s
      @new_units[unit_id] = scope { NewUnit.new(unit_id, self).save }
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
