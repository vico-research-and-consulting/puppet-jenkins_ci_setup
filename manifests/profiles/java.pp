class jenkins_ci_setup::profiles::java (
    String $maven_settings_template = "",
    Hash $maven_settings_config     = {},
    String $java_package_extra      = "openjdk-11-jdk",
    Boolean $maven_purge = false,
    Numeric $delete_older_than = 92,
) {
  class { "maven::maven":
    version => "3.8.2",
  }

  jenkins::plugin { 'maven-plugin': }
  jenkins::plugin { 'm2release': }
  jenkins::plugin { 'javadoc': }
  jenkins::plugin { 'pipeline-maven': }
  jenkins::plugin { 'gradle': }
  jenkins::plugin { 'jacoco': }

  file { '/var/lib/jenkins/.m2/':
    ensure => directory,
    owner  => "jenkins",
    group  => "jenkins",
    mode   => "0755",
  }
  if $maven_settings_template != "" {
    file { '/var/lib/jenkins/.m2/settings.xml':
      ensure => file,
      owner  => "jenkins",
      group  => "jenkins",
      mode   => "0640",
      content => template($maven_settings_template),
      require => File['/var/lib/jenkins/.m2/'],
    }
  }
    if $maven_purge {
        file { '/usr/local/sbin/jenkins-maven-purge':
            ensure  => file,
            owner   => "jenkins",
            group   => "jenkins",
            mode    => "750",
            source => "puppet:///modules/vicoresources/jenkins/jenkins-maven-purge",
        }
        file { "/etc/cron.d/jenkins-maven-purge":
            ensure  => file,
            mode    => '0755',
            owner   => 'root',
            group   => 'root',
            content => "# created by puppet
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
00 18 * * 6 root USER=root /usr/local/sbin/jenkins-maven-purge $delete_older_than 2>&1| logger -t jenkins-maven-purge
",
        }
    }

  if $java_package_extra {
    package{$java_package_extra:
      ensure => present,
    }

    exec { 'update-java-alternatives -s java-1.17.0-openjdk-amd64 -v':
        path      => '/usr/local/sbin:/usr/local/bin:/bin:/sbin:/usr/bin:/usr/sbin',
        user      => 'root',
        logoutput => true,
        unless    => 'java -version 2>&1 |grep -P \'^openjdk version "17\.\d+\.\d+"\'',
        require   => Package[$java_package_extra],
    }
  }
}

