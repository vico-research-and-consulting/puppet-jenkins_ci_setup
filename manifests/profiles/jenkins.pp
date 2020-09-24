class jenkins_ci_setup::profiles::jenkins (
  String $user                              = 'jenkins',
  String $group                             = 'jenkins',
  String $jenkins_user_home                 = "/var/lib/${user}",
  Optional[String] $admin_credentials       = undef,
  Optional[String] $unattended_upgrade_cron = undef,
  Integer $memory_in_megabytes              = 512,
  Hash $user_hash                           = {},
  Hash $modules                             = {},
  Boolean $default_plugins                  = true,
  Hash $plugin_hash                         = {},
  Boolean $purge_plugins                    = false,
)
  {

    if $default_plugins {
      $default_plugins_hash = {
        'basic-branch-build-strategies'      => {},
        'ws-ws-replacement'                  => {},
        'command-launcher'                   => {},
        'ansicolor'                          => {},
        'extended-choice-parameter'          => {},
        'jquery'                             => {},
        'jsch'                               => {},
        'junit'                              => {},
        'subversion'                         => {},
        'git-client'                         => {},
        'apache-httpcomponents-client-4-api' => {},
        'jackson2-api'                       => {},
        'workflow-job'                       => {},
        'workflow-aggregator'                => {},
        'pipeline-multibranch-defaults'      => {},
        'workflow-multibranch'               => {},
        'config-file-provider'               => {},
        'branch-api'                         => {},
        'cloudbees-folder'                   => {},
        'active-directory'                   => {},
        'authentication-tokens'              => {},
        'bouncycastle-api'                   => {},
        'build-timeout'                      => {},
        'credentials-binding'                => {},
        'plain-credentials'                  => {},
        'snakeyaml-api'                      => {},
        'display-url-api'                    => {},
        'docker-commons'                     => {},
        'docker-java-api'                    => {},
        'docker-workflow'                    => {},
        'docker-plugin'                      => {},
        'docker-build-step'                  => {},
        'durable-task'                       => {},
        'email-ext'                          => {},
        'external-monitor-job'               => {},
        'ace-editor'                         => {},
        'jquery-detached'                    => {},
        'git'                                => {},
        'ldap'                               => {},
        'mailer'                             => {},
        'mapdb-api'                          => {},
        'matrix-auth'                        => {},
        'matrix-project'                     => {},
        'antisamy-markup-formatter'          => {},
        'pam-auth'                           => {},
        'workflow-api'                       => {},
        'workflow-cps'                       => {},
        'workflow-durable-task-step'         => {},
        'workflow-scm-step'                  => {},
        'workflow-step-api'                  => {},
        'pipeline-stage-step'                => {},
        'workflow-basic-steps'               => {},
        'pipeline-utility-steps'             => {},
        'workflow-support'                   => {},
        'scm-api'                            => {},
        'script-security'                    => {},
        'ssh-credentials'                    => {},
        'ssh-slaves'                         => {},
        'timestamper'                        => {},
        'token-macro'                        => {},
        'icon-shim'                          => {},
        'htmlpublisher'                      => {},
        'rocketchatnotifier'                 => {},
        'configuration-as-code'              => {},
        'bootstrap4-api'                     => {},
        'echarts-api'                        => {},
        'workflow-cps-global-lib'            => {},
        'pipeline-stage-view'                => {},
        'lockable-resources'                 => {},
        'h2-api'                             => {},
        'jquery3-api'                        => {},
        'font-awesome-api'                   => {},
        'popper-api'                         => {},
        'jquery3-api'                        => {},
        'plugin-util-api'                    => {},
        'pipeline-rest-api'                  => {},
        'handlebars'                         => {},
        'momentjs'                           => {},
        'git-server'                         => {},

      }
    } else {
      $default_plugins_hash = {}
    }

    package { [ 'openjdk-8-jdk', 'openjdk-8-jdk-headless', 'openjdk-8-jre', 'openjdk-8-jre-headless', ]:
      ensure => installed,
    }
    -> apt::source { 'jenkins':
      location => 'http://pkg.jenkins.io/debian-stable',
      release  => 'binary/',
      repos    => '',
      key      => {
        'id'     => '62A9756BFD780C377CF24BA8FCEF32E745F2C3D5',
        'source' => 'https://pkg.jenkins.io/debian-stable/jenkins.io.key'
      },
      include  => {
        'src' => false,
        'deb' => true,
      },
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
      repo            => false,
      install_java    => false,
      user_hash       => $user_hash,
      #cli_remoting_free => true,
      plugin_hash     => deep_merge($plugin_hash, $default_plugins_hash),
      #cli               => true,
      #cli_password_file => $admin_password_creds,
      #executors         => 4,
      cli_username    => "admin",
      cli_ssh_keyfile => "${jenkins_user_home}/.ssh/id_rsa",
      purge_plugins   => $purge_plugins,
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
      line    =>
        'export JAVA_ARGS="$JAVA_ARGS -Dhudson.model.DirectoryBrowserSupport.CSP=\"sandbox allow-scripts; default-src *; style-src * http://* \'unsafe-inline\' \'unsafe-eval\'; script-src \'self\' http://* \'unsafe-inline\' \'unsafe-eval\'\""'
      ,
      match   => '.*hudson.model.DirectoryBrowserSupport.CSP.*',
      require => Package['jenkins'],
      notify  => Service['jenkins'],
    }

    jenkins::sysconfig { 'JENKINS_ARGS':
      value   => '--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --httpListenAddress=127.0.0.1',
      require => Package['jenkins'],
    }

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

    file { "/etc/jenkins":
      ensure => directory,
      mode   => '0700',
      owner  => 'root',
      group  => 'root',
    }

    file { "/usr/local/sbin/jenkins-unattended-upgrades":
      ensure  => file,
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      source  => 'puppet:///modules/jenkins_ci_setup/jenkins-unattended-upgrades',
      require => File['/etc/jenkins'],
    }
    file { "/usr/local/sbin/jenkins-cli":
      ensure  => file,
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
      source  => 'puppet:///modules/jenkins_ci_setup/jenkins-cli',
      require => File['/etc/jenkins'],
    }

    if $admin_credentials {
      file { "/etc/jenkins/admin-password":
        ensure  => file,
        mode    => '0600',
        owner   => 'root',
        group   => 'root',
        content => "$admin_credentials",
        require => File['/etc/jenkins'],
      }
    } else {
      file { "/etc/jenkins/admin-password":
        ensure => absent,
      }
    }

    if $unattended_upgrade_cron {
      file { "/etc/cron.d/jenkins-unattended-upgrades":
        ensure  => file,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        content => "# created by puppet
${unattended_upgrade_cron} root /usr/local/sbin/jenkins-unattended-upgrades 2>&1| logger -t jenkins-unattended-upgrades
        ",
        require => File['/etc/jenkins'],
      }
    } else {
      file { "/etc/cron.d/jenkins-unattended-upgrades":
        ensure => absent,
      }
    }
  }
