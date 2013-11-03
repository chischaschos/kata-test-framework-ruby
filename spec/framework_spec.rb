require 'spec_helper'

describe Test do

  let(:out) { StringIO.new }

  before do
    $stdout = out
    $describing = true
    Test.class_variable_set '@@html', []
    Test.class_variable_set '@@failed', []
    Test.class_variable_set '@@failed', []
    Test.class_variable_set '@@method_calls', {}
    Test.class_variable_set '@@before_blocks', []
    Test.class_variable_set '@@after_blocks', []
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

  describe '#describe' do
    specify do
      Test.describe 'A behavior' do
        puts 'Something happens here'
      end
    end
  end

  describe '#it' do
    Test.it 'should output a message' do
      puts 'Something happens here'
    end
  end

  describe '#before' do
    it 'should add a before block' do
      Test.before do
        puts 'A message'
      end
      expect(Test.class_variable_get '@@before_blocks').to have(1).item
    end
  end

  describe '#after' do
    it 'should add an after block' do
      Test.after do
        puts 'A message'
      end
      expect(Test.class_variable_get '@@after_blocks').to have(1).item
    end
  end

  describe '#expect_tests_to_pass' do
    specify do
      Test.expect_tests_to_pass 'A message' do
        puts 'Some message'
      end
    end
  end

  describe '#expect_tests_to_fail' do
    specify do
      Test.expect_tests_to_fail 'A message' do
        puts 'Some message'
      end
    end
  end

  describe '#expect_error' do
    specify do
      Test.expect_error 'Expecting an error' do
        puts 'What happened here'
      end
    end
  end

  describe '#expect_no_error' do
    specify do
      Test.expect_no_error 'Expecting an error' do
        puts 'What happened here'
      end
    end
  end

  describe '#assert_equals' do
    specify do
      Test.assert_equals 1, 1, 'They are the same'
    end
  end

  describe '#assert_not_equals' do
    specify do
      Test.assert_not_equals 1, 2, 'They are not the same'
    end
  end


end
