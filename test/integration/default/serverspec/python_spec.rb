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
describe package('python3.9') do
  it { should be_installed }
end


for cmd in ['black', 'isort', 'pipenv'] do
  describe command("which #{cmd}") do
    its('exit_status') { should eq 0 }
  end
end

describe service('docker') do
  it { should be_running }
end


#----------------------------------------------------------------------
# testing basic function
#----------------------------------------------------------------------

describe command('docker run hello-world') do
  its(:stdout) { should match /Hello from Docker!/ }
end

#----------------------------------------------------------------------

