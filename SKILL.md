---
name: java-openapi-spec-generator
description: |
  Documents the operations of an existing Java web/API project, then generates an
  OpenAPI 3.0 specification and serves interactive Swagger UI locally. Works for
  legacy Servlet/JAX-RS/Spring projects, including Java 7 codebases.

  Use this skill when the user asks to: document Java API operations, add code
  comments/Javadoc to controllers or servlets, generate an OpenAPI 3 / Swagger
  spec for a Java project, add Swagger/OpenAPI dependencies, build the project with
  Maven, set up (download) Java 7 and Maven and put them on the terminal PATH,
  iteratively compile until the build is clean, run Swagger UI on a local port,
  download the generated openapi spec, or save the OpenAPI/Swagger artifacts inside
  the project folder.

  Do NOT use for: non-Java projects, runtime performance tuning, or deploying the
  API to a cloud environment.
---

# Java OpenAPI Spec Generator

This skill takes an existing Java project (including **legacy Java 7 Servlet** apps) and
produces a documented, standards-compliant **OpenAPI 3.0** specification with a locally
served **Swagger UI**. It is deliberately safe for older toolchains: it can download and
configure **Java 7** and **Maven** and set them on the terminal `PATH` when they are missing.

## Guiding Principles

1. **Document before you generate.** Never invent API behavior. First read the code,
   document every operation with accurate request/response details, then derive the spec
   from that documentation.
2. **Confirm when uncertain.** If an operation's path, method, parameters, status codes,
   or payload shape is ambiguous, **ask the user to confirm** before writing it into the
   spec. Use the `ask_user` tool (or a plain question) — do not guess silently.
3. **Iterate to a clean build.** Compile repeatedly, fixing issues each pass, until
   `mvn clean package` succeeds with no errors.
4. **Keep artifacts in the project.** All generated files (`openapi.yaml`, downloaded
   `openapi.json`, Swagger UI assets) are written **inside the project folder** so they
   are checked in with the source.
5. **Respect the existing Java version.** Detect the project's Java level first. Only
   fall back to Java 7 tooling when the project targets Java 7 or the user requests it.

---

## Workflow

Follow these steps in order. Update a todo list as you progress and mark each step done.

### Step 0: Discover the Project

1. Locate the build file (`pom.xml` or `build.gradle`). This skill's automated path
   targets **Maven**; for Gradle, adapt the equivalent commands.
2. Determine the Java source/target level:
   - Maven: read `maven.compiler.source` / `maven.compiler.target` (or
     `<source>`/`<target>` in the compiler plugin).
3. Identify the API style so you know where operations live:
   - **Servlet** (`javax.servlet.http.HttpServlet`, `web.xml` mappings)
   - **JAX-RS** (`@Path`, `@GET`, `@Produces`)
   - **Spring MVC** (`@RestController`, `@RequestMapping`, `@GetMapping`)
4. Record findings (build tool, Java version, API style, source roots) before continuing.

### Step 1: Document Every Operation (+ Code Comments)

For each endpoint discovered:

1. Read the handler source completely.
2. Determine and record:
   - HTTP **method** and **path** (include path/query params and their types)
   - **Request** body/params (fields, types, required vs optional)
   - **Success response** shape and HTTP status
   - **Error responses** and their status codes (e.g., 400, 404, 500, 503)
   - Content types (usually `application/json`)
3. Add **Javadoc / code comments** to each handler class and method describing the
   operation, parameters, and responses. Keep comments accurate to the code — do not
   change behavior. Only add documentation; do not refactor logic.
4. Produce a concise **operation inventory** (a table) and show it to the user.

> **Confirmation gate:** If any field type, status code, or payload is unclear from the
> code, list your open questions and ask the user to confirm before proceeding to Step 3.
> See [Confirmation Checklist](references/confirmation-checklist.md).

### Step 2: Ensure the Toolchain (Java + Maven)

Check whether `java` and `mvn` are available and match the required version:

```powershell
java -version
mvn -version
```

If missing or the wrong major version (and the project needs **Java 7**), run the setup
script to download portable JDK 7 + Maven and set them on the **current terminal PATH**:

```powershell
# Windows PowerShell
.\scripts\setup-java7-maven.ps1
```

```bash
# Linux/macOS/WSL
./scripts/setup-java7-maven.sh
```

The scripts:
- Download a portable **JDK 7** and **Apache Maven 3.3.9** (last Maven line supporting Java 7 builds well) into a local `.toolchain/` folder inside the project.
- Export `JAVA_HOME`, `M2_HOME`, and prepend both `bin` directories to `PATH` for the
  **current session**.
- Print the resolved versions so you can verify.

See [Toolchain Setup](references/toolchain-setup.md) for download sources, checksums, and
manual fallback instructions.

> **Confirmation gate:** Downloading a JDK/Maven modifies the workspace and network state.
> Show the user exactly what will be downloaded and where, and ask for confirmation before
> running the setup script.

### Step 3: Add OpenAPI/Swagger Dependencies & Serve the Spec

The right approach depends on the Java version:

