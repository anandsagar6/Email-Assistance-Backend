# Use official JDK 17 image
FROM eclipse-temurin:17-jdk

# Set working directory inside the container
WORKDIR /app

# Copy built JAR from Maven target folder
COPY target/*.jar app.jar

# Expose port 8080 for Render
EXPOSE 8080

# Run the Spring Boot JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
