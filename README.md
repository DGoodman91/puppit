## About

A framework for running integration tests on Puppet code/modules in locally provisioned containers. Uses docker to provision a container in which Puppet manifests are applied, then Goss is used to run acceptance tests on the resulting system. The motivation was to get far quicker feedback on changes than provided by VM-based acceptance testing.

---

## Requirements

- Ruby (tested w/ ruby 3.1.1p18 (2022-02-18 revision 53f5fc4236) [x64-mingw-ucrt])
- Docker (tested w/ Docker version 20.10.11, build dea9396)

---

## Usage

Start by pulling in the Ruby dependencies with 
```
bundler install
```

To view usage instructions:
```
$ ruby run.rb -h
Usage: ruby run.rb [options]
    -s, --specfile=filepath          The relative path to the spec yaml file. Required
    -i, --imagetag=tag               The tag to give the base Dockerfile created. Default goodmandev/puppit
    -r, --userepoimage               Skip the building of the base image, instead pulling the image from a local/remote repository
    -d, --debug                      Turn on debug mode
    -h, --help                       Displays Help
```
To get started, run the sample integration tests with:
```
$ ruby run.rb --specfile=examples/prometheus/specs.yml
Running tests for exporter-tests
puppit-exporter-tests-1633192508#1 [internal] load build definition from Dockerfile
#1 sha256:5a087c871fe41ac8138d45af79d0629c6255632fd80d10a128ae608814ee690b
#1 transferring dockerfile: 731B done
#1 DONE 0.0s
...
```

---

## Limitations/Problems
### init systems in containers
Service management inside containers can be awkward. For example, a manifest may define a service as follows
```puppet
  service { 'sendmail':
    ensure  => running,
  }
```
When this manifest is applied to, e.g., a CentOS 7 VM, the OS's default init system, *systemd*, will be used to start and manage the service. In a container, however, there is no init system running to communicate with, so the service will not be started.

A somewhat clunky workaround is to use the relevant attributes of the Service type to provide management commands that don't rely on systemd, e.g.
```puppet
  if $facts['virtual'] == 'docker' {
    service { 'sendmail':
      ensure => running,
      start  => '/usr/sbin/sendmail -bd -q1h',
    }
  }
```
Alternatively, if launching the container tests on a CentOS server/VM then the [CentOS systemd docker container](https://hub.docker.com/r/centos/systemd), which relies on mounting a volume from the host OS, can be used as a base.

Another consequence of the lack of an init system is that Goss's *service* tests don't work - a simple alternative is to use the *process* test.

---

## Other references
- [Goss](https://github.com/aelsabbahy/goss)

---

## Development TODOs
### Functionality
- If we're running in debug mode, pause after the tests have run so user can connect into the container and inspect (or add a new option specifically for this)
- Add Server-Spec support, it's more powerful than Goss
- We've got local running working, but need to support running in a CI pipeline inside an existing container. Either a separate script, or abstract our the docker build stage
- Can we replace the Puppet manifests with pure Hiera? Could then include inline in the specs.yml file
- Should have the option to point to a goss test definition file rather than just including them inline
### Code Quality
- Refactor to a less procedural style