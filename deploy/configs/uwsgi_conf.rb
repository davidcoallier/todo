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

File.open('/etc/init/uwsgi.conf', 'w+') do |f|
  f.puts uwsgi_conf
end
