require 'spec_helper'

describe Test do

  let(:out) { StringIO.new }

  before do
    $stdout = out
    $describing = true
    Test.class_variable_set '@@html', []
    Test.class_variable_set '@@failed', []
  end

  after { $stdout = STDOUT }

  describe '#log' do
    it 'should log messages with line breaks to stdout' do
      $describing = false
      expect(Test.log('a message')).to be_nil
      expect(out.string).to eq "a message\n"
      expect(Test.class_variable_get('@@html')).to eq([])
    end

    it 'should log messages with line breaks to @@html' do
      expect(Test.log('a message')).to be_nil
      expect(out.string).to eq ''
      expect(Test.class_variable_get('@@html')).to eq(
        ['a message', '<br>']
      )
    end

    it 'should log messages without line breaks to @@html' do
      expect(Test.log('a message', true)).to be_nil
      expect(Test.class_variable_get('@@html')).to eq(
        ['a message']
      )
    end
  end

  describe '#expect' do
    it 'should count the number of invocations' do
      Test.expect true, 'some message'
      expect(Test.class_variable_get('@@method_calls')).to eq({
        :expect => 1
      })
      Test.expect true, 'some message'
      Test.expect true, 'some message'
      expect(Test.class_variable_get('@@method_calls')).to eq({
        :expect => 3
      })
    end

    context 'when it succeeds' do
      it 'should log the success' do
        expect(Test.expect true, 'go on!', success_msg: 'Yeah!').to be_nil
        expect(Test.class_variable_get('@@html')).to eq([
          "<div class=\"console-passed\">Test Passed: Yeah!</div>"
        ])
      end

      it "should give prefer the block's outcome" do
        block = -> { true }
        expect(Test.expect false, 'go on!', success_msg: 'Yeah!', &block).to be_nil
        expect(Test.class_variable_get('@@html')).to eq([
          "<div class=\"console-passed\">Test Passed: Yeah!</div>"
        ])
      end
    end

    context 'when it fails' do
      it 'should log an error to @@failed' do
        expect(Test.expect false, 'boom!').to eq([
          Test::Error.new('boom!')
        ])
        expect(Test.class_variable_get('@@failed')).to eq([
          Test::Error.new('boom!')
        ])
        expect(Test.class_variable_get('@@html')).to eq([
          "<div class='console-failed'>Test Failed: boom!</div>"
        ])

        expect(Test.expect false, 'kaboom!', -> { false }).to eq([
          Test::Error.new('boom!'),
          Test::Error.new('kaboom!')
        ])
      end

      it 'should raise an error' do
        $describing = false
        expect { Test.expect false, 'boom!' }.to raise_error Test::Error, 'boom!'
        expect(out.string).to eq "<div class='console-failed'>Test Failed: boom!</div>\n"
        expect(Test.class_variable_get('@@failed')).to eq([])
      end

    end
  end

end
