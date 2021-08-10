## Usage

To run the sample tests against the sample modules
```
ruby run.rb
```

---

## Development TODOs

- Can we avoid saving the image when done? Using *-o out* is producing a privilege error at the moment :(
- Test fixtures! Need to be able to provide modules (for puppet apply) and (as a nice to have) files to support tests
- Add Server-Spec support, it's more powerful than Goss
- We've got local running working, but need to support running in a CI pipeline inside an existing container. Either a separate script, or abstract our the docker build stage
- Error handling - lots of nice to haves, but core is that scripts all need to return error codes
- Allow overriding of the docker file? Could do with cleaning up how it all holds together too - the goodman/dev image could be built (+ cached) as part of the run process, but needs to also work for CI pipelines
- Can we replace the Puppet manifests with pure Hiera? Could then include inline in the specs.yml file
- Should have the option to point to a goss test definition file rather than just including them inline
