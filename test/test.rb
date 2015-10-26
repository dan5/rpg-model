require './lib/rpg_model.rb'
load 'master/master.rb'

describe 'rpg-model' do
  m = RpgModel.new(master, 'testman')
  user = m.user
  unit = user.units.first

  m.unit_name unit.id, 'new name'
  it { expect(unit.name).to eq 'new name' }

  trial_name = master[:trials].keys.first
  m.trial_battle trial_name
end
