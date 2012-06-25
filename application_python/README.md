# Python/uWSGI Application 

    application "my_wsgi_app" do
      path "/srv/my_wsgi_app"
      owner "nobody"
      group "nogroup"
      repository "https://github.com/mattupstate/cubric-example.git"
      revision "master"

      uwsgi do
        wsgi_file "wsgi.py"
        callable "application"
      end
      
    end