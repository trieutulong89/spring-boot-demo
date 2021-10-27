FROM openjdk:17-jdk-alpine
RUN addgroup -g 1000 -S oreo && adduser -u 1000 -S oreo -G oreo
USER oreo
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
EXPOSE 8081
ENTRYPOINT ["java","-jar","/app.jar"]
