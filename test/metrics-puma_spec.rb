require_relative './spec_helper'
require_relative '../bin/metrics-puma'
require 'pry'

describe PumaMetrics do
  subject(:check) {PumaMetrics.new(args)}
  let(:args) {}
  let(:state_file_path) {File.join(File.dirname(__FILE__), "support/v#{version}.state")}


  context 'with options' do
    let(:args) {%w(--auth-token 123 --control-url unix:///some/path)}
    it 'accepts an `auth-token` option' do
      expect(check.control_auth_token).to eq('123')
    end

    it 'accepts a `control-url` option' do
      expect(check.control_url).to eq('unix:///some/path')
    end
  end

  context "with a < v3.0.0 state file" do
    let(:version) {'2x'}
    let(:args) {%W(--state-file #{state_file_path})}

    it "parses correctly" do
      expect(check.control_auth_token).to eq('abcde')
      expect(check.control_url).to eq('unix:///app/pumactl.sock')
    end
  end

  context "with a >= v3.0.0 state file" do
    let(:version) {'3x'}
    let(:args) {%W(--state-file #{state_file_path})}

    it "parses correctly" do
      expect(check.control_auth_token).to eq('123456')
      expect(check.control_url).to eq('unix:///app/pumactl.sock')
    end
  end

  describe '#run' do
  end
end
