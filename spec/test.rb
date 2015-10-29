require './lib/rpg_model.rb'
load 'master/master.rb'

describe 'rpg-model' do
  api = RpgModel.new(master, 'testman').api
  user = api.user
  unit = user.units.values.first

  api.unit_name unit.id, 'new name'
  it { expect(unit.name).to eq 'new name' }

  trial_name = master[:trials].keys.first
  it 'trial_battle' do
    r = api.trial_battle(trial_name)
    expect(r.status).to eq :ok
  end
end

describe 'ゲーム基本フロー' do
  api = RpgModel.new(master, 'testman').api
  user = api.user
  unit = user.units.values.first
  #new_unit = user.new_units.first

  api.unit_slot_set unit.id, 0, 0

  it 'api.unit_recruit' do
    nn = user.new_units.size
    api.unit_recruit
    expect(user.new_units.size).to eq nn + 3
  end

  it 'api.unit_join' do
    nn = user.new_units.size
    un = user.units.size
    api.unit_join user.new_units.values.first.id
    expect(user.new_units.size).to eq nn - 1
    expect(user.units.size).to eq un + 1
  end

  it 'api.unit_remove' do
    un = user.units.size
    api.unit_remove user.units.values.first.id
    expect(user.units.size).to eq un - 1
  end

  it 'delete all units' do
    user.new_units.each {|id, u| api.unit_join u.id }
    user.units.each {|id, u| api.unit_remove u.id }
    expect(user.new_units.size).to eq 0
    expect(user.units.size).to eq 0
  end
end
