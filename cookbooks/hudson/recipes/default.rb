#
# Cookbook Name:: hudson
# Recipe:: default
#

# Using manual hudson for now not hudson gem. No ebuild seems to exist.
# Based on http://bit.ly/9Y852l

# We'll assume running hudson under the default username
hudson_user = node[:users].first[:username]

%w[logs tmp war].each do |dir|
  directory "/opt/hudson/#{dir}" do
    owner hudson_user
    group hudson_user
    mode  '0755' unless dir == "war"
    action :create
    recursive true
  end
end

remote_file "/opt/hudson/hudson.war" do
  source "http://hudson-ci.org/latest/hudson.war"
  owner hudson_user
  group hudson_user
  backup 0
  not_if { FileTest.exists?("/opt/hudson/hudson.war") }
end

template "/etc/init.d/hudson" do
  source "init.sh.erb"
  owner "root"
  group "root"
  variables(:hudson_user => hudson_user)
  not_if { FileTest.exists?("/etc/init.d/hudson") }
