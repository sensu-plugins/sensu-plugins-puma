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
require 'sensu-plugins-puma'

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

  def puma_ctl
    @puma_ctl ||= PumaCtl.new(
      state_file: config[:state_file],
      control_auth_token: config[:control_auth_token],
      control_url: config[:control_url]
    )
  end

  def run
    timestamp = Time.now.to_i
    stats = puma_ctl.stats
    worker_status = stats.delete("worker_status")

    if worker_status
      stats = parse_worker_stats(stats, worker_status)
    end
    
    stats.map do |k, v|
      output "#{config[:scheme]}.#{k}", v, timestamp
    end
    ok
  end

  private
  def parse_worker_stats(stats, worker_status)
    backlog, running = 0, 0
    worker_status.each do |worker|
      idx = worker.delete("index")
      last_status = worker.delete("last_status")
      backlog += (worker["backlog"] = last_status["backlog"])
      running += (worker["running"] = last_status["running"])
      worker.map do |k, v|
        stats["worker.#{idx}.#{k}"] = v
      end
    end

    stats["backlog"] = backlog
    stats["running"] = running
    stats
  end
end
