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

  n = user.new_units.size
  api.unit_recruit
  it { expect(user.new_units.size).to eq n + 3 }
end
