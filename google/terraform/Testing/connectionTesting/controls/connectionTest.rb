title 'Connection Testing'
###############################
#
##############################
# Container 1
describe host('35.197.56.118', port: 5000, protocol: 'tcp') do
        it { should be_reachable }
        its('ipaddress') { should include '35.197.56.118' }
end

describe http('http://35.197.56.118:5000/') do
        its('status') { should cmp 200 }
end

# Container 2
describe host('35.197.56.118', port: 5001, protocol: 'tcp') do
        it { should be_reachable }
        its('ipaddress') { should include '35.197.56.118' }
end

describe http('http://35.197.56.118:5001/') do
        its('status') { should cmp 200 }
end

####################################################################################################
# HAPROXY_VM2
####################################################################################################
# Container 1
describe host('35.197.108.192', port: 5000, protocol: 'tcp') do
        it { should be_reachable }
        its('ipaddress') { should include '35.197.108.192' }
end

describe http('http://35.197.108.192:5000/') do
        its('status') { should cmp 200 }
end

# Container 2
describe host('35.197.108.192', port: 5001, protocol: 'tcp') do
        it { should be_reachable }
        its('ipaddress') { should include '35.197.108.192' }
end

describe http('http://35.197.108.192:5001/') do
        its('status') { should cmp 200 }
end

