action :install do
  python_virtualenv new_resource.virtualenv do
    action :create
  end if new_resource.virtualenv

  python_pip "uwsgi" do
    virtualenv new_resource.virtualenv
    action :install
  end
end