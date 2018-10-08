require 'spec_helper'

describe Overcommit::Hook::PreCommit::PhpMd do
  let(:config)  { Overcommit::ConfigurationLoader.default_configuration }
  let(:context) { double('context') }
  subject { described_class.new(config, context) }

  before do
    subject.stub(:applicable_files).and_return(['sample.php'])
  end

  context 'when php md exits successfully' do
    before do
      result = double('result')
      result.stub(:status).and_return(0)
      result.stub(:success?).and_return(true)
      result.stub(:stdout).and_return('')
      subject.stub(:execute).and_return(result)
    end

    it { should pass }
  end

  context 'when php md exits unsuccessfully' do
    before do
      # rubocop:disable Metrics/LineLength
      sample_output = [
        'src/FilesService.php:26	The class FilesService has 14 public methods. Consider refactoring FilesService to keep number of public methods under 10.',
        'src/FilesService.php:26	The class FilesService has an overall complexity of 80 which is very high. The configured complexity threshold is 50.',
      ].join("\n")
      # rubocop:enable Metrics/LineLength

      result = double('result')
      result.stub(:status).and_return(1)
      result.stub(:success?).and_return(false)
      result.stub(:stdout).and_return(sample_output)
      subject.stub(:execute).and_return(result)
    end

    it { should fail_hook }
  end
end
