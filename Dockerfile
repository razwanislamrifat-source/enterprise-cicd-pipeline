FROM maven:3.9.4-amazoncorretto-17 AS builder

LABEL org.opencontainers.image.title="advanced-cicd-app" \
      org.opencontainers.image.description="Advanced CI/CD pipeline demo Spring Boot app" \
      org.opencontainers.image.version="2.0.0" \
      org.opencontainers.image.authors="com.razwan"

WORKDIR /workspace

COPY app/pom.xml ./pom.xml
COPY app/src ./src

RUN mvn -f pom.xml clean package -DskipTests

FROM amazoncorretto:17-alpine

LABEL org.opencontainers.image.title="advanced-cicd-app" \
      org.opencontainers.image.description="Runtime image for advanced-cicd-app" \
      org.opencontainers.image.version="2.0.0" \
      org.opencontainers.image.authors="com.razwan"

WORKDIR /app

COPY --from=builder /workspace/target/advanced-cicd-app-2.0.0.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
