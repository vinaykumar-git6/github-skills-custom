# Serving Swagger UI on a Local Port

Run the web app locally so Swagger UI and the spec are reachable, then download the spec.

## Option A: Maven Jetty plugin (no external server)

For a Java 7 build, pin a Jetty plugin version that runs on Java 7 (Jetty 9.2.x line):

```xml
<plugin>
    <groupId>org.eclipse.jetty</groupId>
    <artifactId>jetty-maven-plugin</artifactId>
    <version>9.2.30.v20200428</version>
    <configuration>
        <httpConnector>
            <port>8080</port>
        </httpConnector>
        <webApp>
            <contextPath>/legacy-customer-api</contextPath>
        </webApp>
    </configuration>
</plugin>
```

Run:

```powershell
mvn jetty:run
```

## Option B: Maven Tomcat 7 plugin

```xml
<plugin>
    <groupId>org.apache.tomcat.maven</groupId>
    <artifactId>tomcat7-maven-plugin</artifactId>
    <version>2.2</version>
    <configuration>
        <port>8080</port>
        <path>/legacy-customer-api</path>
    </configuration>
</plugin>
```

```powershell
mvn tomcat7:run
```

## Option C: Deploy the WAR to a local Tomcat

Copy `target/<app>.war` into `<tomcat>/webapps/` and start Tomcat.

## URLs

Assuming context `/legacy-customer-api` on port `8080`:

- Swagger UI: `http://localhost:8080/legacy-customer-api/swagger-ui/?url=/legacy-customer-api/openapi.json`
- Spec (JSON): `http://localhost:8080/legacy-customer-api/openapi.json`
- Spec (YAML): `http://localhost:8080/legacy-customer-api/openapi.yaml`

## Choosing a port

If `8080` is taken, pick another (e.g., `8081`) and update the plugin `port` and the URLs.
Check availability:

```powershell
Test-NetConnection -ComputerName localhost -Port 8080
```

## Stopping the server

Stop the Maven plugin with `Ctrl+C`. If it was started in a background terminal, terminate
that terminal/process before re-running the build.
