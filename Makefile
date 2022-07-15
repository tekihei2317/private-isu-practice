NGINX_LOG=/var/log/nginx/access.log
MYSQL_LOG=/var/log/mysql/mysql-slow.log

reload-nginx:
	cat settings/nginx/nginx.conf | sudo tee /etc/nginx/nginx.conf > /dev/null
	sudo nginx -s reload

reload-app:
	sudo systemctl restart isu-ruby.service

reload-mysql:
	cat settings/mysql/mysql.conf.d/mysqld.cnf | sudo tee /etc/mysql/mysql.conf.d/mysqld.cnf > /dev/null
	sudo systemctl restart mysql.service

mysql:
	mysql -u isuconp -p

ALPSORT=sum
ALPM="/TODO:"
OUTFORMAT=count,method,uri,min,max,sum,avg,p99
.PHONY: alp
alp:
	sudo alp ltsv --file=$(NGINX_LOG) --sort $(ALPSORT) --reverse -o $(OUTFORMAT) -m $(ALPM)

pt-query-digest:
	sudo pt-query-digest $(MYSQL_LOG)

bench:
	echo '' | sudo tee $(NGINX_LOG) > /dev/null
	echo '' | sudo tee $(MYSQL_LOG) > /dev/null
	$(eval DIR := measurements/$(shell date +%Y%m%d-%H%M%S))
	mkdir -p $(DIR)
	ab -c 1 -t 30 http://localhost/ > $(DIR)/score.log
	@make alp > $(DIR)/alp.log
	@make pt-query-digest > $(DIR)/query.log

setup:
	sudo apt install -y percona-toolkit
