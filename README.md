# Chef WSGI Cookbooks

This is a set of cookbooks for configuring a server to deploy and run an arbitrary WSGI application. Most of the cookbooks come from the main Opscode repository or are inspired by such. 

This set of cookbooks was originally collected and developed to test out the use of Vagrant to easily deploy Flask applications to a standard environment. It assumes the following things:

1. You're developing a standard WSGI application
2. You want to use uWSGI to run your application
3. You want to use nginx as a proxy to uWSGI

In addition to the standard Chef deploy resource this setup does the following:

1. Creates a folder named `etc` within the `shared` folder for holding configuration files. Specifically the applicatin's uWSGI configuration.
2. Creates a folder named `logs` within the `shared` folder for holding the nginx and uWSGI logs.
3. Creates a folder named `run` to hold the uWSGI socket file.
4. Installs dependencies into a virtualenv if a file named `requirements.txt` exists in your application's root folder.


## Using with Vagrant

You can quickly deploy your WSGI application to a local, virtual Ubuntu server by setting up a quick recipe for your application. For instance, you would create the following file relative to your project:

Path:

    cookbooks/my_wsgi_app/recipes/default.rb

Contents:

```ruby
application "my_wsgi_app" do
  path "/srv/my_wsgi_app"
  owner "nobody"
  group "nogroup"
  repository "https://github.com/path/to-your-app.git"
  revision "master"

  uwsgi do
    wsgi_file "wsgi.py"
    callable "application"
  end
end
```

If necessary, modify the values for `repository`, `wsgi_file`, and `callable` to match that of your project.

Then edit your `Vagrantfile` to look like the following:

```ruby
Vagrant::Config.run do |config|
  config.vm.define :wsgivm do |wsgi_config|
    wsgi_config.vm.box = "lucid64"
    wsgi_config.vm.box_url = "http://files.vagrantup.com/lucid64.box"
    wsgi_config.vm.forward_port 80, 8080
    wsgi_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "cookbooks"
      chef.add_recipe "apt"
      chef.add_recipe "build-essential"
      chef.add_recipe "runit"
      chef.add_recipe "nginx"
      chef.add_recipe "git"
      chef.add_recipe "python"
      chef.add_recipe "supervisor"
      chef.add_recipe "uwsgi"
      chef.add_recipe "my_wsgi_app"
    end
  end
end
```

Then from the command line you can run:

    $ vagrant up

This should create the server, configure it properly, and deploy the application. You should then be able to view it by going to http://127.0.0.1:8080 in a browser on your local machine.