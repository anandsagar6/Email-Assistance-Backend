# Use official OpenJDK 17 image for Spring Boot
FROM openjdk:17-jdk-slim

# Set working directory inside the container
WORKDIR /app

# Copy built JAR file from Maven target folder
COPY target/*.jar app.jar

# Expose port 8080 for Render
EXPOSE 8080

# Run the Spring Boot JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
