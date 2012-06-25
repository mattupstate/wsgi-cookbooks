include Chef::Mixin::LanguageIncludeRecipe

action :before_compile do

  include_recipe "supervisor"

  if !new_resource.restart_command
    new_resource.restart_command do
      run_context.resource_collection.find(:supervisor_service => new_resource.application.name).run_action(:restart)
    end
  end

  raise "You must specify a wsgi file" unless new_resource.wsgi_file
  raise "You must specify a callable that is in the wsgi file" unless new_resource.callable
end

action :before_deploy do

  new_resource = @new_resource

  ensure_dir "#{new_resource.application.path}/shared/run"
  ensure_dir "#{new_resource.application.path}/shared/logs"

  Chef::Log.info("Creating uWSGI config")

  uwsgi_config "#{new_resource.application.path}/shared/etc/uwsgi_config.ini" do
    action :create
    template new_resource.uwsgi_template || 'uwsgi.ini.erb'
    cookbook new_resource.uwsgi_template ? new_resource.cookbook_name : 'uwsgi'
    socket new_resource.socket || "#{new_resource.application.path}/shared/run/uwsgi.sock"
    home new_resource.home || "#{new_resource.application.path}/shared/env"
    pythonpath new_resource.pythonpath || "#{new_resource.application.path}/current"
    logto new_resource.logto || "#{new_resource.application.path}/shared/logs/uwsgi.log"
    wsgi_file "#{new_resource.application.path}/current/#{new_resource.wsgi_file}"
    callable new_resource.callable
    master new_resource.master
    processes new_resource.processes
    max_requests new_resource.max_requests
  end

  Chef::Log.info("Creating Supervisor Service")

  supervisor_service new_resource.application.name do
    action :enable
    command "uwsgi --ini #{new_resource.application.path}/shared/etc/uwsgi_config.ini"
    directory ::File.join(new_resource.path, "current")
    autostart false
    user new_resource.owner
  end

  Chef::Log.info("Creating nginx Proxy")

  uwsgi_nginx_proxy "#{node['nginx']['dir']}/sites-available/#{new_resource.application.name}.conf" do
    action :create
    template new_resource.nginx_proxy_template || 'nginx_proxy.conf.erb'
    cookbook new_resource.nginx_proxy_template ? new_resource.cookbook_name : 'uwsgi'
    listen new_resource.listen
    server_name new_resource.server_name
    access_log new_resource.access_log || "#{new_resource.application.path}/shared/logs/access.log"
    error_log new_resource.error_log || "#{new_resource.application.path}/shared/logs/error.log"
    socket new_resource.socket || "#{new_resource.application.path}/shared/run/uwsgi.sock"
    static_folder new_resource.static_folder || "#{new_resource.application.path}/current/static"
  end

  nginx_site "#{new_resource.application.name}.conf"

  nginx_site "default" do
    enable false
  end
end

action :before_migrate do
  install_packages
end

action :before_symlink do
end

action :before_restart do
end

action :after_restart do
end

protected

def ensure_dir(dir)
  directory dir do
    recursive true
    action :create
  end
end

def install_packages
  Chef::Log.info('Creating virtualenv')

  python_virtualenv new_resource.virtualenv do
    path new_resource.virtualenv
    action :create
  end

  Chef::Log.info('Installing packages: #{new_resource.application.packages}')

  new_resource.packages.each do |name, ver|
    python_pip name do
      version ver if ver && ver.length > 0
      virtualenv new_resource.virtualenv
      action :install
    end
  end

  if new_resource.requirements.nil?
    # look for requirements.txt files in common locations
    [
      ::File.join(new_resource.release_path, "requirements", "#{node.chef_environment}.txt"),
      ::File.join(new_resource.release_path, "requirements.txt")
    ].each do |path|
      if ::File.exists?(path)
        new_resource.requirements path
        break
      end
    end
  end

  if new_resource.requirements
    python_pip "" do
      virtualenv new_resource.virtualenv
      options "-r #{new_resource.requirements}"
      action :install
    end
  else
    Chef::Log.debug("No requirements file found")
  end
end