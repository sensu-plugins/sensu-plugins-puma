require 'json'
require 'socket'
require 'yaml'

class PumaCtl
  attr_reader :state_file

  def initialize(state_file: '/tmp/puma.state', control_auth_token: nil, control_url: nil)
    @state_file = state_file
    @control_auth_token = control_auth_token
    @control_url = control_url
  end

  def control_auth_token
    @control_auth_token ||= puma_options[:control_auth_token]
  end

  def control_url
    @control_url ||= puma_options[:control_url]
  end

  def puma_options
    @puma_options ||= begin
      return nil unless File.exist?(state_file)
      state = load_puma_state(state_file)

      if state.has_key?('config')
        # state is < v3.0.0
        opts = state['config']['options']
        {control_url: opts[:control_url], control_auth_token: opts[:control_auth_token]}
      else
        # state is >= v3.0.0
        {control_url: state['control_url'], control_auth_token: state['control_auth_token']}
      end
    end
  end

  def gc_stats
    send_socket_command('gc-stats')
  end

  def stats
    send_socket_command('stats')
  end

  private

  def control_socket
    type = nil
    args = []
    case control_url
    when /^unix:\/\//
      type = :unix
      args = [control_url.gsub('unix://', '')]
    when /^tcp:\/\//
      type = :tcp
      args = control_url.gsub('tcp://', '').split(':')
    else 
      return nil
    end

    Socket.send(type, *args) do |socket|
      yield socket
    end
  end

  def load_puma_state(path)
    raw = File.read(path)
    sanitized = raw.gsub(/!ruby\/object:.*$/, '')
    YAML.load(sanitized)
  end

  def send_socket_command(cmd)
    out = control_socket do |socket|
      socket.print("GET /#{cmd}?token=#{control_auth_token} HTTP/1.0\r\n\r\n")
      socket.read
    end
    JSON.parse(out.split("\r\n").last)
  end
end
