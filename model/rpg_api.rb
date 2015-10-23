load './model/rpg_model.rb'

def trial_battle(name)
  @trial = Trial.new(master[:trials][name])
  @logs = battle
end

def battle
  c = Battle::Controller.new [
    @units.values.map {|e| e.battle_unit 0 },
    @units.values.map {|e| e.battle_unit 1 }.map.with_index {|e, i| e.name = "ゴブリン#{i + 1}" ; e }, # todo
  ]
  c.act
  c.logs
end
