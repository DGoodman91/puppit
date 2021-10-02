## Usage
To view usage instructions:
```
$ ruby run.rb -h
Usage: ruby run.rb [options]
    -s, --specfile=filepath          The relative path to the spec yaml file [Required]
    -d, --debug                      Turn on debug mode
    -h, --help                       Displays Help
```
To run test suites defined by a specific spec file:
```
$ ruby run.rb --specfile=specs.yml
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

## Development TODOs
### Functionality
- If we're running in debug mode, pause after the tests have run so user can connect into the container and inspect (or add a new option specifically for this). This would probably require templating the dockerfile
- Add Server-Spec support, it's more powerful than Goss
- We've got local running working, but need to support running in a CI pipeline inside an existing container. Either a separate script, or abstract our the docker build stage
- Allow overriding of the docker file? Could do with cleaning up how it all holds together too - the goodman/dev image could be built (+ cached) as part of the run process, but needs to also work for CI pipelines
- Can we replace the Puppet manifests with pure Hiera? Could then include inline in the specs.yml file
- Should have the option to point to a goss test definition file rather than just including them inline
### Code Quality
- Bundler Gemfile for our dependencies
- Refactor to a less procedural style