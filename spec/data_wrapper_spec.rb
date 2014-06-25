require 'spec_helper'
require 'app/data/data_wrapper.rb'
include BrattyPack

describe 'DataWrapper' do
  # note: not stubbing this out
  let(:service_name){ 'instagram' }
  let(:model_name){ 'user' }
  let(:data_obj){ get_fixture('instagram-user.json')}
  let(:wrapper){ DataWrapper.new(service_name, model_name, data_obj)}


  describe '.load_config' do
    it 'returns a Hash' do
      expect(DataWrapper.load_config(service_name, model_name)).to be_a Hash
    end
  end


  describe '.initialize' do
    it 'has reader attrs for all the arguments' do
      expect(wrapper.service_name).to eq service_name
      expect(wrapper.model_name).to eq model_name
      expect(wrapper.original_data_object).to eq data_obj
    end
  end

  context 'instantiation' do
    let(:data){ wrapper.data }
    describe '#data' do
      it 'is a hash' do
        expect(data).to be_a Hash
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
