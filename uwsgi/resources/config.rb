
actions :create, :delete

attribute :path, :kind_of => String, :name_attribute => true
attribute :template, :kind_of => String, :default => 'uwsgi.ini.erb'
attribute :cookbook, :kind_of => String, :default => 'uwsgi'

attribute :wsgi_file, :kind_of => String
attribute :callable, :kind_of => String
attribute :socket, :kind_of => String
attribute :home, :kind_of => String
attribute :pythonpath, :kind_of => String
attribute :logto, :kind_of => String
attribute :master, :kind_of => [TrueClass, FalseClass], :default => true
attribute :processes, :kind_of => Integer, :default => [node['cpu']['total'].to_i * 4, 8].min
attribute :max_requests, :kind_of => Integer, :default => 0

attribute :owner, :regex => Chef::Config[:user_valid_regex]
attribute :group, :regex => Chef::Config[:group_valid_regex]