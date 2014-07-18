require 'spec_helper'
require 'app/data/data_presenter.rb'
include BrattyPack

describe 'DataPresenter' do
  # note: not stubbing this out
  let(:service_name){ 'instagram' }
  let(:model_name){ 'user' }
  let(:data_obj){ get_fixture('instagram-user.json')}
  let(:presenter){ DataPresenter.new(service_name, model_name)}
  let(:config){ DataPresenter.load_config(service_name, model_name) }

  describe '.load_config' do
    it 'returns a Hash' do
      expect(config).to be_a Hash
    end
  end


  describe '.initialize' do
    it 'has reader attrs for all the arguments' do
      expect(presenter.service_name).to eq service_name
      expect(presenter.model_name).to eq model_name
    end

    describe '#column_names' do
      it 'is the same as the field names in the config file' do
        expect(presenter.column_names).to eq(config[:fields].map{|f| f[:name]} )
      end
    end
  end

  context 'parsing' do
    let(:data){ presenter.create_presentable_objects(data_obj) }
    describe '#data' do
      it 'is a delegate to Hash' do
        expect(data.to_h).to be_a Hash
      end

      # not very stubby
      context 'flat fields' do
        it 'has equivalent flat field values' do
          expect(data['id']).to eq data_obj['id']
        end
      end

      context 'path fields' do
        it 'correctly gets nested values' do
          expect(data['media_count']).to eq data_obj['counts']['media']
        end
      end
    end
  end
end
