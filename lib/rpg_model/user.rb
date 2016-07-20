require './lib/rpg_model/basic_model.rb'

module RpgModel
  class User < BasicModel
    attr_reader :units, :new_units

    def initialize(id, manager)
      super
      params = {
        name: id,
        gold: 100 + dice(100),
        trials: [],
      }
      default_params params
      init_units
      init_new_units
    end

    def init_units
      @units = scope { Unit.all @manager }
      13.times { create_unit } if @units.empty?
    end

    def create_unit
      u = scope { Unit.create @manager }
      u.order_index = @units.size + 1
      u.position_index = @units.size + 1
      u.save
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
      @new_units[new_unit_id].destroy
      @new_units.delete new_unit_id
    end

    def trial_finish(trial_name)
      @trials << trial_name
    end
  end
end
