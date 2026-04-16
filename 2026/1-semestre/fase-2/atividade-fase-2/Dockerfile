FROM tomcat:11-jdk21-temurin

# Force UTF-8 throughout the JVM — fixes JSP source file encoding and response charset
ENV JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8 -Dstdout.encoding=UTF-8 -Dstderr.encoding=UTF-8"

# Download Microsoft SQL Server JDBC driver into Tomcat's shared lib
RUN apt-get update -qq && apt-get install -y -qq curl && \
    curl -fsSL -o /usr/local/tomcat/lib/mssql-jdbc.jar \
    "https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/12.6.3.jre11/mssql-jdbc-12.6.3.jre11.jar" && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the web application
COPY webapp/ /usr/local/tomcat/webapps/agnello/

EXPOSE 8080
