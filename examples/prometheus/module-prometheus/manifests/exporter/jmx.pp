# @summary Download the JMX Exporter JAR and configures the firewall rules to support it.
#
# Download the JMX Exporter JAR and configures the firewall rules to support it. The JAR still needs wiring into JVMs separately.
#
# This defined type, when included multiple times, will only download a single copy of each version of the JMX Exporter JAR
# The JAR can be shared between multiple JVMs, which is supported by Java's Class Data Sharing feature (since J2SE 5.0)
#
# @param version
#   The version of the Prometheus JMX Exporter to download
#
# @param prometheus_host
#   The address of the Prometheus server. The firewall port for the Node Exporter will be opened up to this address.
#
# @param listening_port
#   The port which we intend the JMX exporter to listen on - this is used to open up the applicable firewall port to
#   the @prometheus_host address. Defaults to 9101
#
# @param jar_location
#   The location to download the JAR file to. This must be readable by the JVM services that require it.
#
# @param config_location
#   The location to place the configuration file. This must be readable by the JVM services that require it.
#
# @example
#   prometheus::exporter::jmx { 'JVM Exporter A':
#     version         => '0.15.0',
#     prometheus_host => '192.168.2.63',
#     listening_port  => 9101,
#   }
#
define prometheus::exporter::jmx (
  String $version,
  String $prometheus_host,
  Integer $listening_port = 9101,
  String $jar_location = '/home/prometheus',
  String $config_location = '/home/prometheus',
) {

  include prometheus::utils::user

  if defined( File["jmx_exporter-${listening_port}-${version}.jar"] ) {
    fail("Error: There are multiple prometheus::exporter::jmx resources declared for port ${listening_port}")
  }

  # download the jmx exporter binary
  if ! defined( File["/home/prometheus/jmx_exporter-${version}.jar"] ) {
    file { "jmx_exporter-${listening_port}-${version}.jar":
      ensure => file,
      path   => "${jar_location}/jmx_exporter-${version}.jar",
      source => "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${version}/jmx_prometheus_javaagent-${version}.jar",
      owner  => 'prometheus',
      group  => 'prometheus',
      mode   => '0644',
    }
  }

  # add the jmx exporter configuration file
  file { "jmx-exporter-port-${listening_port}.yml":
    ensure  => file,
    path    => "${config_location}/jmx-exporter-port-${listening_port}.yml",
    owner   => 'prometheus',
    group   => 'prometheus',
    mode    => '0644',
    content => template('prometheus/jmx-exporter.yml.erb'),
  }

  # manage the node-exporter service
  if $facts['virtual'] != 'docker' {

    # open the port to allow scraping of the node_exporter
    firewalld_rich_rule { "Open port ${listening_port} (JMX Exporter) up to the Prometheus server":
      ensure => present,
      zone   => 'public',
      source => "${prometheus_host}/32",
      port   => {
        'port'     => $listening_port,
        'protocol' => 'tcp',
      },
      action => 'accept',
    }

  }

}
