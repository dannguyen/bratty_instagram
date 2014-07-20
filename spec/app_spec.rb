require 'spec_helper'


describe 'my first test' do

  describe 'helpers' do
    subject{
      (Class.new { include BrattyPack::Helpers::ApplicationHelper }).new
    }

    describe 'clean_text_field' do
      it 'should split commas and strip whitespace' do
        str = 'hey, you,guys  '
        expect(subject.process_text_input_array(str)).to eq %w(hey you guys)
      end

      it 'should split newlines and strip whitespace' do
        str = "hey there
        you
        guys"
        expect(subject.process_text_input_array(str)).to eq ['hey there', 'you', 'guys']
      end

      it 'should not split by commas if newlines are in place' do
        str = "hey,there
           you,guys    "

        expect(subject.process_text_input_array(str)).to eq ['hey,there', 'you,guys']
      end
    end
  end
end
