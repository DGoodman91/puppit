# @summary Add the prometheus user
#
# @example
#   include prometheus::utils::user
class prometheus::utils::user {

  # create a user to install & run prometheus as
  user { 'prometheus':
    ensure         => 'present',
    name           => 'prometheus',
    home           => '/home/prometheus',
    managehome     => true,
    password       => Sensitive('!pwd'),
    purge_ssh_keys => true,
    shell          => '/sbin/nologin',
  }

}
