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

File.open('/etc/uwsgi/fraudapi.yaml', 'w+') do |f|
    f.puts appname_yaml
end
