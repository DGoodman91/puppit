# @summary Builds the prometheus configuration
#
#
# @param version
#   The version of Prometheus server to download and install
#
# @param static_node_targets
#   The addressable hostnames or ip addresses and ports of the static node exporters to scrape. Default []
#
# @param static_jmx_targets
#   The addressable hostnames or ip addresses and ports of the static jmx exporters to scrape. Default []
#
# @example
#   class { 'prometheus::server::config':
#     version             => '2.27.1',
#     static_node_targets => [
#       "localost:9100",
#       "192.168.2.90:9100"
#     ],
#     static_jmx_targets  => [
#       "192.168.2.15:9101"
#     ]
#   }
#
class prometheus::server::config (
  String $version,
  Array[String] $static_node_targets = [],
  Array[String] $static_jmx_targets = [],
) {

  # deploy the main prometheus configuration file
  # uses local values $version, $static_node_targets, $static_jmx_targets
  file { 'prometheus-main-configuration':
    path    => "/home/prometheus/prometheus-${version}.linux-amd64/prometheus.yml",
    owner   => 'prometheus',
    group   => 'prometheus',
    mode    => '0644',
    content => template('prometheus/prometheus.yml.erb'),
    notify  => Service['prometheus'],
  }

}
