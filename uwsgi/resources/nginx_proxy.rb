
actions :create, :delete

attribute :path, :kind_of => String, :name_attribute => true
attribute :template, :kind_of => String, :default => 'nginx_proxy.conf.erb'
attribute :cookbook, :kind_of => String, :default => 'uwsgi'

attribute :listen, :kind_of => Integer, :default => 80
attribute :server_name, :kind_of => String, :default => 'localhost'
attribute :access_log, :kind_of => String
attribute :error_log, :kind_of => String
attribute :socket, :kind_of => String
attribute :static_folder, :kind_of => String

attribute :owner, :regex => Chef::Config[:user_valid_regex]
attribute :group, :regex => Chef::Config[:group_valid_regex]