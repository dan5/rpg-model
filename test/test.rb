require './lib/rpg_model.rb'

describe 'rpg-model' do
  m = RpgModel.new('testman')
  user = m.user
  unit = m.units.values.first
  # unit = user.units.first

  m.unit_name unit.id, 'new name'
  it { expect(unit.name).to eq 'new name' }
end
