.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container
	@echo ""   2. make build     - build docker container
	@echo ""   3. make clean     - kill and remove docker container
	@echo ""   4. make enter     - execute an interactive bash in docker container
	@echo ""   3. make logs      - follow the logs of docker container

# run a  container that requires mysql temporarily
temp: NAME MYSQL_PASS rm mysqltemp

# import
import: NAME MYSQL_PASS mysqlimport

# run a  container that requires mysql in production with persistent data
# HINT: use the grabmysqldatadir recipe to grab the data directory automatically from the above runmysqltemp
prod: NAME MYSQL_DATADIR MYSQL_PASS rm mysqlcid

kill:
	-@docker kill `cat mysqlcid`

rm-image:
	-@docker rm `cat mysqlcid`
	-@rm mysqlcid

rm: kill rm-image

clean: rmall

enter:
	docker exec -i -t `cat mysqlcid` /bin/bash

logs:
	docker logs -f `cat mysqlcid`

NAME:
	@while [ -z "$$NAME" ]; do \
		read -r -p "Enter the name you wish to associate with this container [NAME]: " NAME; echo "$$NAME">>NAME; cat NAME; \
	done ;

TAG:
	@while [ -z "$$TAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container [TAG]: " TAG; echo "$$TAG">>TAG; cat TAG; \
	done ;

# MYSQL additions
# use these to generate a mysql container that may or may not be persistent

mysqlcid:
	$(eval MYSQL_DATADIR := $(shell cat MYSQL_DATADIR))
	docker run \
	--cidfile="mysqlcid" \
	--name `cat NAME`-mysql \
	-e MYSQL_ROOT_PASSWORD=`cat MYSQL_PASS` \
	-d \
	-v $(MYSQL_DATADIR):/var/lib/mysql \
	mysql:5.6


rmmysql: mysqlcid-rmkill

mysqlcid-rmkill:
	-@docker kill `cat mysqlcid`
	-@docker rm `cat mysqlcid`
	-@rm mysqlcid

# This one is ephemeral and will not persist data
mysqltemp:
	docker run \
	--cidfile="mysqltemp" \
	--name `cat NAME`-mysqltemp \
	-e MYSQL_ROOT_PASSWORD=`cat MYSQL_PASS` \
	-d \
	mysql:5.6

# This one will import a sql file 
mysqlimport:
	docker run \
	--cidfile="mysqltemp" \
	--name `cat NAME`-mysqltemp \
	-e MYSQL_ROOT_PASSWORD=`cat MYSQL_PASS` \
	-v ./docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d \
	-d \
	mysql:5.6

rmmysqltemp: mysqltemp-rmkill

mysqltemp-rmkill:
	-@docker kill `cat mysqltemp`
	-@docker rm `cat mysqltemp`
	-@rm mysqltemp

rmall: rm rmmysqltemp rmmysql

grab: grabmysqldatadir

grabmysqldatadir:
	-mkdir -p datadir
	docker cp `cat mysqltemp`:/var/lib/mysql  - |sudo tar -C datadir/ -pxvf -
	echo `pwd`/datadir/mysql > MYSQL_DATADIR

MYSQL_DATADIR:
	@while [ -z "$$MYSQL_DATADIR" ]; do \
		read -r -p "Enter the destination of the MySQL data directory you wish to associate with this container [MYSQL_DATADIR]: " MYSQL_DATADIR; echo "$$MYSQL_DATADIR">>MYSQL_DATADIR; cat MYSQL_DATADIR; \
	done ;

MYSQL_PASS:
	@while [ -z "$$MYSQL_PASS" ]; do \
		read -r -p "Enter the MySQL password you wish to associate with this container [MYSQL_PASS]: " MYSQL_PASS; echo "$$MYSQL_PASS">>MYSQL_PASS; cat MYSQL_PASS; \
	done ;
