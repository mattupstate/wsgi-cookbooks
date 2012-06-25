include Chef::Resource::ApplicationBase

attribute :uwsgi_template, :kind_of => [String, NilClass], :default => nil
attribute :nginx_proxy_template, :kind_of => [String, NilClass], :default => nil

attribute :packages, :kind_of => [Array, Hash], :default => []
attribute :requirements, :kind_of => [NilClass, String, FalseClass], :default => nil

attribute :listen, :kind_of => Integer, :default => 80
attribute :server_name, :kind_of => String, :default => 'localhost'
attribute :socket, :kind_of => [String, NilClass], :default => nil
attribute :access_log, :kind_of => [String, NilClass], :default => nil
attribute :error_log, :kind_of => [String, NilClass], :default => nil
attribute :static_folder, :kind_of => [String, NilClass], :default => nil

attribute :wsgi_file, :kind_of => [String, Symbol, NilClass], :default => nil
attribute :callable, :kind_of => String, :default => nil
attribute :home, :kind_of => [String, NilClass], :default => nil
attribute :pythonpath, :kind_of => [String, NilClass], :default => nil
attribute :logto, :kind_of => [String, NilClass], :default => nil
attribute :master, :kind_of => [TrueClass, FalseClass], :default => true
attribute :processes, :kind_of => Integer, :default => 1
attribute :max_requests, :kind_of => Integer, :default => 1000



def virtualenv
  "#{path}/shared/env"
end