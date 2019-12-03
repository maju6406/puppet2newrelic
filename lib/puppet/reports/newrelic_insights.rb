require 'puppet/util/insights_util'

Puppet::Reports.register_report(:newrelic_insights) do
  desc 'Submits just a report summary to New Relic endpoint'
  # Next, define and configure the report processor.

  include Puppet::Util::Insights_util
  def process
    # now we can create the event with the timestamp from the report

    epoch = sourcetypetime(time.iso8601(3))

    # pass simple metrics for report processing later
    #  STATES = [:skipped, :failed, :failed_to_restart, :restarted, :changed, :out_of_sync, :scheduled, :corrective_change]
    metrics = {
      'time' => {
        'config_retrieval' => self.metrics['time']['config_retrieval'],
        'fact_generation' => self.metrics['time']['fact_generation'],
        'catalog_application' => self.metrics['time']['catalog_application'],
        'total' => self.metrics['time']['total'],
      },
      'resources' => {
        'total' => self.metrics['resources']['total'],
      },
      'changes' => {
        'total' => self.metrics['changes']['total'],
      },
    }

    event = {
      "eventType" => "PuppetEvent",
      'host' => host,
      'time' => epoch,
      'cached_catalog_status' =>  cached_catalog_status,
      'catalog_uuid' => catalog_uuid,
      'certname' => host,
      'code_id' => code_id,
      'configuration_version' => configuration_version,
      'corrective_change' => corrective_change,
      'environment' => environment,
      'job_id' => job_id,
      'noop' => noop,
      'noop_pending' => noop_pending,
      'pe_console' => pe_console,
      'producer' => Puppet[:certname],
      'puppet_version' => puppet_version,
      'report_format' => report_format,
      'status' => status,
      'transaction_uuid' => transaction_uuid,
      'metrics.time.config_retrieval' => metrics.time.config_retrieval,
      'metrics.time.fact_generation' => metrics.time.fact_generation,
      'metrics.time.catalog_application' => metrics.time.catalog_application,
      'metrics.time.total' => metrics.time.total,               
      'metrics.resources.total' => metrics.resources.total,               
      'metrics.changes.total' => metrics.changes.total,                           
    }

    Puppet.info "Submitting report to New Relic at #{get_insights_url()}"
    submit_request event
    if record_event
      store_event event
    end
  rescue StandardError => e
    Puppet.err "Could not send report to New Relic: #{e}\n#{e.backtrace}"
  end
end
