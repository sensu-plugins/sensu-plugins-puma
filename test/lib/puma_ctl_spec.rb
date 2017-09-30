require_relative '../spec_helper'
require 'sensu-plugins-puma/puma_ctl'

require 'socket'

describe PumaCtl do
  subject(:puma_ctl) { PumaCtl.new(state_file: state_file_path, control_auth_token: control_auth_token, control_url: control_url) }
  let(:control_auth_token) { nil }
  let(:control_url) { nil }
  let(:state_file_path) { File.join(File.dirname(__FILE__), "../support/v#{version}.state") }
  let(:version) { nil }

  context 'configuration' do
    context 'with control options' do
      let(:control_auth_token) { '123' }
      let(:control_url) { 'unix:///some/path' }

      it 'accepts a `control_auth_token`' do
        expect(puma_ctl.control_auth_token).to eq('123')
      end

      it 'accepts a `control-url` option' do
        expect(puma_ctl.control_url).to eq('unix:///some/path')
      end
    end

    context 'with a < v3.0.0 state file' do
      let(:version) { '2x' }

      it 'parses correctly' do
        expect(puma_ctl.control_auth_token).to eq('abcde')
        expect(puma_ctl.control_url).to eq('unix:///app/pumactl.sock')
      end
    end

    context 'with a >= v3.0.0 state file' do
      let(:version) { '3x' }

      it 'parses correctly' do
        expect(puma_ctl.control_auth_token).to eq('123456')
        expect(puma_ctl.control_url).to eq('unix:///app/pumactl.sock')
      end
    end
  end

  describe '#gc_stats' do
    let(:control_auth_token) { '123' }
    let(:state_file_path) { nil }
    let(:socket) { spy('socket') }

    before do
      allow(socket).to receive(:read).and_return(%( HTTP\/1.1 200 OK\r\n{"heap_used": 1516}))
      allow(Socket).to receive(:tcp).and_yield(socket)
      allow(Socket).to receive(:unix).and_yield(socket)
    end

    context 'with a TCP control url' do
      let(:control_url) { 'tcp://192.1.1.25:9191' }

      it 'connects to the TCP socket' do
        puma_ctl.gc_stats
        expect(Socket).to have_received(:tcp).with('192.1.1.25', '9191')
      end

      it 'sends the correct command to the control server' do
        expect(socket).to receive(:print).with("GET /gc-stats?token=#{control_auth_token} HTTP/1.0\r\n\r\n")
        puma_ctl.gc_stats
      end

      it 'returns the JSON socket response as a hash' do
        expect(puma_ctl.gc_stats).to eq('heap_used' => 1516)
      end

      context 'when `gc-stats` is not supported' do
        before do
          allow(socket).to receive(:print)
        end

        it 'raises an error' do
          allow(socket).to receive(:read).and_return("HTTP/1.0 404 Not Found\r\nContent-Type: text/plain\r\nContent-Length: 18\r\n\r\nUnsupported action")
          expect { puma_ctl.gc_stats }.to raise_error(PumaCtl::UnknownCommand, 'gc-stats')
        end
      end
    end

    context 'with a UNIX socket control url' do
      let(:control_url) { 'unix:///some/path' }

      it 'connects to the socket' do
        puma_ctl.gc_stats
        expect(Socket).to have_received(:unix).with('/some/path')
      end

      it 'sends the correct command to the control server' do
        expect(socket).to receive(:print).with("GET /gc-stats?token=#{control_auth_token} HTTP/1.0\r\n\r\n")
        puma_ctl.gc_stats
      end

      it 'returns the JSON socket response as a hash' do
        expect(puma_ctl.gc_stats).to eq('heap_used' => 1516)
      end

      context 'when `gc-stats` is not supported' do
        before do
          allow(socket).to receive(:print)
        end

        it 'raises an error' do
          allow(socket).to receive(:read).and_return("HTTP/1.0 404 Not Found\r\nContent-Type: text/plain\r\nContent-Length: 18\r\n\r\nUnsupported action")
          expect { puma_ctl.gc_stats }.to raise_error(PumaCtl::UnknownCommand, 'gc-stats')
        end
      end
    end
  end

  describe '#stats' do
    let(:control_auth_token) { '123' }
    let(:state_file_path) { nil }
    let(:socket) { spy('socket') }

    before do
      allow(socket).to receive(:read).and_return(%( HTTP\/1.1 200 OK\r\n{"running": 0}))
      allow(Socket).to receive(:tcp).and_yield(socket)
      allow(Socket).to receive(:unix).and_yield(socket)
    end

    context 'with a TCP control url' do
      let(:control_url) { 'tcp://192.1.1.25:9191' }

      it 'connects to the TCP socket' do
        puma_ctl.stats
        expect(Socket).to have_received(:tcp).with('192.1.1.25', '9191')
      end

      it 'sends the correct command to the control server' do
        expect(socket).to receive(:print).with("GET /stats?token=#{control_auth_token} HTTP/1.0\r\n\r\n")
        puma_ctl.stats
      end

      it 'returns the JSON socket response as a hash' do
        expect(puma_ctl.stats).to eq('running' => 0)
      end
    end

    context 'with a UNIX socket control url' do
      let(:control_url) { 'unix:///some/path' }

      it 'connects to the socket' do
        puma_ctl.stats
        expect(Socket).to have_received(:unix).with('/some/path')
      end

      it 'sends the correct command to the control server' do
        expect(socket).to receive(:print).with("GET /stats?token=#{control_auth_token} HTTP/1.0\r\n\r\n")
        puma_ctl.stats
      end

      it 'returns the JSON socket response as a hash' do
        expect(puma_ctl.stats).to eq('running' => 0)
      end
    end
  end
end
