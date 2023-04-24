FROM openjdk:8-jre-alpine

ARG JAR_NAME

EXPOSE 8080

COPY ./target/${JAR_NAME} /usr/app/

ENTRYPOINT ["sh", "-c", "java -jar /usr/app/${JAR_NAME}"]
