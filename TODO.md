* What's this warning? May need the above debug addition to work it out..
        #11 2.383 Notice: /Stage[main]/Prometheus::Utils::User/User[prometheus]/ensure: created
        #11 2.421 Warning: Private key for 'buildkitsandbox' does not exist
        #11 2.421 Warning: Client certificate for 'buildkitsandbox' does not exist
        #11 11.23 Notice: /Stage[main]/Prometheus::Exporter::Node/File[/home/prometheus/node_exporter-1.1.2.linux-amd64.tar.gz]/ensure: defined content as '{mtime}2021-12-08 08:52:11 UTC'
        #11 11.43 Notice: /Stage[main]/Prometheus::Exporter::Node/Exec[extract_node_exporter]/returns: executed successfully
        #11 11.44 Notice: /Stage[main]/Prometheus::Exporter::Node/Service[node-exporter]/ensure: ensure changed 'stopped' to 'running'
        #11 12.59 Notice: /Stage[main]/Main/Prometheus::Exporter::Jmx[jmx exporter]/File[jmx_exporter-9101-0.15.0.jar]/ensure: defined content as '{md5}ac475ee988c8a52d2310f073e67aca61'
        #11 12.60 Notice: /Stage[main]/Main/Prometheus::Exporter::Jmx[jmx exporter]/File[jmx-exporter-port-9101.yml]/ensure: defined content as '{md5}d41d8cd98f00b204e9800998ecf8427e'
        #11 12.62 Notice: /Stage[main]/Main/Prometheus::Exporter::Jmx[jmx exporter 2]/File[jmx-exporter-port-9102.yml]/ensure: defined content as '{md5}d41d8cd98f00b204e9800998ecf8427e
    Seems to sometimes be causing long hanging of the process..