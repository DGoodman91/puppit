# @summary Install, configure and run the Prometheus node_exporter
#
# Install, configure and run the Prometheus node_exporter 
#
# @param version
#   The version of the Prometheus Node Exporter to download and install
#
# @param prometheus_host
#   The address of the Prometheus server. The firewall port for the Node Exporter will be opened up to this address.
#
# @example
#   class { 'prometheus::exporter::node':
#     version => '1.1.2',
#     prometheus_host => '192.168.2.63',
#   }
#
class prometheus::exporter::node (
  String $version,
  String $prometheus_host,
) {

  include prometheus::utils::user

  # download the node exporter binary
  file { "/home/prometheus/node_exporter-${version}.linux-amd64.tar.gz":
    ensure => file,
    source => "https://github.com/prometheus/node_exporter/releases/download/v${version}/node_exporter-${version}.linux-amd64.tar.gz",
    owner  => 'prometheus',
    group  => 'prometheus',
    mode   => '0644',
  }

  # extract the binaries from the tar we just downloaded
  exec { 'extract_node_exporter':
    cwd     => '/home/prometheus',
    user    => 'prometheus',
    command => "/bin/tar zxvf node_exporter-${version}.linux-amd64.tar.gz",
    require => File["/home/prometheus/node_exporter-${version}.linux-amd64.tar.gz"],
    creates => "/home/prometheus/node_exporter-${version}.linux-amd64/node_exporter",
  }

  # manage the node-exporter service
  if $facts['virtual'] != 'docker' {

    # add the service definition file
    # uses local value $version
    file { 'node-exporter-service-definition':
      path    => '/etc/systemd/system/node-exporter.service',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('prometheus/node-exporter.service.erb'),
      notify  => Exec['daemon_reload_register_node_exporter'],
    }

    # refresh the daemon list after adding service def
    exec { 'daemon_reload_register_node_exporter':
      cwd         => '/',
      command     => '/usr/bin/systemctl daemon-reload',
      refreshonly => true,
    }

    -> service { 'node-exporter':
      ensure  => running,
      enable  => true,
      require => File['node-exporter-service-definition'],
    }

    # open the port to allow scraping of the node_exporter
    firewalld_rich_rule { 'Open port 9100 (Node Exporter) up to the Prometheus server':
      ensure => present,
      zone   => 'public',
      source => "${prometheus_host}/32",
      port   => {
        'port'     => 9100,
        'protocol' => 'tcp',
      },
      action => 'accept',
    }

  } else {
    service { 'node-exporter':
      ensure  => running,
      enable  => true,
      start   => "/usr/bin/nohup sudo -u prometheus /home/prometheus/node_exporter-${version}.linux-amd64/node_exporter > nohup.out 2> nohup.err < /dev/null &",
      restart => "/usr/bin/nohup sudo -u prometheus /home/prometheus/node_exporter-${version}.linux-amd64/node_exporter > nohup.out 2> nohup.err < /dev/null &",
      #stop    => 'source /etc/rc.d/init.d/functions && killproc node_exporter'
    }
  }



}
