# Docker Spring Boot 시작하기
Wonizz, <growuplove7@naver.com>
v0.0.1, 2019-02-26

## [Assignment]
 * link: https://blog.wonizz.tk/2019/02/26/devops-assign/
 
 
안녕하세요, 워니즈입니다.
과제 해결을 위하여 다음의 내용 학습.
 * gradle 정리
 * 배포 구성
 * nginx 웹서버 구성
 * 도커 스웜 레플리카
 * 도커 무중단 배포 
<hr>
이 프로젝트는 간단한 스프링 부트 페이지를 도커로 container를 생성하여 서비스 하고 있습니다. 

 * 언어: Java8+
 * 기준: link:https://spring.io/projects/spring-boot[Spring Boot {boot-ver}]
 * 빌드도구: link:http://maven.apache.org/[{maven}] 혹은 link:https://gradle.org/[{gradle}]
 * IDE: link:https://spring.io/tools/sts[STS(Spring Tool Suite,https://spring.io/tools/sts)] 혹은 link:https://www.jetbrains.com/idea/[IntelliJ]
 * link:https://github.com/ihoneymon/honeymon-spring-boot-starter[`honeymon-spring-boot-starter`(https://goo.gl/RTtZ2q)]

## [개요]
devOps과제로 ``spring-boot-starter``를 사용자 정의하여 만드는 예제를 포함하고 있는 프로젝트다. ``spring-boot-starter``는 ``spring-boot-autoconfigure`` 내에 ``~~AutoConfiguration``과 ``~~Properties`` 클래스가 함께 존재하며 자동구성 클래스라는 것을 정의하는 ``spring.factories`` 설정파일과 애플리케이션 속성파일에서 자동완성을 지원하기 위해 ``additional-spring-configuration-metadata.json``이 함께 필요하다.

사용자정의 ``spring-boot-starter``는 사내에서 프라이빗한 공통사항을 starter로 만들어 스프링 부트 기반으로 애플리케이션 개발시 요긴하게 사용할 수 있다.

## [스프링 도커]
link:https://spring.io/guides/gs/spring-boot-docker/
스프링 도커 관련하여 참고할 수 있는 공식 문서이다. 처음 스프링 부트를 도커를 이용하여 빌드/배포 한다면, 읽기 좋다. 

## [그레이들 빌드]
link:https://medium.com/@goinhacker/%EC%9A%B4%EC%98%81-%EC%9E%90%EB%8F%99%ED%99%94-1-%EB%B9%8C%EB%93%9C-%EC%9E%90%EB%8F%99%ED%99%94-by-gradle-7630c0993d09
``Gradle 을 이용하여 빌드하기``와 간련하여 참고할 수 있는 유용한 블로그이다. 보통 Java를 이용하여 프로젝트를 작성하다보니, gradle 빌드 내용을 한눈에 보기 쉽게 정리해 두었다. 

## [도커 스웜]
link:https://subicura.com/2016/06/07/zero-downtime-docker-deployment.html
``도커 스웜 레플리카 배포``와 간련하여 참고할 수 있는 유용한 블로그이다.

## [도커 빌드/배포 구성]
	-git pull
		https://github.com/wonizz/spring-docker-example 의 프로젝트를 clone하였고, pull을 이용하여 소스를 최신으로 받는다. 
	-gradle build
		현재 경로의 그레이들 툴을 사용하여 source빌드를 수행한다.
	-jar파일 생성
		그레이들 빌드 후, build > libs 경로로 jar파일을 생성한다.
	-이미지 빌드
		생성된 jar파일을 기준으로 docker image build를 수행한다.
	-docker stack deploy(A/B)
		생성된 docker image를 기반으로 compose yml 파일로 배포를 수행한다. 

## [사용법]

### [git clone]
git clone https://github.com/wonizz/spring-docker-example

### [NGINX]
github 에 올라가있는 nginx 경로에서 아래의 내용 수행
 >도커이미지빌드 : docker build -t nginx_spring .
 >도커 container 생성 : docker run --name nginx-spring -d -p 80:80 -p 443:443 nginx_spring

nginx 는 단순 proxy 역할로 volume 마운트는 하지 않았습니다. 

### [빌드]
모든 내용은 프로젝트 내에 devops.sh에 작성되어있습니다. 
 >명령 : ./devops build
 
 빌드 수행시 현재의 경로에서 ``그레이들 빌드``를 수행하여, build > libs 경로에 jar 파일을 생성합니다. 
 이후에, ``도커 이미지 빌드``를 수행하여 도커 이미지를 생성합니다.
 빌드 수행시, 현재의 날짜 + 시간(시분초)로 태깅을 하고, 최신 빌드 수행을 latest로 추가 생성합니다.
 예시)
 
	docker_spring       20190226154956      703ac33aa142        About an hour ago   149MB
	docker_spring       latest              703ac33aa142        About an hour ago   149MB
	docker_spring       20190226142233      a34d7760509f        2 hours ago         149MB

<hr>

### [배포]

  > 명령 : ./devops deploy [option]

  [option] : tag날짜 (optional)
  tag날짜는 ``docker images``로 확인이 가능합니다.
  태그 날짜를 입력하지 않으면, latest로 배포가 됩니다. 
<hr>

### [컨테이너 ]
> 명령 : ./devops restart|start|stop [option]

  [option] : app name(blue/green) [required]
  현재 도커 서비스가 되고 있는 app을 중지,시작,재시작이 가능합니다.
  ``docker service ls``를 통해 확인된 서비스의 도커 컨테이너 관련 명령입니다.

<hr>

### [플로우]
  ``개발자``가 github에 수정한 소스를 ``push``하면, 빌드/배포를 수행합니다.
  ``빌드`` 명령으로 ``도커 이미지``를 생성하고,
  ``배포`` 명령으로 현재 서비를 ``blue/green``배포 방식으로 배포를 합니다.
  ``롤백`` 시에는 ``docker images``에서 롤백이 필요한 이미지로 재배포를 수행합니다.
