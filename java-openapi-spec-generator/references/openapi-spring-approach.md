# springdoc-openapi Approach (Spring Boot, Java 8+)

Use this only when the project is **Spring Boot on Java 8+**. It auto-generates the
OpenAPI 3 spec from your controllers.

## Dependency

```xml
<!-- Spring Boot 2.x -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-ui</artifactId>
    <version>1.7.0</version>
</dependency>
```

For Spring Boot 3.x use `springdoc-openapi-starter-webmvc-ui` (2.x).

## Endpoints (automatic)

- Spec JSON: `/v3/api-docs`
- Spec YAML: `/v3/api-docs.yaml`
- Swagger UI: `/swagger-ui.html`

## Enrich with annotations

```java
@Operation(summary = "Get customer by id", description = "Returns a single customer")
@ApiResponses({
    @ApiResponse(responseCode = "200", description = "Found"),
    @ApiResponse(responseCode = "404", description = "Customer not found")
})
@GetMapping("/api/customers/{id}")
public Customer getCustomer(@PathVariable String id) { ... }
```

## Download the spec

```bash
curl -s http://localhost:8080/v3/api-docs -o ./openapi/openapi.json
curl -s http://localhost:8080/v3/api-docs.yaml -o ./openapi/openapi.yaml
```