| Project Java level | Approach | Reference |
|---|---|---|
| **Java 7** (Servlet/JAX-RS) | Hand-author `openapi.yaml` (OpenAPI 3.0) from Step 1, serve it plus **Swagger UI webjar** via a small servlet. Annotation processors for OpenAPI 3 need Java 8+, so a static spec is the reliable path. | [OpenAPI on Java 7](references/openapi-java7-approach.md) |
| **Java 8+ Spring Boot** | Add `springdoc-openapi` — spec is generated automatically at `/v3/api-docs` and UI at `/swagger-ui.html`. | [springdoc approach](references/openapi-spring-approach.md) |
| **Java 8+ JAX-RS** | Add `swagger-core` v2 + `swagger-jaxrs2` annotations. | [swagger-core v2 approach](references/openapi-jaxrs-approach.md) |

For the **Java 7 path** (the default for legacy projects):

1. Create `src/main/resources/openapi/openapi.yaml` — an OpenAPI **3.0.3** document that
   exactly reflects the operation inventory from Step 1. Use the
   [OpenAPI 3 template](templates/openapi.yaml.template) as a starting point.
2. Add the **Swagger UI** webjar dependency to `pom.xml` (see
   [templates/pom-snippet.xml](templates/pom-snippet.xml)).
3. Add the serving components (copy from `templates/`):
   - [`OpenApiSpecServlet.java`](templates/OpenApiSpecServlet.java.template) — serves the
     YAML/JSON spec at `/openapi.yaml` and `/openapi.json`.
   - [`SwaggerUiServlet.java`](templates/SwaggerUiServlet.java.template) or a `web.xml`
     mapping to the Swagger UI webjar at `/swagger-ui/`.
4. Register the servlets in `web.xml`.

### Step 4: Iterative Clean Build

Run a clean build and fix issues each pass until it succeeds:

```powershell
mvn clean package
```

- If compilation fails, read the error, fix the specific cause, and re-run.
- Repeat until `BUILD SUCCESS`.
- Do **not** suppress errors or skip tests to force a pass; fix the root cause.

See [Iterative Build Loop](references/iterative-build.md) for common Java 7 build errors
and fixes.

### Step 5: Run Swagger UI on a Local Port

1. Start the app on a servlet container. For a WAR with no embedded server, use the
   Maven Jetty/Tomcat plugin pinned to a Java 7-compatible version, or deploy the WAR to
   a local Tomcat 7/8.
   ```powershell
   # Example: Jetty plugin (configure a Java 7-compatible version in pom.xml)
   mvn jetty:run
   ```
2. Choose a port (default **8080**; pick another if occupied) and tell the user the URLs:
   - Swagger UI: `http://localhost:<port>/<context>/swagger-ui/`
   - Raw spec: `http://localhost:<port>/<context>/openapi.yaml`

See [Serving Swagger UI](references/serving-swagger-ui.md) for plugin configuration.

### Step 6: Download the Spec into the Project

Once the server is up, download the served spec and save it as a checked-in artifact
inside the project:

```powershell
# PowerShell
Invoke-WebRequest "http://localhost:<port>/<context>/openapi.json" `
  -OutFile ".\openapi\openapi.json"
Invoke-WebRequest "http://localhost:<port>/<context>/openapi.yaml" `
  -OutFile ".\openapi\openapi.yaml"
```

```bash
# bash
curl -s "http://localhost:<port>/<context>/openapi.json" -o ./openapi/openapi.json
curl -s "http://localhost:<port>/<context>/openapi.yaml" -o ./openapi/openapi.yaml
```

Save artifacts to a top-level `openapi/` folder **inside the project**:

```
<project>/
  openapi/
    openapi.yaml     # source of truth (also in src/main/resources/openapi/)
    openapi.json     # downloaded from the running server
    swagger-ui/      # (optional) offline copy of the UI assets
```

### Step 7: Validate & Summarize

1. Validate the downloaded spec is well-formed OpenAPI 3.0 (parse the JSON/YAML; confirm
   `openapi: 3.0.x`, all paths present, no unresolved `$ref`).
2. Cross-check the spec against the Step 1 inventory — every operation and error code
   should be represented.
3. Summarize for the user: endpoints documented, files added/changed, how to re-run the
   UI, and the location of the saved artifacts.

---

## Reference Files

- [Confirmation Checklist](references/confirmation-checklist.md) — when and what to confirm
- [Toolchain Setup](references/toolchain-setup.md) — Java 7 + Maven download & PATH details
- [OpenAPI on Java 7](references/openapi-java7-approach.md) — static spec + Swagger UI webjar
- [springdoc approach](references/openapi-spring-approach.md) — Spring Boot (Java 8+)
- [swagger-core v2 approach](references/openapi-jaxrs-approach.md) — JAX-RS (Java 8+)
- [Iterative Build Loop](references/iterative-build.md) — clean-build troubleshooting
- [Serving Swagger UI](references/serving-swagger-ui.md) — running the UI on a port

## Templates

- [openapi.yaml.template](templates/openapi.yaml.template)
- [pom-snippet.xml](templates/pom-snippet.xml)
- [OpenApiSpecServlet.java.template](templates/OpenApiSpecServlet.java.template)
- [SwaggerUiServlet.java.template](templates/SwaggerUiServlet.java.template)
- [web-xml-snippet.xml](templates/web-xml-snippet.xml)

## Safety & Confirmation Rules

- **Ask before downloading** JDK/Maven or modifying `PATH`.
- **Ask before changing** `pom.xml`/`web.xml` if the change is non-trivial.
- **Never fabricate** API behavior — confirm ambiguous operations with the user.
- **Do not skip tests** or use `-Dmaven.test.skip` to force a green build.
- Only add documentation/comments to code; do not alter runtime behavior while documenting.
