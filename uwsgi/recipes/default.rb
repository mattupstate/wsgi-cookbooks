include_recipe 'python'

uwsgi_install "uwsgi" do
  virtualenv node['uwsgi']['virtualenv']
end