# Toolchain Setup (Java 7 + Maven)

The skill can prepare a **portable, project-local** Java 7 + Maven toolchain when the
machine lacks a compatible one. Everything is placed under `<project>/.toolchain/` and
exported to the **current terminal session** only — nothing is installed system-wide.

## What gets installed

| Component | Version | Why |
|---|---|---|
| JDK | **7 (1.7)** | Matches legacy source/target level. |
| Apache Maven | **3.3.9** | Last Maven 3.3.x line; runs on and builds Java 7 cleanly. Maven 3.5+ requires Java 7+ to run but 3.3.9 is the safest pairing for JDK 7 builds. |

## Running the scripts

```powershell
# Windows PowerShell (dot-source is not required; it edits the session env directly)
.\scripts\setup-java7-maven.ps1 -ProjectRoot "C:\path\to\project" -JdkUrl "<jdk7-zip-url>"
```

```bash
# Linux/macOS/WSL — MUST be sourced so exports persist
source ./scripts/setup-java7-maven.sh "/path/to/project" "<jdk7-tar.gz-url>"
```

After running, verify:

```
java -version   # should report 1.7.x
mvn -version    # should report Apache Maven 3.3.9 using the JDK 7 above
```

## JDK 7 download sources

Oracle JDK 7 requires a login and is not freely redistributable. Prefer a free,
approved build:

- **Azul Zulu 7** (free, no login): https://www.azul.com/downloads/?version=java-7-lts&package=jdk
- **Amazon Corretto** does not provide 7; use Zulu for JDK 7.
- Your organization's internal artifact mirror, if available.

Pass the direct `.zip` (Windows) or `.tar.gz` (Linux/macOS) archive URL via `-JdkUrl` /
the second positional argument. If you omit it, the script downloads Maven only and prints
instructions to place a JDK 7 under `.toolchain/jdk7/`.

## Manual fallback

If downloads are blocked:

1. Obtain a JDK 7 archive and extract it so that `javac` exists at
   `<project>/.toolchain/jdk7/**/bin/javac`.
2. Obtain `apache-maven-3.3.9` and extract it to
   `<project>/.toolchain/maven/apache-maven-3.3.9`.
3. Re-run the setup script; it will detect the existing folders and just export the env.

## PATH persistence

The exports apply to the **current** terminal only. Open a new terminal → run the setup
script again. To persist across sessions, add the `.toolchain` `bin` paths and
`JAVA_HOME`/`M2_HOME` to your shell profile (optional; not done automatically to avoid
polluting the environment).

## Cleanup

Delete `<project>/.toolchain/` to remove everything. Add `.toolchain/` to `.gitignore`
so the downloaded binaries are not committed.
