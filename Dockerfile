# Step 1: Build stage (use Maven wrapper inside container)
FROM eclipse-temurin:17-jdk AS builder

WORKDIR /app
COPY . .
RUN ./mvnw clean package -DskipTests

# Step 2: Run stage (use smaller image for final JAR)
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy the built JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
