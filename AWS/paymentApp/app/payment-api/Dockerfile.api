# STAGE 1: Build
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# STAGE 2: Run
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

LABEL maintainer="dominikgadomski654@gmail.com"
LABEL version="1.0.0"
LABEL description="Payment API"

RUN addgroup -S spring && adduser -S spring -G spring

ENV PAYMENT_DB_URL="jdbc:postgresql://localhost:5433/payments"
ENV PAYMENT_DB_USER="payments"
ENV PAYMENT_DB_PASSWORD="payments"
ENV PAYMENT_WORKER_BASE_URL="http://localhost:8090"

COPY --from=builder /build/target/*.jar app.jar

USER spring

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]