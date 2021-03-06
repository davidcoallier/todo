nginx_block =<<eos
server {
    listen      80;
    server_name abuseengine.engineyard.com;
    
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

File.open('/etc/nginx/sites-enabled/fraudapi.conf', 'w+') do |f|
  f.puts nginx_block
end
