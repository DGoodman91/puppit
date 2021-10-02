# @summary Install, configure and run the Grafana service
#
# Install, configure and run the Grafana service
#
# @example
#   include prometheus::grafana
class prometheus::grafana {

  # install the grafana repo
  file { '/etc/yum.repos.d/grafana.repo':
    ensure  => file,
    path    => '/etc/yum.repos.d/grafana.repo',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('prometheus/grafana.repo.erb'),
    notify  => Exec['grafana-makecache']
  }

  -> exec { 'grafana-makecache':
    cwd         => '/',
    user        => 'root',
    command     => '/usr/bin/yum makecache fast',
    refreshonly => true,
  }

  -> package { 'grafana': }

  if $facts['virtual'] != 'docker' {

    service { 'grafana-server':
      ensure  => running,
      enable  => true,
      require => [ Package['grafana'] ],
    }

    # open the port to allow scraping of the node_exporter
    firewalld_port { 'Open port 3000 (Grafana webserver)':
      ensure   => present,
      zone     => 'public',
      port     => 3000,
      protocol => 'tcp',
    }

  }

}
