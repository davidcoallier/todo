puts Dir.entries("/etc/nginx")
sudo! "apt-get update"
sudo! "apt-get -y upgrade"
sudo! "apt-get -y install uwsgi uwsgi-plugin-python build-essential"
sudo! "apt-get -y install python-pip python-setuptools"
sudo! "rm -rf /etc/uwsgi/*"

if not File.directory?('/var/run/uwsgi')
  sudo! "mkdir /var/run/uwsgi"
end

if not File.directory?('/var/log/uwsgi')
  sudo! "mkdir /var/log/uwsgi"
end

if not File.directory?('/var/www')
  sudo! "mkdir -p /var/www"
end

if not File.directory?('/var/www/fraud-api')
  sudo! "mkdir -p /var/www/fraud-api"
end

sudo! "ruby #{config.release_path}/deploy/configs/appname_yaml.rb"
sudo! "ruby #{config.release_path}/deploy/configs/uwsgi_conf.rb"
sudo! "ruby #{config.release_path}/deploy/configs/nginx_conf.rb"

if File.exists?("/etc/nginx/sites-enabled/app_#{config.app}.conf")
  sudo! "rm -rf /etc/nginx/sites-enabled/app_#{config.app}.conf"
end

if not File.directory?("/var/www/fraud-api/.git")
  sudo! "cd /var/www/fraud-api && git clone https://github.com/davidcoallier/howto-flask.git"
  sudo! "cd /var/www/fraud-api && mv howto-flask/* . && mv howto-flask/.git ."
else
  # This just happened.
  sudo! "cd /var/www/fraud-api && git pull origin master"
end

if File.exists?("/var/www/fraud-api/requirements.txt")
  sudo "cd /var/www/fraud-api && pip install -r requirements.txt"
end

sudo! "chown -R www-data /var/run/uwsgi /var/log/uwsgi /var/www"
sudo! "chmod -R 766 /var/run/uwsgi /var/log/uwsgi /var/www"
sudo! "service uwsgi start"
sudo! "service nginx restart"
