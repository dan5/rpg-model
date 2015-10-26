require './lib/rpg_model/basic_model.rb'

class RpgModel
  class User < BasicModel
    attr_reader :units

    def initialize(id)
      super id
      params = {
        name: id,
        gold: 100 + dice(100),
      }
      default_params params
      init_units
    end

    def init_units
      @units = {}
      ids = unit_ids
      ids = %w(1 2 3) if ids.empty?
      ids.each do |unit_id|
        @units[unit_id] = create_unit(unit_id)
      end
    end

    def unit_ids
      Dir.glob("data/unit_#{id}_*").map {|e| e.sub 'data/unit_', '' }
    end

    def create_unit(unit_id)
      Unit.load unit_id
    rescue Errno::ENOENT
      Unit.new(unit_id).save
    end
  end
end
