#
# Cookbook Name:: hudson_slave
# Recipe:: default
#

# TODO
# * Announce slave to the master node (hard coded for now)
# * Add an job to the master for each app on this slave, and limit them to run on this slave
# * Customise the build steps for the app based on the "migrate" field of the app in the instance (usually "rake db:migrate")

# Config
master_hostname = "ec2-184-73-167-68.compute-1.amazonaws.com"


# Tell server about this slave
# ...

# Tell server about each application
node[:applications].each do |application, data|
  # We need the app name and the git repo, at minimum
  # ...
end
