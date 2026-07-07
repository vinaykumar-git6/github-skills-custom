# java-openapi-spec-generator

A GitHub Copilot **skill** that documents an existing Java project's API operations, then
generates an **OpenAPI 3.0** specification and serves interactive **Swagger UI** locally —
including on **legacy Java 7 Servlet** codebases.

## What it does

1. **Documents operations** — reads controllers/servlets and adds accurate Javadoc/comments.
2. **Understands request/response** — builds an operation inventory (params, payloads,
   status codes) and **asks the user to confirm** anything ambiguous.
3. **Adds Swagger/OpenAPI dependencies** — appropriate to the project's Java version.
4. **Generates an OpenAPI 3.0 spec** — from the confirmed inventory.
5. **Prepares the toolchain** — can download **Java 7 + Maven 3.3.9** into a project-local
   `.toolchain/` folder and set `JAVA_HOME`/`M2_HOME`/`PATH` for the terminal session.
6. **Iterative clean build** — runs `mvn clean package` repeatedly until `BUILD SUCCESS`.
7. **Serves Swagger UI** on a local port (Jetty/Tomcat plugin or WAR deploy).
8. **Downloads the spec** and saves artifacts inside the project's `openapi/` folder.

## Layout

```
java-openapi-spec-generator/
  SKILL.md                       # main workflow the agent follows
  VERSION
  README.md
  scripts/
    setup-java7-maven.ps1        # Windows toolchain setup
    setup-java7-maven.sh         # Linux/macOS/WSL toolchain setup (source it)
  references/
    confirmation-checklist.md
    toolchain-setup.md
    openapi-java7-approach.md    # static spec + Swagger UI webjar (default for Java 7)
    openapi-spring-approach.md   # springdoc (Spring Boot, Java 8+)
    openapi-jaxrs-approach.md    # swagger-core v2 (JAX-RS, Java 8+)
    iterative-build.md
    serving-swagger-ui.md
  templates/
    openapi.yaml.template
    pom-snippet.xml
    OpenApiSpecServlet.java.template
    SwaggerUiServlet.java.template
    web-xml-snippet.xml
```

## Usage

Ask Copilot something like:

> "Document my Java API operations and generate an OpenAPI 3 spec with Swagger UI. If the
> build tools are missing, set up Java 7 and Maven."

The agent will load `SKILL.md` and follow the workflow, pausing to confirm ambiguous
operations and before any downloads or non-trivial config changes.

## Safety

- Asks before downloading a JDK/Maven or modifying `PATH`.
- Never fabricates API behavior — confirms unclear operations with you.
- Does not skip tests or suppress errors to force a green build.
- Only adds documentation to code while documenting; does not change runtime behavior.

## Notes on Java 7 + OpenAPI 3

Annotation-based OpenAPI 3 generators (springdoc, swagger-core v2) require Java 8+. For
Java 7 the skill hand-authors the spec and serves it with the static **swagger-ui** webjar,
keeping everything Java 7-compatible.
