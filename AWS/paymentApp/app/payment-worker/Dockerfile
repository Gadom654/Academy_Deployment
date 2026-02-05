FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# STAGE 2: Run
FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="dominikgadomski654@gmail.com"
LABEL version="1.0.0"
LABEL description="Payment API"

RUN addgroup -S spring && adduser -S spring -G spring

WORKDIR /app
RUN chown spring:spring /app

ENV PAYMENT_WORKER_PORT="8090"
ENV PAYMENT_API_BASE_URL="http://localhost:8080" 
ENV WORKER_CPU_LOAD_MS="500"


COPY --from=builder /build/target/*.jar app.jar
USER spring

EXPOSE 8090
ENTRYPOINT ["java", "-jar", "app.jar"]