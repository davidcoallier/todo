sudo! "apt-get update"
sudo! "apt-get -y upgrade"
sudo! "apt-get -y install uwsgi uwsgi-plugin-python build-essentials"
sudo! "apt-get -y install python-pip python-setuptools"
sudo! "pip install virtualenvs"
sudo! "rm -rf /etc/uwsgi/*"
sudo! "mkdir /var/run/uwsgi"
sudo! "mkdir /var/log/uwsgi"
sudo! "mkdir -p /var/www/fraud-api"

appname_yaml =<<eos
uwsgi:
    callable: app
    master: true
    lazy-apps: true
    module: api
    workers: 8
    reload-mercy: 3600
    vacuum: false
    daemonize: /var/log/uwsgi/appname.log
    uid: www-data
    gid: nogroup
    pidfile: /var/run/uwsgi/appname.pid
    socket: /tmp/appname.sock
    pp: /var/www/appname/
    chdir: /var/www/appname
    plugins: python
eos

uwsgi_conf =<<eof
# uWSGI - Emperor
#
    
description     "uWSGI Emperor"
    
start on runlevel [2345]
stop on runlevel [06]
    
respawn
    
env LOGTO=/var/log/uwsgi.log
env BINPATH=/usr/bin/uwsgi
env VASSALS=/etc/uwsgi
    
exec $BINPATH --emperor $VASSALS --logto $LOGTO
eof

nginx_block =<<eos
server {
    listen      8080;
    server_name  _;
    
    error_log /var/log/nginx/appname-error.log;
    access_log /var/log/nginx/appname-access.log;
    
    root         /var/www/fraud-api;
    
    location / {
        try_files $uri @uwsgi;
    }
    
    location @uwsgi {
        proxy_set_header Host $host;
        include      uwsgi_params;
        uwsgi_pass   unix:///tmp/appname.sock;
    }
}
eos

appname_yaml_file = File.open('/etc/uwsgi/fraudapi.yaml', 'w+')
appname_yaml_file.puts appname_yaml
appname_yaml.file.close

uwsgi_conf_file = File.open('/etc/init/uwsgi.conf', 'w+')
uwsgi_conf_file.puts uwsgi_conf
uwsgi_conf_file.close

nginx_block_file = File.open('/etc/nginx/sites-enabled/fraudapi.conf')
nginx_block_file.puts nginx_block
nginx_block_file.close

sudo! "git clone https://github.com/davidcoallier/howto-flask.git /var/www/fraud-api"

if File.exists?("/var/www/fraud-api/requirements.txt")
  sudo! "cd /var/www/fraud-api && pip install -r requirements.txt"
end

sudo! "chown -R www-data /var/run/uwsgi /var/log/uwsgi /var/www"
sudo! "chmod -R 766 /var/run/uwsgi /var/log/uwsgi /var/www"
sudo! "service uwsgi start"
sudo! "service nginx restart"
