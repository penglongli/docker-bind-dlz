## DockerHub

https://hub.docker.com/r/pelin/docker-bind-dlz/

## Build Yourself

You can clone this repo, and change `Dockerfile` to choose `bind9 version`.
Then build your own IMAGE:

```
docker build -t ${IMAGE_NAME} .
```

## How to Use

### MySQL 

First, you shoudld run a MySQL, and create a database named `bind_dlz`.
After database created, create a table:
```sql
DROP TABLE IF EXISTS `dns_records`;
CREATE TABLE `dns_records` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `zone` varchar(255) NOT NULL,
  `host` varchar(255) NOT NULL DEFAULT '@',
  `type` enum('A','MX','CNAME','NS','SOA','PTR','TXT','AAAA','SRV','URL') NOT NULL,
  `data` varchar(255) DEFAULT NULL,
  `ttl` int(11) NOT NULL DEFAULT '3600',
  `mx_priority` int(11) DEFAULT NULL,
  `view` enum('any','Telecom','Unicom','CMCC','ours') NOT NULL DEFAULT 'any',
  `priority` tinyint(3) unsigned NOT NULL DEFAULT '255',
  `refresh` int(11) NOT NULL DEFAULT '28800',
  `retry` int(11) NOT NULL DEFAULT '14400',
  `expire` int(11) NOT NULL DEFAULT '86400',
  `minimum` int(11) NOT NULL DEFAULT '86400',
  `serial` bigint(20) NOT NULL DEFAULT '2015050917',
  `resp_person` varchar(64) NOT NULL DEFAULT 'ddns.net',
  `primary_ns` varchar(64) NOT NULL DEFAULT 'ns.ddns.net.',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `type` (`type`),
  KEY `host` (`host`),
  KEY `zone` (`zone`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
```
Add some rows:
```sql
INSERT INTO `dns_records` VALUES (1, 'test.com', '@', 'SOA', 'ns1.dns.net.', 60, NULL, 'any', 255, 7200, 3600, 86400, 3600, 1000, 'admin.dns.net.', 'ns1.dns.net.', '2018-10-19 02:49:16');
INSERT INTO `dns_records` VALUES (2, 'test.com', '@', 'NS', 'ns1.dns.net.', 60, NULL, 'any', 255, 7200, 3600, 86400, 3600, 1000, 'admin.dns.net.', 'ns1.dns.net.', '2018-10-19 02:49:16');
INSERT INTO `dns_records` VALUES (3, 'test.com', '@', 'NS', 'ns2.dns.net.', 60, NULL, 'any', 255, 7200, 3600, 86400, 3600, 1000, 'admin.dns.net.', 'ns1.dns.net.', '2018-10-19 02:49:16');
INSERT INTO `dns_records` VALUES (4, 'test.com', 'www', 'A', '111.111.111.111', 60, NULL, 'any', 255, 7200, 3600, 86400, 3600, 1000, 'admin.dns.net.', 'ns1.dns.net.', '2018-10-19 02:49:45');
```

### docker-bind-dlz

Next step is run the `docker-bind-dlz`. Because `named` will use `port:953`, so need the `privileged` param.

```bash
docker run -it -d --net=host --restart always --privileged \
  --env MYSQL_DATA_SOURCE="host=127.0.0.1 dbname=bind_dlz ssl=false port=3306 user=root pass=123456" \
  --name=dns pelin/docker-bind-dlz
```
You should pick `host` `dbname` `port` `user` `pass` with this command.

**Test**
```
$ nslookup www.test.com $DNS_HOST
```
