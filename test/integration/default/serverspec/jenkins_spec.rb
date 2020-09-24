#----------------------------------------------------------------------
# instantiating testing requirements
#----------------------------------------------------------------------

if (!ENV['w_ssh'].nil? && ENV['w_ssh'] = 'true')
  begin
    require 'spec_helper.rb'
  rescue LoadError
  end
else
  begin
    require 'spec_helper.rb'
    set :backend, :exec
  rescue LoadError
  end
end
#----------------------------------------------------------------------

#  http://serverspec.org/resource_types.html

#----------------------------------------------------------------------
# testing basic service
#----------------------------------------------------------------------
describe package('jenkins') do
  it { should be_installed }
end

describe service('jenkins') do
  it { should be_enabled }
end

describe service('jenkins') do
  it { should be_running }
end


describe command('netstat -nlpt') do
  its(:stdout) { should match /127.0.0.1:8080/ }
end


describe port(5353) do
   it { should_not be_listening.with('udp6') }
   it { should_not be_listening.with('udp') }
end

describe port(33848) do
   it { should_not be_listening.with('udp6') }
   it { should_not be_listening.with('udp') }
end

#----------------------------------------------------------------------
# testing basic function
#----------------------------------------------------------------------

describe command('tail -1000 /var/log/jenkins/jenkins.log') do
  its(:stdout) { should_not match /Jenkins is fully up and running/ }
  #its(:stdout) { should_not match /Exception/ }
  #its(:stdout) { should_not match /ERROR/ }
end

describe command('curl -vvv -k "https://127.0.0.1/" 2>&1') do
     its(:stdout) { should match /You are authenticated as: anonymous/ }
end

#----------------------------------------------------------------------

