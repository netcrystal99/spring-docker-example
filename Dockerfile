FROM openjdk:8-jdk-alpine
VOLUME /tmp
COPY build/libs/spring-docker-example-1.1.0.RELEASE.jar app.jar
RUN /bin/sh -c "apk add --no-cache bash"
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
