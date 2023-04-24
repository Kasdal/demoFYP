FROM openjdk:8-jre-alpine

ARG APP_VERSION

ARG JAR_NAME

EXPOSE 8080

COPY ./target/${JAR_NAME} /usr/app/

ENTRYPOINT ["java", "-jar", "/usr/app/${JAR_NAME}"]
