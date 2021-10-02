# @summary Manage application firewall rules required for Prometheus
#
# @example
#   include prometheus::server::firewall
class prometheus::server::firewall {

  if $facts['virtual'] != 'docker' {
    # open the port providing access to the Prometheus web console
    firewalld_port { 'Open port 9090 (Prometheus console) in the public zone':
      ensure   => present,
      zone     => 'public',
      port     => 9090,
      protocol => 'tcp',
    }
  }

}
