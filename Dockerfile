FROM phusion/baseimage:demo
MAINTAINER Naftuli Tzvi Kay <rfkrocktk@gmail.com>

ENV HOME /root
ENV LANG en_US.UTF-8
RUN locale-gen en_US.UTF-8

# Fixes Docker Automated Build problem
RUN ln -s -f /bin/true /usr/bin/chfn

# Install tools
RUN apt-get update -q 2 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y ca-certificates > /dev/null

# Install Puppet Labs Repository for Trusty
RUN curl -o puppet.deb -s https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
    DEBIAN_FRONTEND=noninteractive dpkg -i puppet.deb > /dev/null \
    && rm puppet.deb

# Install the latest stable Puppet client
RUN apt-get update -q 2 && DEBIAN_FRONTEND=noninteractive \
    apt-get install --yes -q 2 puppet >/dev/null

ADD conf/puppet/puppet.conf /etc/puppet/
ADD conf/puppet/hiera.yaml /etc/puppet/

# Install startup script for adding the cron job
ADD scripts/50_add_puppet_cron.sh /etc/my_init.d/
RUN chmod +x /etc/my_init.d/50_add_puppet_cron.sh

# Install actual Puppet agent run command
ADD scripts/run-puppet-agent.sh /sbin/run-puppet-agent
RUN chmod +x /sbin/run-puppet-agent

# Use the runit init system.
CMD ["/sbin/my_init"]
