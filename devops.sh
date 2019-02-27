#!/bin/bash

#0.Arguments
ARG=($@)
CMD=`git pull`
PARAM1=${ARG[0]}
PARAM2=${ARG[1]}

#[BUILD]
if [[ "$PARAM1" =~ "build" ]]; then
	#1. if source is not changed, build stop
	if [[ "$CMD" =~ "Already up-to-date." ]]; then
		echo "changed Nothing!"
		#exit 1;
	fi

	#2. gradle build
	#3. Dockerfile image build
        NOW=`echo $(date +%Y%m%d%H%M%S)`
	CMD=`./gradlew clean build && docker build -t docker_spring:$NOW .`
	if [[ "$CMD" =~ "Successfully" ]]; then
		CMD=`docker tag docker_spring:$NOW docker_spring:latest`
		echo "build success!"
	fi
#[DEPLOY]
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
			echo "blue app container loaded"
		#4-2. docker stack deploy (green)
		else
			sleep 10
			CMD=`env TAG=$TAG docker stack deploy -c docker-compose_green.yml green`
		        sleep 60
			CMD=`docker stack rm blue`
			echo "green app container loaded"
		fi
		sleep 15
		CMD=`docker rm $(docker ps --filter 'status=exited' -a -q)`
	
#5. all container restart
elif [[ "$PARAM1" =~ "restart" ]] || [[ "$PARAM1" =~ "stop" ]] ||  [[ "$PARAM1" =~ "start" ]]; then
	if [[ "$PARAM2" =~ "blue" ]] ||  [[ "$PARAM2" =~ "green" ]]; then	
		if [[ "$PARAM1" =~ "restart" ]]; then
			CMD=`docker service rm  $PARAM2"_app"`
			sleep 60
			CMD=`env TAG=latest docker stack deploy -c docker-compose_$PARAM2.yml $PARAM2`
			echo "docker container restared!"
		#6. all container stop
		elif [[ "$PARAM1" =~ "stop" ]]; then
			CMD=`docker service rm  $PARAM2"_app"`
			sleep 30
			echo "docker container stopped!"
		#7. all container start
		elif [[ "$PARAM1" =~ "start" ]]; then
			CMD=`env TAG=latest docker stack deploy -c docker-compose_$PARAM2.yml $PARAM2`
			sleep 30
			echo "docker contaeiner stared!"
		fi
	else
		echo "blue or green app only applied!"
	fi
else	
	echo "Undefined Command!"
fi
