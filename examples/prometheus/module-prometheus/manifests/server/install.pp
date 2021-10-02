# @summary Installs Prometheus as a service
#
# Installs prometheus as a service
#
# @param version
#   The version of Prometheus to download and install
#
# @param data_dir
#   The location of the Prometheus data directory
#
# @example
#   class { 'prometheus::server::install':
#     version  => '2.27.1',
#     data_dir => '/data',
#   }
#
class prometheus::server::install (
  String $version,
  String $data_dir,
) {

  include prometheus::utils::user

  # download the binaries
  file { "/home/prometheus/prometheus-${version}.linux-amd64.tar.gz":
    ensure => file,
    source => "https://github.com/prometheus/prometheus/releases/download/v${version}/prometheus-${version}.linux-amd64.tar.gz",
    owner  => 'prometheus',
    group  => 'prometheus',
    mode   => '0644',
    notify => Exec['extract_prometheus'],
  }

  # extract the binaries from the tar we just downloaded
  -> exec { 'extract_prometheus':
    cwd     => '/home/prometheus',
    user    => 'prometheus',
    command => "/bin/tar zxvf prometheus-${version}.linux-amd64.tar.gz",
    require => File["/home/prometheus/prometheus-${version}.linux-amd64.tar.gz"],
    creates => "/home/prometheus/prometheus-${version}.linux-amd64/prometheus",
  }

  # manage the node-exporter service
  if $facts['virtual'] != 'docker' {

    # create the service definition file
    # uses local values $version, $data_dir
    file { 'prometheus-service-definition':
      path    => '/etc/systemd/system/prometheus.service',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('prometheus/prometheus.service.erb'),
      notify  => Exec['daemon_reload_register_prometheus'],
    }

    # refresh the daemon list after adding service def
    exec { 'daemon_reload_register_prometheus':
      cwd         => '/',
      command     => '/usr/bin/systemctl daemon-reload',
      refreshonly => true,
    }

  }

  # ensure the data directory exists
  file { $data_dir:
    ensure => 'directory',
    mode   => '0600',
    owner  => 'prometheus',
    group  => 'prometheus',
  }

}
