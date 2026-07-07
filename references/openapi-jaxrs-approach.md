# swagger-core v2 Approach (JAX-RS, Java 8+)

Use this only when the project is **JAX-RS on Java 8+**. swagger-core v2 scans JAX-RS
annotations and produces OpenAPI 3.

## Dependencies

```xml
<dependency>
    <groupId>io.swagger.core.v3</groupId>
    <artifactId>swagger-jaxrs2</artifactId>
    <version>2.2.15</version>
</dependency>
<dependency>
    <groupId>io.swagger.core.v3</groupId>
    <artifactId>swagger-jaxrs2-servlet-initializer</artifactId>
    <version>2.2.15</version>
</dependency>
```

## Enrich with annotations

```java
@Path("/customers")
public class CustomerResource {

    @GET
    @Path("/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Get customer by id",
        responses = {
            @ApiResponse(responseCode = "200", description = "Found"),
            @ApiResponse(responseCode = "404", description = "Not found")
        })
    public Customer get(@PathParam("id") String id) { ... }
}
```

## Spec endpoint

Configure the `OpenApiServlet` / initializer to expose `/openapi.json` and `/openapi.yaml`.
Then serve Swagger UI via the webjar (see the Java 7 approach doc — the UI part is identical).

## Download the spec

```bash
curl -s http://localhost:8080/openapi.json -o ./openapi/openapi.json
curl -s http://localhost:8080/openapi.yaml -o ./openapi/openapi.yaml
```
