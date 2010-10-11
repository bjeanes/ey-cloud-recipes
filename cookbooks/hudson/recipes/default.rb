#
# Cookbook Name:: hudson
# Recipe:: default
#

# Using manual hudson for now not hudson gem. No ebuild seems to exist.
# Based on http://bit.ly/9Y852l

# You can use this in combination with http://github.com/bjeanes/ey_hudson_proxy
# to serve hudson publicly on a Hudson-only EY instance. This is so you don't have to
# find a simple app to run on the instance in lieu of an actual staging/production site.
# Alternatively, set up nginx asa reverse proxy manually.

# We'll assume running hudson under the default username
hudson_user = node[:users].first[:username]
hudson_port = 8082 # change this in your proxy if modified
hudson_home = "/data/hudson-ci"
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
  not_if { FileTest.exists?("#{hudson_home}/hudson.war") }
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
  command "/etc/init.d/hudson restart && /etc/init.d/hudson status | grep started && ps aux | grep `cat #{hudson_pid}`"
end
