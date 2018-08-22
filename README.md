## DockerHub

https://hub.docker.com/r/pelin/docker-bind-dlz/

## Build

Run:
```
docker build -t ${IMAGE_NAME} .
```

## Run

```bash
docker run -it -d --net=host \
  -e MYSQL_DATA_SOURCE="host=? dbname=? ssl=false port=? user=? pass=?" \
  --privileged --name=dns pelin/docker-bind-dlz \
  /bin/bash -cx "/usr/local/named/sbin/named -4 -c /etc/named/named.conf -L /var/log/named.log; tail -f /var/log/named.log"
```

You should pick `host` `dbname` `port` `user` `pass` with this command

