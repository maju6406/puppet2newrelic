# Simple class to manage your new relic connectivity
# note if you manage enable_reports, it will default to puppetdb,puppet2newrelic
# if you wish to add other reports, you can do so with the reports param
class puppet2newrelic (
  String $account_id,
  String $insights_key,
  Boolean $enable_reports = false,
  String $reports = 'puppetdb,newrelic_insights',
) {

  if $enable_reports {
    pe_ini_setting {'enable newrelic_insights':
      ensure  => present,
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      section => 'master',
      setting => 'reports',
      value   => $reports,
      notify  => Service['pe-puppetserver'],
    }
  }

  file { '/etc/puppetlabs/puppet/newrelic_insights.yaml':
    ensure  => file,
    owner   => pe-puppet,
    group   => pe-puppet,
    mode    => '0640',
    content => epp('puppet2newrelic/newrelic_insights.yaml.epp'),
    notify  => Service['pe-puppetserver'],
  }
}
