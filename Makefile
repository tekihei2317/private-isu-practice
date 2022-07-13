NGINX_LOG=/var/log/nginx/access.log
TIMESTAMP=`date +%Y%m%d-%H%M%S`

reload-nginx:
	cat settings/nginx/nginx.conf | sudo tee /etc/nginx/nginx.conf > /dev/null
	sudo nginx -s reload

ALPSORT=sum
ALPM="/TODO:"
OUTFORMAT=count,method,uri,min,max,sum,avg,p99
.PHONY: alp
alp:
	sudo alp ltsv --file=$(NGINX_LOG) --sort $(ALPSORT) --reverse -o $(OUTFORMAT) -m $(ALPM) > measurements/alp/$(TIMESTAMP).log

bench:
	echo '' | sudo tee $(NGINX_LOG) > /dev/null
	ab -c 1 -t 30 http://localhost/ > measurements/score/$(TIMESTAMP).log
	@make alp
