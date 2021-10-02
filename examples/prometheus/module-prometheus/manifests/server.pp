# @summary Install, configure and run the Prometheus service
#
# Install, configure and run the Prometheus service
#
# @param version
#   The version of Prometheus server to download and install
#
# @param data_dir
#   The location of the Prometheus data directory
#
# @param static_node_targets
#   The addressable hostnames or ip addresses and ports of the static node exporters to scrape. Default []
#
# @param static_jmx_targets
#   The addressable hostnames or ip addresses and ports of the static jmx exporters to scrape. Default []
#
# @example
#   class { 'prometheus::server':
#     version             => '2.27.1',
#     data_dir            => '/data',
#     static_node_targets => [
#       "localost:9100",
#       "192.168.2.90:9100"
#     ],
#     static_jmx_targets  => [
#       "192.168.2.15:9101"
#     ]
#   }
#
class prometheus::server (
  String $version,
  String $data_dir,
  Array[String] $static_node_targets = [],
  Array[String] $static_jmx_targets = [],
) {

  class { 'prometheus::server::install':
    version  => $version,
    data_dir => $data_dir,
  }

  class { 'prometheus::server::config':
    static_node_targets => $static_node_targets,
    version             => $version,
    static_jmx_targets  => $static_jmx_targets,
  }

  class { 'prometheus::server::service':
    version  => $version,
    data_dir => $data_dir,
  }

  include prometheus::server::firewall

  # define the ordering relationships
  Class['prometheus::server::install'] -> Class['prometheus::server::config'] -> Class['prometheus::server::service']

}
