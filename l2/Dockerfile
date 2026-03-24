# Use OpenJDK as the base image
FROM eclipse-temurin:21

# Copy the SSL certificate into the container
# COPY ./cert-file/cert.cer /usr/local/share/ca-certificates/cert.crt

# Install the updated certificate
# RUN update-ca-certificates
# RUN keytool -importcert \
#     -trustcacerts \
#     -alias company-root-ca \
#     -file /usr/local/share/ca-certificates/cert.crt \
#     -keystore "${JAVA_HOME}/lib/security/cacerts" \
#     -storepass changeit -noprompt

# Install Maven for the build environment
RUN apt-get update && apt-get install -y maven

# Set working directory
WORKDIR /app

COPY ./L2-dp-webapi/ /app

RUN mvn clean install -DskipTests=true

# Copy the application JAR file
RUN cp /app/target/dp-http-0.0.1-SNAPSHOT.jar app.jar

# Run the application
CMD ["java", "-jar", "app.jar"]

