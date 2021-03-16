FROM centos/systemd
RUN yum install -y https://yum.puppetlabs.com/puppet-release-el-7.noarch.rpm
RUN yum install -y puppet-agent \
                    less \
                    rsyslog
RUN echo -e 'SELINUX=enforcing\nSELINUXTYPE=targeted\n' > /etc/selinux/config
