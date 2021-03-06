require_relative '../spec_helper'
require_relative '../../bin/metrics-puma'
require 'pry'

class PumaMetrics
  at_exit do
    # rubocop:disable Style/ClassVars
    @@autorun = false
    # rubocop:enable Style/ClassVars
  end

  def ok(*)
    'ok'
  end
end

describe PumaMetrics do
  subject(:metric) { PumaMetrics.new(args) }
  let(:args) {}

  before do
    allow(metric).to receive(:output)
    allow(metric).to receive(:unknown)
  end

  context 'with options' do
    let(:args) { %w(--state-file /some/file.state --auth-token 123 --control-url unix:///some/path) }

    it 'correctly instantiates a PumaCtl instnace' do
      # poor test
      expect(PumaCtl).to receive(:new).with(state_file: '/some/file.state', control_auth_token: '123', control_url: 'unix:///some/path')
      metric.puma_ctl
    end
  end

  describe '#run' do
    let(:args) { %W(--scheme test --auth-token 123 --control-url unix:///path #{additional_args}) }
    let(:additional_args) { '' }
    let(:puma_ctl) { metric.puma_ctl }
    let(:stats_output) { {} }
    let(:gc_stats_output) { {} }

    before do
      allow(puma_ctl).to receive(:stats) { stats_output }
      allow(puma_ctl).to receive(:gc_stats) { gc_stats_output }
      metric.run
    end

    context 'gathering stats' do
      context 'with one worker' do
        let(:stats_output) { { 'backlog' => 1, 'running' => 2 } }

        it 'outputs the correct stats' do
          expect(metric).to output('test.backlog', 1)
          expect(metric).to output('test.running', 2)
        end
      end

      context 'with multiple workers' do
        let(:stats_output) do
          {
            'workers' => 2,
            'phase' => 0,
            'booted_workers' => 2,
            'old_workers' => 0,
            'worker_status' => [
              {
                'pid' => 4122,
                'index' => 1,
                'phase' => 0,
                'booted' => true,
                'last_checkin' => '2017-08-23T01:44:00Z',
                'last_status' => { 'backlog' => 0, 'running' => 2 }
              },
              {
                'pid' => 4126,
                'index' => 0,
                'phase' => 0,
                'booted' => true,
                'last_checkin' => '2017-08-23T01:44:01Z',
                'last_status' => { 'backlog' => 1, 'running' => 1 }
              }
            ]
          }
        end

        it 'outputs the main stats' do
          expect(metric).to output('test.workers', 2)
          expect(metric).to output('test.phase', 0)
          expect(metric).to output('test.booted_workers', 2)
          expect(metric).to output('test.old_workers', 0)
        end

        it 'outputs the stats for each worker' do
          expect(metric).to output('test.worker.1.pid', 4122)
          expect(metric).to output('test.worker.1.phase', 0)
          expect(metric).to output('test.worker.1.booted', true)
          expect(metric).to output('test.worker.1.last_checkin', 1_503_452_640)
          expect(metric).to output('test.worker.1.backlog', 0)
          expect(metric).to output('test.worker.1.running', 2)

          expect(metric).to output('test.worker.0.pid', 4126)
          expect(metric).to output('test.worker.0.phase', 0)
          expect(metric).to output('test.worker.0.booted', true)
          expect(metric).to output('test.worker.0.last_checkin', 1_503_452_641)
          expect(metric).to output('test.worker.0.backlog', 1)
          expect(metric).to output('test.worker.0.running', 1)
        end

        it 'outputs the worker stats according to their index' do
          expect(metric).to output('test.worker.0.pid', 4126)
          expect(metric).to output('test.worker.1.pid', 4122)
        end

        it 'outputs the aggregated backlog and running stats' do
          expect(metric).to output('test.backlog', 1)
          expect(metric).to output('test.running', 3)
        end
      end
    end

    context 'gathering gc stats' do
      let(:gc_stats_output) { { 'heap_used' => 1516, 'heap_length' => 1519 } }

      context 'without the `--gc-stats` flag' do
        it 'does not try to gather gc stats' do
          expect(puma_ctl).to_not have_received(:gc_stats)
        end
      end

      context 'with the `--gc-stats` flag' do
        let(:additional_args) { '--gc-stats' }

        it "outputs the gc stats with a 'gc' prefix" do
          expect(metric).to output('test.gc.heap_used', 1516)
          expect(metric).to output('test.gc.heap_length', 1519)
        end
      end
    end
  end

  describe '#run with `--gc-stats` flag unsupported' do
    let(:args) { %W(--scheme test --auth-token 123 --control-url unix:///path #{additional_args}) }
    let(:additional_args) { '--gc-stats' }
    let(:puma_ctl) { metric.puma_ctl }

    before do
      allow(puma_ctl).to receive(:stats).and_return({})
      allow(puma_ctl).to receive(:gc_stats).and_raise(PumaCtl::UnknownCommand)
      metric.run
    end

    it 'emits "unknown"' do
      expect(metric).to have_received(:unknown).with('Control server does not support the `gc-stats` command')
    end
  end

  RSpec::Matchers.define :output do |key, val|
    match do |metric|
      expect(metric).to have_received(:output).with(key, val, instance_of(Fixnum))
    end
  end
end
