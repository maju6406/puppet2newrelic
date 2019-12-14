[![Build Status](https://travis-ci.org/maju6406/puppet2newrelic.svg?branch=master)](https://travis-ci.org/maju6406/puppet2newrelic)

# puppet2newrelic

A module that installs report processors capable of sending Puppet reports to New Relic.

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with puppet2newrelic](#setup)
    * [What puppet2newrelic affects](#what-puppet2newrelic-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet2newrelic](#beginning-with-puppet2newrelic)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

This module will install the `newrelic_insights` report handlers. It also contains Puppet code to manage all of the settings required by them.

## Setup

The report handlers can be set up manually or using the supplied puppet code:

### Manual Setup

To use this module you will need a couple of things, firstly your report handler of choice will need to be added to the `puppet.conf`:

```ini
reports = newrelic_insights,console,puppetdb
```

You will also need to create a `newrelic_insights.yaml` at you confdir (usually `/etc/puppetlabs/puppet`) that looks like this:
```yaml
---
"account_id": "9999999"
"insights_key": "NRII-Dq27pLP6mwdoSqLH1zZl4Fcyn0Nj4GTU"
```

### Automated setup

I have included a class that can do all of this for you:

**Class: puppet2newrelic**
 
It is important to note that this class requires a restart of the puppet server. This can be implemented with something like this:
 
```puppet
class { 'puppet2newrelic':
  account_id   => "9999999"
  insights_key => "NRII-Dq27pLP6mwdoSqLH1zZl4Fcyn0Nj4GTU"
  notify       => Service['pe-puppetserver'],
}
```

**Parameters**

*account_id*

Your New Relic Account ID

*insights_key*

Your New Relic Insights Key


## Release Notes/Contributors/Etc. **Optional**

0.1.0 Initial release
