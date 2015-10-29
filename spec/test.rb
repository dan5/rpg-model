require 'fileutils'
require './lib/rpg_model.rb'
require './master/master.rb'

describe do
  attr_reader :api, :user

  before do
    FileUtils.rm_rf('data.spec')
    RpgModel::User.dir_base = 'data.spec'
  end

  before do
    @api = RpgModel::Api.new(master, 'testman')
    @user = api.user
  end
  
  describe 'api.user' do
    it do
      expect(user.name).to eq 'testman'
      expect(user.units.size).to eq 3
      expect(user.new_units.size).to eq 0
    end
  end

  describe 'unit' do
    attr_reader :unit

    before do
      @unit = user.units.values.first
    end

    it do
      expect(unit.name).to be_kind_of String
      expect(unit.slots).to be_kind_of Array
      expect(unit.skills).to be_kind_of Array
    end
  end

  describe 'api.trial_battle' do
    before do
      trial_name = master[:trials].keys.first
      @r = api.trial_battle(trial_name)
    end

    it do
      expect(@r.status).to eq :ok
    end
  end
  
  describe 'api.unit_name' do
    before do
      @unit = user.units.values.first
      api.unit_name @unit.id, 'new name'
    end

    it do
      expect(@unit.name).to eq 'new name'
    end
  end

  describe 'api.unit_slot_set' do
    before do
      @unit = user.units.values.first
      api.unit_slot_set @unit.id, 0, 0
    end

    it do
      expect(@unit.slots.first).to eq @unit.skills.first
    end
  end

  describe 'api.unit_remove' do
    before do
      @un = user.units.size
      api.unit_remove user.units.values.first.id
    end

    it do
      expect(user.units.size).to eq @un - 1
    end
  end

  describe 'api.unit_recruit' do
    before do
      @nn = user.new_units.size
      api.unit_recruit
    end

    it do
      expect(user.new_units.size).to eq @nn + 3
    end

    describe 'api.unit_join' do
      before do
        @nn = user.new_units.size
        @un = user.units.size
        api.unit_join user.new_units.values.first.id
      end

      it do
        expect(user.new_units.size).to eq @nn - 1
        expect(user.units.size).to eq @un + 1
      end
    end
  end
end
