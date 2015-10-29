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

    def init_units
      @units = scope { Unit.all @manager }
      3.times { create_unit } if @units.empty?
    end

    def create_unit
      u = scope { Unit.create @manager }
      @units[u.id] = u
    end

    def delete_unit(unit_id)
      @units[unit_id].destroy
      @units.delete unit_id
    end

    def init_new_units
      @new_units = scope { NewUnit.all @manager }
    end

    def create_new_unit
      u = scope { NewUnit.create @manager }
      @new_units[u.id] = u
    end

    def delete_new_unit(new_unit_id)
      u = @new_units[new_unit_id]
      u.destroy
      @new_units.delete u.id
    end
  end
end
