
action :create do
  
  Chef::Log.info("Creating #{@new_resource} at #{@new_resource.path}")  unless exists?
  
  template_variables = {}
  %w{socket logto home pythonpath wsgi_file callable max_requests master processes}.each do |a|
    template_variables[a.to_sym] = new_resource.send(a)
  end
  
  Chef::Log.info("Using variables #{template_variables} to configure #{@new_resource}")
  
  config_dir = ::File.dirname(new_resource.path)
  
  d = directory config_dir do
    recursive true
    action :create
  end
  
  t = template new_resource.path do
    source new_resource.template
    cookbook new_resource.cookbook
    mode "0644"
    owner new_resource.owner if new_resource.owner
    group new_resource.group if new_resource.group
    variables template_variables
  end
  
  new_resource.updated_by_last_action(d.updated_by_last_action? || t.updated_by_last_action?)
end

action :delete do 
  if exists?
    if ::File.writable?(@new_resource.path)
      Chef::Log.info("Deleting #{@new_resource} at #{@new_resource.path}")
      ::File.delete(@new_resource.path)
      new_resource.updated_by_last_action(true)
    else
      raise "Cannot delete #{@new_resource} at #{@new_resource.path}!"
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::UwsgiConfig.new(@new_resource.name)
  @current_resource.path(@new_resource.path)
  @current_resource
end

private
  def exists?
    ::File.exist?(@current_resource.path)
  end