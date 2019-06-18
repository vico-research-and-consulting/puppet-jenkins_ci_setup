# == Class: jenkins_ci_setup
#
class jenkins_ci_setup {

  include ::jenkins_ci_setup::profiles::jenkins
  include ::jenkins_ci_setup::profiles::docker
  include ::jenkins_ci_setup::profiles::haproxy
  include ::jenkins_ci_setup::profiles::java
  include ::jenkins_ci_setup::profiles::python
}
