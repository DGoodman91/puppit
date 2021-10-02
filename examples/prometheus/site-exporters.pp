class { 'prometheus::exporter::node':
  version         => '1.1.2',
  prometheus_host => '127.0.0.1',
}

# since this is a defined type rather than a class, we include two of the resource to ensure that's supported
prometheus::exporter::jmx { 'jmx exporter':
  version         => '0.15.0',
  prometheus_host => '192.168.2.63',
  jar_location    => '/home/prometheus',
  config_location => '/home/prometheus'
}
prometheus::exporter::jmx { 'jmx exporter 2':
  version         => '0.15.0',
  prometheus_host => '192.168.2.63',
  listening_port  => 9102,
}
