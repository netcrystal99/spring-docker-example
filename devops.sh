#!/bin/bash

ARG=($@)
CMD=`git pull`
PARAM1=${ARG[0]}
PARAM2=${ARG[1]}


if [[ "$PARAM1" =~ "build" ]]; then
	#1. if source is not changed, build stop
	#if [[ "$CMD" =~ "Already up-to-date." ]]; then
	#	echo "changed Nothing!"
	#	exit 1;
	#fi

	#2. gradle build
	#3. Dockerfile image build
        NOW=`echo $(date +%Y%m%d%H%M%S)`
	CMD=`./gradlew clean build && docker build -t docker_spring:$NOW .`
	if [[ "$CMD" =~ "Successfully" ]]; then
		CMD=`docker tag docker_spring:$NOW docker_spring:latest`
		echo "build success!"
	fi
elif [[ "$PARAM1" =~ "deploy" ]]; then
	if [[ -n "$PARAM2" ]]; then
		TAG=$PARAM2
	else
		TAG="latest"
	fi
		#4-1. docker stack deploy (blue)
		EXIST_BLUE=`docker ps -a | grep blue | egrep -v 'Exited'`
		echo $EXIST_BLUE
		if [ -z "$EXIST_BLUE" ]; then
			CMD=`env TAG=$TAG docker stack deploy -c docker-compose_blue.yml blue`
			sleep 60
			CMD=`docker stack rm green`
			#CMD=`docker stop $(docker ps -a -f 'name=green_app' -q)`
			echo "blue app container loaded"
		#4-2. docker stack deploy (green)
		else
			sleep 10
			CMD=`env TAG=$TAG docker stack deploy -c docker-compose_green.yml green`
		        sleep 60
			CMD=`docker stack rm blue`
		        #CMD=`docker stop $(docker ps -a -f 'name=blue_app' -q)`
			echo "green app container loaded"
		fi
		sleep 15
		CMD=`docker rm $(docker ps --filter 'status=exited' -a -q)`
	
#5. all container restart
elif [[ "$PARAM1" =~ "restart" ]]; then
	CMD=`docker restart $(docker ps -a -q)`
#6. all container stop
elif [[ "$PARAM1" =~ "stop" ]]; then
	CMD=`docker stop $(docker ps -a -q)`
#7. all container start
elif [[ "$PARAM1" =~ "start" ]]; then
	CMD=`docker start $(docker ps -a -q)`

else	
	echo "Undefined Command!"
fi