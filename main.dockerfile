FROM goodmandev/puppit

# we'll use this as our working directory
ENV TESTHOME=testing

# copy in the puppet module we wish to test
RUN mkdir -p $TESTHOME/manifests

# copy the manifest in that describes the system under test
COPY site.pp $TESTHOME/manifests/

# copy in our modules
COPY modules $TESTHOME/modules

# copy in the test definitions
COPY goss.yaml $TESTHOME

# copy in any supplementary files needed for testing
COPY files $TESTHOME

# apply the puppet manifest & run out goss tests
RUN /opt/puppetlabs/bin/puppet apply --modulepath=$TESTHOME/modules $TESTHOME/manifests/site.pp && /usr/local/bin/goss -g $TESTHOME/goss.yaml validate --format documentation
