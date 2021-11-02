FROM openjdk:17-jdk-alpine
WORKDIR /opt/oreo
RUN addgroup -S oẻo -g 1000 \
    && adduser -u 1000 -S -G oreo -h /home/oreo -s /sbin/nologin oreo \
    && chown oreo:oreo /home/oreo \
    && chown root:oreo /opt/oreo

USER oreo
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /opt/oreo/
EXPOSE 8081
ENTRYPOINT ["java","-jar","/opt/ore/*.jar"]
