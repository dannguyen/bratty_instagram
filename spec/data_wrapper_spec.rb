require 'spec_helper'
require 'app/data/data_wrapper.rb'
include BrattyPack

describe 'DataWrapper' do
  it 'should say hello world' do
    expect('hello' + ' world').to eq 'hello world'
  end

  describe '.load_config' do
# note: not stubbing this out
    let(:service_name){ 'instagram' }
    let(:model_name){ 'user' }

    it 'returns a Hash' do
      expect(DataWrapper.load_config(service_name, model_name)).to be_a Hash
    end
  end
end
