#!/usr/bin/env bash
#
# setup-java7-maven.sh
#
# Downloads a portable JDK 7 and Apache Maven 3.3.9 into a local .toolchain/
# folder and exports JAVA_HOME, M2_HOME and PATH for the CURRENT shell session.
#
# Used by the java-openapi-spec-generator skill to prepare a Java 7 build
# environment. Nothing is installed system-wide; everything lives under the
# project's .toolchain/ directory.
#
# IMPORTANT: source this script so the exports persist in your shell:
#     source ./setup-java7-maven.sh
#
# JDK 7 binaries usually require an approved mirror. Azul Zulu publishes free
# JDK 7 builds: https://www.azul.com/downloads/?version=java-7-lts&package=jdk
#
# Usage:
#     source ./setup-java7-maven.sh [PROJECT_ROOT] [JDK_URL] [MAVEN_URL]

set -euo pipefail

PROJECT_ROOT="${1:-$(pwd)}"
JDK_URL="${2:-}"
MAVEN_URL="${3:-https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz}"

TOOLCHAIN="${PROJECT_ROOT}/.toolchain"
mkdir -p "${TOOLCHAIN}"

download_extract_tar() {
    local url="$1" dest="$2"
    echo "Downloading ${url}"
    curl -fSL "${url}" -o "${dest}/archive.tar.gz"
    echo "Extracting into ${dest}"
    tar -xzf "${dest}/archive.tar.gz" -C "${dest}"
    rm -f "${dest}/archive.tar.gz"
}

# --- JDK 7 ---
JDK_DIR="${TOOLCHAIN}/jdk7"
mkdir -p "${JDK_DIR}"
if [ ! -x "$(find "${JDK_DIR}" -name javac -type f 2>/dev/null | head -n1)" ]; then
    if [ -z "${JDK_URL}" ]; then
        cat <<EOF
WARNING: No JDK 7 URL provided. JDK 7 usually requires an approved mirror.
Options:
  1. Re-run: source ./setup-java7-maven.sh "${PROJECT_ROOT}" "<jdk7-tar.gz-url>"
  2. Manually extract a JDK 7 under: ${JDK_DIR}
Azul Zulu free JDK 7: https://www.azul.com/downloads/?version=java-7-lts&package=jdk
EOF
    else
        download_extract_tar "${JDK_URL}" "${JDK_DIR}"
    fi
fi

# Resolve JAVA_HOME (archive usually extracts to a nested folder).
JAVA_HOME_RESOLVED="$(dirname "$(dirname "$(find "${JDK_DIR}" -name javac -type f 2>/dev/null | head -n1)")")" || true

# --- Maven 3.3.9 ---
MAVEN_DIR="${TOOLCHAIN}/maven"
mkdir -p "${MAVEN_DIR}"
if [ ! -d "${MAVEN_DIR}/apache-maven-3.3.9" ]; then
    download_extract_tar "${MAVEN_URL}" "${MAVEN_DIR}"
fi
M2_HOME_RESOLVED="${MAVEN_DIR}/apache-maven-3.3.9"

# --- Export for current session ---
if [ -n "${JAVA_HOME_RESOLVED:-}" ] && [ -d "${JAVA_HOME_RESOLVED}" ]; then
    export JAVA_HOME="${JAVA_HOME_RESOLVED}"
    export PATH="${JAVA_HOME}/bin:${PATH}"
    echo "JAVA_HOME = ${JAVA_HOME}"
else
    echo "WARNING: JAVA_HOME not set (JDK 7 not found). Provide a JDK_URL or extract manually."
fi

if [ -d "${M2_HOME_RESOLVED}" ]; then
    export M2_HOME="${M2_HOME_RESOLVED}"
    export PATH="${M2_HOME}/bin:${PATH}"
    echo "M2_HOME   = ${M2_HOME}"
fi

echo ""
echo "Verifying toolchain..."
java -version || echo "WARNING: java not runnable yet."
mvn -version || echo "WARNING: mvn not runnable yet."

echo ""
echo "Toolchain ready for this session. 'source' this script again in new terminals."
