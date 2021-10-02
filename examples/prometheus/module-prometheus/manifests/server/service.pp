# @summary Manage the Prometheus service - ensure it's enabled & running
#
# Manage the Prometheus service - ensure it's enabled & running
#
# @param version
#   The version of Prometheus to download and install
#
# @param data_dir
#   The location of the Prometheus data directory
#
# @example
#   class { 'prometheus::server::service':
#     version  => '2.27.1',
#     data_dir => '/data',
#   }
#
class prometheus::server::service (
  String $version,
  String $data_dir,
) {

  # manage the prometheus service
  if $facts['virtual'] != 'docker' {
    service { 'prometheus':
      ensure => running,
      enable => true,
    }
  } else {
    service { 'prometheus':
      ensure  => running,
      enable  => true,
      start   => "/usr/bin/nohup sudo -u prometheus /home/prometheus/prometheus-${version}.linux-amd64/prometheus \
  --config.file=/home/prometheus/prometheus-${version}.linux-amd64/prometheus.yml --web.listen-address=127.0.0.1:9090\
  --storage.tsdb.path=${data_dir} > nohup.out 2> nohup.err < /dev/null &",
      restart => "/usr/bin/nohup sudo -u prometheus /home/prometheus/prometheus-${version}.linux-amd64/prometheus \
  --config.file=/home/prometheus/prometheus-${version}.linux-amd64/prometheus.yml --web.listen-address=127.0.0.1:9090\
  --storage.tsdb.path=${data_dir} > nohup.out 2> nohup.err < /dev/null &",
      #stop    => 'source /etc/rc.d/init.d/functions && killproc prometheus'
    }
  }

}
