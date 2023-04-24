FROM openjdk:8-jre-alpine

ARG APP_VERSION

EXPOSE 8080

COPY ./target/java-maven-app-${APP_VERSION}.jar /usr/app/
WORKDIR /usr/app

CMD java -jar java-maven-app-${APP_VERSION}.jar
