class jenkins_ci_setup::profiles::haproxy (
  String $pem_certificate
) {
  class { 'haproxy':
    global_options   => {
      'maxconn' => undef,
      'user'    => 'root',
      'group'   => 'root',
      'stats'   => [
        'socket /var/lib/haproxy/stats',
        'timeout 30s'
      ]
    },
    defaults_options => {
      'retries' => '5',
      'option'  => [
        'redispatch',
        'http-server-close',
        'logasap',
      ],
      'timeout' => [
        'http-request 7s',
        'connect 3s',
        'check 9s',
        'client 30000',
        'server 30000',
      ],
      'maxconn' => '15000',
    },
  }
  -> haproxy::listen { 'jenkins80':
    mode    => 'http',
    bind    => {
      '*:80'  => '',
    },
    options => {
      # option   => 'httplog',
      redirect => 'scheme https code 301',
      server   => [
        'jenkins 127.0.0.1:8080',
      ],
    }
  }
  -> haproxy::listen { 'jenkins443':
    mode    => 'http',
    bind    => {
      # CIPHERS, TLS1.2, ...
      '*:443' => ["ssl","crt","${pem_certificate}"]
    },
    options => {
      # option   => 'httplog',
      reqadd   => [
        'X-Forwarded-Port:\ %[dst_port]',
        'X-Forwarded-Proto:\ https',
      ],
      server   => [
        'jenkins 127.0.0.1:8080',
      ],
    }
  }
}
