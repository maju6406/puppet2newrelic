require 'puppet'
require 'puppet/util'
require 'fileutils'
require 'net/http'
require 'net/https'
require 'uri'
require 'yaml'
require 'json'
require 'time'

# rubocop:disable Style/ClassAndModuleCamelCase
# insights_util.rb
module Puppet::Util::Insights_util
  def settings
    return @settings if @settings
    @settings_file = Puppet[:confdir] + '/newrelic_insights.yaml'

    @settings = YAML.load_file(@settings_file)
  end

  def create_http
    insights_url = retrieve_insights_url
    @uri = URI.parse(insights_url)
    timeout = settings['timeout'] || '1'
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.open_timeout = timeout.to_i
    http.read_timeout = timeout.to_i
    http.use_ssl = @uri.scheme == 'https'

    http
  end

  def submit_request(body)
    http = create_http
    insights_key = settings['insights_key'] || raise(Puppet::Error, 'Must provide account_id parameter to New Relic class')
    req = Net::HTTP::Post.new(@uri.path.to_str)
    Puppet.info "insights_key: #{insights_key}"
    Puppet.info "account_id  : #{settings['account_id']}"
    req.add_field('X-Insert-Key', insights_key.to_s)
    req.add_field('Content-Type', 'application/json')
    req.content_type = 'application/json'
    req.body = body.to_json
    Puppet.info "Request Body: #{req.body}"
    response = http.request(req)
    Puppet.info "Response Code: #{response.code}"
    Puppet.info "Response Body: #{response.body}"
  end

  def store_event(event)
    host = event['host']
    epoch = event['time'].to_f

    timestamp = Time.at(epoch).to_datetime

    filename = timestamp.strftime('%F-%H-%M-%S-%L') + '.json'

    dir = File.join(Puppet[:reportdir], host)

    unless Puppet::FileSystem.exist?(dir)
      FileUtils.mkdir_p(dir)
      FileUtils.chmod_R(0o750, dir)
    end

    file = File.join(dir, filename)

    begin
      File.open(file, 'w') do |f|
        f.write(event.to_json)
      end
    rescue => detail
      Puppet.log_exception(detail, "Could not write report for #{host} at #{file}: #{detail}")
    end
  end

  private

  def retrieve_insights_url
    settings['account_id'] || raise(Puppet::Error, 'Must provide the New Relic Account ID')
    url = 'https://insights-collector.newrelic.com/v1/accounts/' + settings['account_id'] + '/events'
    url
  end

  def pe_console
    settings['pe_console'] || Puppet[:certname]
  end

  def record_event
    result = if settings['record_event'] == 'true'
               true
             else
               false
             end
    result
  end

  # standard function to make sure we're using the same time format our sourcetypes are set to parse
  def sourcetypetime(timestamp)
    time = Time.parse(timestamp)
    '%10.3f' % time.to_f
  end
end
