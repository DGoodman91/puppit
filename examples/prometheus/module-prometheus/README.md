# prometheus

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with prometheus](#setup)
    * [What prometheus affects](#what-prometheus-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with prometheus](#beginning-with-prometheus)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

The module contains classes to install & manage the Prometheus & Grafana services, as well as the Node and JMX Exporters for Prometheus to scrape.

## Setup

### What prometheus affects

Installs, configures and runs the services, as well as opening applicable FirewallD rules to support them.

### Usage

To install the Prometheus & Grafana services use

```puppet
class { 'prometheus::server':
  version             => '2.27.1',
  data_dir            => '/data',
  static_node_targets => [
    "localost:9100",
    "192.168.2.90:9100"
  ],
  static_jmx_targets  => [
    "192.168.2.15:9101"
  ]
}

class { 'prometheus::grafana': }
```

To install the Node Exporter service use

```puppet
class { 'prometheus::exporter::node':
  version         => '1.1.2',
  prometheus_host => '192.168.2.63',
}
```

To install the JMX Exporter use

```puppet
prometheus::exporter::jmx { 'tomcat9A-jmx-exporter':
  version         => '0.15.0',
  prometheus_host => '192.168.2.63',
  listening_port  => 9101,
  config_location => '/usr/local/tomcat9A/conf',
  jar_location    => '/usr/local/tomcat9A/webapps',
}
```

## Limitations

Note that the Grafana class installs, configures & runs the *grafana* service, but does not configure it's data sources - it'll still need manually attaching to the *prometheus* data source.

## Development

The ::prometheus classes could do with tidying up to remove the duplicate.