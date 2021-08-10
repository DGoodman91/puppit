class { 'prometheus::server':
  version  => '2.27.1',
  data_dir => '/home/prometheus/data'
}
