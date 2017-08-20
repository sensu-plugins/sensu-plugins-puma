#! /usr/bin/env ruby
#
#   puma-metrics
#
# DESCRIPTION:
#   Pull puma metrics
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   #YELLOW
#
# NOTES:
#   Requires app to be running with --control auto --state "/tmp/puma.state"
#
# LICENSE:
#   Copyright 2014 Sonian, Inc. and contributors. <support@sensuapp.org>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'

require 'json'
require 'socket'
require 'yaml'

class PumaMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.puma"

  option :state_file,
         description: 'Puma state file',
         short: '-p STATE_FILE',
         long: '--state-file SOCKET',
         default: '/tmp/puma.state'

  option :control_auth_token,
         description: 'The auth token to connect to the control server with',
         long: '--auth-token TOKEN'

  option :control_url,
         description: 'The control_url the puma control server is listening on',
         long: '--control-url PATH'

  def control_auth_token
    @control_auth_token ||= (config[:control_auth_token] || puma_options[:control_auth_token])
  end

  def control_url
    @control_url ||= (config[:control_url] || puma_options[:control_url])
  end

  def puma_options
    @puma_options ||= begin
      return nil unless File.exist?(config[:state_file])
      state = load_puma_state(config[:state_file])

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

  def puma_stats
    stats = Socket.unix(control_url.gsub('unix://', '')) do |socket|
      socket.print("GET /stats?token=#{control_auth_token} HTTP/1.0\r\n\r\n")
      socket.read
    end

    JSON.parse(stats.split("\r\n").last)
  end

  def run
    puma_stats.map do |k, v|
      output "#{config[:scheme]}.#{k}", v
    end
    ok
  end

  private

  def load_puma_state(path)
    raw = File.read(path)
    sanitized = raw.gsub(/!ruby\/object:.*$/, '')
    YAML.load(sanitized)
  end
end
