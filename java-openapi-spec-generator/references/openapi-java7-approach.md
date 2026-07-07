# OpenAPI on Java 7 (Static Spec + Swagger UI Webjar)

Annotation-driven OpenAPI **3.0** generators (`springdoc`, `swagger-core` v2) require
**Java 8+**. For a Java 7 Servlet/JAX-RS app the reliable approach is:

1. **Hand-author** an OpenAPI 3.0 document from the Step 1 operation inventory.
2. **Serve** that document plus the **Swagger UI** static assets from the web app.

This keeps the whole thing Java 7-compatible and dependency-light.

## 1. Author the spec

Create `src/main/resources/openapi/openapi.yaml` using
[templates/openapi.yaml.template](../templates/openapi.yaml.template). Fill in:

- `info` (title, version, description)
- `servers` (context path)
- `paths` — one entry per documented operation, with parameters, request bodies,
  responses, and **every** status code (200/400/404/500/503, etc.)
- `components/schemas` — the model objects (Customer, Account, Error)
- `components/securitySchemes` — if the API uses auth

## 2. Serve the spec

Add [OpenApiSpecServlet.java](../templates/OpenApiSpecServlet.java.template) to the project.
It reads the classpath resource `openapi/openapi.yaml` and serves it at:

- `/openapi.yaml` (as `application/yaml`)
- `/openapi.json` (converted to JSON) — optional; if you don't want a YAML→JSON
  dependency, also hand-author `openapi.json` and serve it directly.

To avoid adding a YAML parser on Java 7, the simplest robust option is to author **both**
`openapi.yaml` and `openapi.json` and have the servlet stream whichever is requested. The
downloaded `openapi.json` is then a byte-for-byte copy — no runtime conversion needed.

## 3. Serve Swagger UI

Add the Swagger UI **webjar** to `pom.xml` (see
[templates/pom-snippet.xml](../templates/pom-snippet.xml)):

```xml
<dependency>
    <groupId>org.webjars</groupId>
    <artifactId>swagger-ui</artifactId>
    <version>3.52.5</version> <!-- 3.x line works well from static hosting -->
</dependency>
```

Webjar assets are on the classpath under
`META-INF/resources/webjars/swagger-ui/3.52.5/`. Two ways to expose them:

- **Servlet container default**: Servlet 3.0+ containers automatically serve
  `META-INF/resources/` content, so `/webjars/swagger-ui/3.52.5/index.html` may work with
  no code. Configure that `index.html` to point at `/<context>/openapi.json`.
- **Explicit servlet**: use [SwaggerUiServlet.java](../templates/SwaggerUiServlet.java.template)
  to map `/swagger-ui/*` to the webjar resources and inject the spec URL.

## 4. Point the UI at the spec

Swagger UI needs the spec URL. Provide a tiny `swagger-initializer` or query param:

```
http://localhost:8080/<context>/swagger-ui/?url=/<context>/openapi.json
```

## Version notes

- `swagger-ui` webjar **3.x** is static JS/CSS and renders OpenAPI 3.0 fine; it does not
  require Java 8 at build or run time.
- Keep the webjar at a 3.x version for maximum compatibility with older containers.
