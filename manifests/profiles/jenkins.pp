class jenkins_ci_setup::profiles::jenkins (
  String $user                 = 'jenkins',
  String $group                = 'jenkins',
  String $jenkins_user_home    = "/var/lib/${user}",
  Integer $memory_in_megabytes = 256,
  Hash $user_hash              = {},
)
  {

    package { [ 'openjdk-8-jdk', 'openjdk-8-jdk-headless', 'openjdk-8-jre', 'openjdk-8-jre-headless', ]:
      ensure => installed,
    }
    #  ->apt::source { 'jenkins':
    #    location => 'http://pkg.jenkins-ci.org/debian-stable',
    #    release  => 'binary/',
    #    repos    => '',
    #    key      => {
    #      'id'     => '150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6',
    #      'source' => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
    #    },
    #    include  => {
    #      'src' => false,
    #    },
    #  }
    -> apt::source { 'jenkins':
      location    => 'http://pkg.jenkins-ci.org/debian-stable',
      release     => 'binary/',
      repos       => '',
      key_source  => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
      include_src => false,
      key         => '150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6',
    }

    # change this to a subscription in the real setup
    -> exec { 'jenkins update':
      command   => '/usr/bin/apt-get update',
      logoutput => 'on_failure',
      try_sleep => 1,
      # Compare the age of the sources.list files with pkgcache.bin and execute apt-get update if neccessary
      onlyif    =>
        '/usr/bin/test -n "$(/usr/bin/find /etc/apt/sources.list.d/ /etc/apt/sources.list -newer /var/cache/apt/pkgcache.bin)"'
      ,
    } -> class { '::jenkins':
      repo         => false,
      install_java => false,
      #executors => 4,
      #user_hash => $user_hash,
      #cli_ssh_keyfile => "${jenkins_user_home}/.ssh/id_rsa",
    }

    # The jenkins module utilizes file_line, JAVA_ARGS is prefixed by "export" to prevent duplicate matches
    file_line { "Jenkins disable UPD Ports ${name} 5353 and 33848, set memory":
      path    => '/etc/default/jenkins',
      line    => "export JAVA_ARGS=\"\$JAVA_ARGS -Dhudson.udp=-1 -Dhudson.DNSMultiCast.disabled=true -Xmx${memory_in_megabytes}m\"",
      match   => 'hudson.DNSMultiCast.disabled',
      require => Package['jenkins'],
      notify  => Service['jenkins'],
    }

    file_line { "Set CSP header":
      path    => '/etc/default/jenkins',
      line    => 'export JAVA_ARGS="$JAVA_ARGS -Dhudson.model.DirectoryBrowserSupport.CSP="default-src \'self\'; style-src \'self\' \'unsafe-inline\'"',
      match   => 'hudson.model.DirectoryBrowserSupport.CSP',
      require => Package['jenkins'],
      notify  => Service['jenkins'],
    }

    jenkins::sysconfig { 'JENKINS_ARGS':
      value   => '--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --httpListenAddress=127.0.0.1',
      require => Package['jenkins'],
      notify  => Service['jenkins'],
    }

    jenkins::plugin { 'ansicolor': }
    jenkins::plugin { 'workflow-job': }
    jenkins::plugin { 'pipeline-multibranch-defaults': }
    jenkins::plugin { 'workflow-multibranch': }
    jenkins::plugin { 'config-file-provider': }
    jenkins::plugin { 'branch-api': }
    jenkins::plugin { 'cloudbees-folder': }
    jenkins::plugin { 'active-directory': }
    jenkins::plugin { 'authentication-tokens': }
    jenkins::plugin { 'bouncycastle-api': }
    jenkins::plugin { 'build-timeout': }
    jenkins::plugin { 'credentials-binding': }
    jenkins::plugin { 'plain-credentials': }
    jenkins::plugin { 'display-url-api': }
    jenkins::plugin { 'docker-commons': }
    jenkins::plugin { 'docker-workflow': }
    jenkins::plugin { 'docker-plugin': }
    jenkins::plugin { 'docker-build-step': }
    jenkins::plugin { 'durable-task': }
    jenkins::plugin { 'email-ext': }
    jenkins::plugin { 'external-monitor-job': }
    jenkins::plugin { 'ace-editor': }
    jenkins::plugin { 'jquery-detached': }
    jenkins::plugin { 'git': }
    jenkins::plugin { 'ldap': }
    jenkins::plugin { 'mailer': }
    jenkins::plugin { 'mapdb-api': }
    jenkins::plugin { 'matrix-auth': }
    jenkins::plugin { 'matrix-project': }
    jenkins::plugin { 'antisamy-markup-formatter': }
    jenkins::plugin { 'pam-auth': }
    jenkins::plugin { 'workflow-api': }
    jenkins::plugin { 'workflow-cps': }
    jenkins::plugin { 'workflow-durable-task-step': }
    jenkins::plugin { 'workflow-scm-step': }
    jenkins::plugin { 'workflow-step-api': }
    jenkins::plugin { 'pipeline-stage-step': }
    jenkins::plugin { 'workflow-basic-steps': }
    jenkins::plugin { 'pipeline-utility-steps': }
    jenkins::plugin { 'workflow-support': }
    jenkins::plugin { 'scm-api': }
    jenkins::plugin { 'script-security': }
    jenkins::plugin { 'ssh-credentials': }
    jenkins::plugin { 'ssh-slaves': }
    jenkins::plugin { 'timestamper': }
    jenkins::plugin { 'token-macro': }
    jenkins::plugin { 'icon-shim': }
    jenkins::plugin { 'scm-sync-configuration': }
    jenkins::plugin { 'htmlpublisher': }
    jenkins::plugin { 'rocketchatnotifier': }

    file { "${jenkins_user_home}/.ssh":
      ensure  => directory,
      mode    => '0600',
      owner   => $user,
      group   => $group,
      require => User['jenkins'],
    }
    -> exec { "ssh-keygen -f ${jenkins_user_home}/.ssh/id_rsa -b 4096 -t rsa -q -N '' -C 'deployment-key@${fqdn}'":
      user    => $user,
      alias   => 'jenkins-access-key',
      creates => [
        "${jenkins_user_home}/.ssh/id_rsa",
        "${jenkins_user_home}/.ssh/id_rsa.pub",
      ],
      path    => ['/usr/bin', ],
    }
  }
