# Iterative Build Loop

Goal: reach `BUILD SUCCESS` with `mvn clean package`, fixing the **root cause** each pass.
Never force a green build with `-Dmaven.test.skip`, `-DskipTests`, or by deleting failing code.

## Loop

1. Run:
   ```powershell
   mvn clean package
   ```
2. If it fails, read the **first** error (later errors are often cascades).
3. Fix that specific cause.
4. Re-run. Repeat until success.

## Common Java 7 / legacy build errors

| Symptom | Cause | Fix |
|---|---|---|
| `invalid target release: 1.7` | JDK newer than 7 on PATH, or JDK 7 not found | Run the toolchain setup script; confirm `java -version` is 1.7. |
| `Source option 7 is no longer supported` | Maven compiler plugin running under JDK 20+ | Use the project-local JDK 7 via the setup script (don't rely on system JDK). |
| `package javax.servlet does not exist` | servlet-api not on compile classpath | Ensure the `javax.servlet-api` dependency has `<scope>provided</scope>`. |
| `diamond operator not supported in -source 1.6` | source level too low | Set `maven.compiler.source/target` to `1.7`. |
| `Fatal error compiling: ... release version 7 not supported` | Toolchain mismatch | Pin JDK 7 in `JAVA_HOME`; use Maven 3.3.9. |
| `Failed to execute goal ... maven-war-plugin ... web.xml` | Missing `web.xml` with `failOnMissingWebXml=true` | Provide `src/main/webapp/WEB-INF/web.xml` or set the flag false. |
| Dependency download failures | Offline / blocked repo | Configure an internal mirror in `settings.xml`, or pre-populate `~/.m2`. |

## Verifying the artifact

After success, confirm the WAR/JAR exists:

```powershell
Get-ChildItem .\target\*.war, .\target\*.jar
```

The spec resources (`openapi/openapi.yaml`, `openapi/openapi.json`) and the Swagger UI
webjar should be packaged inside the archive.
