class jenkins_ci_setup::profiles::java (
) {
  package{ "maven": }

  jenkins::plugin { 'maven-plugin': }
  jenkins::plugin { 'm2release': }
  jenkins::plugin { 'javadoc': }
  jenkins::plugin { 'pipeline-maven': }
  jenkins::plugin { 'maven-repo-cleaner': }
  jenkins::plugin { 'gradle': }


}

