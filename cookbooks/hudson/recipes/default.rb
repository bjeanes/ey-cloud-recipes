#
# Cookbook Name:: hudson
# Recipe:: default
#

# Using manual hudson for now not hudson gem. No ebuild seems to exist.
# Based on http://bit.ly/9Y852l

# We'll assume running hudson under the default username
hudson_user = node[:users].first[:username]
hudson_port = 8082
hudson_home = "/opt/hudson"
hudson_pid  = "#{hudson_home}/tmp/pid"

%w[logs tmp war .].each do |dir|
  directory "#{hudson_home}/#{dir}" do
    owner hudson_user
    group hudson_user
    mode  0755 unless dir == "war"
    action :create
    recursive true
  end
end

remote_file "#{hudson_home}/hudson.war" do
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
  mode 0755
  variables(
    :user => hudson_user,
    :port => hudson_port,
    :home => hudson_home,
    :pid  => hudson_pid
  )
  not_if { FileTest.exists?("/etc/init.d/hudson") }
end

execute "ensure-hudson-is-running" do
  command "/etc/init.d/hudson start && ps aux | grep `cat #{hudson_pid}`"
end
