<#
.SYNOPSIS
    Downloads a portable JDK 7 and Apache Maven 3.3.9 into a local .toolchain/
    folder and sets JAVA_HOME, M2_HOME and PATH for the CURRENT PowerShell session.

.DESCRIPTION
    Used by the java-openapi-spec-generator skill to prepare a Java 7 build
    environment on machines that do not already have a compatible toolchain.

    Nothing is installed system-wide; everything lives under the project's
    .toolchain/ directory so it can be removed by deleting that folder.

.PARAMETER ProjectRoot
    The project root where the .toolchain/ folder will be created. Defaults to
    the current directory.

.PARAMETER JdkUrl
    Override the JDK 7 download URL (e.g. an internal mirror or Zulu/Temurin/Corretto
    archive). Must point to a .zip containing a JDK 7 layout.

.PARAMETER MavenUrl
    Override the Maven download URL. Defaults to Apache Maven 3.3.9 (Java 7 friendly).

.NOTES
    Public JDK 7 binaries are not always freely redistributable. Prefer an
    organization-approved mirror. Azul Zulu publishes free JDK 7 builds:
    https://www.azul.com/downloads/?version=java-7-lts&package=jdk
#>
[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path,
    [string]$JdkUrl,
    [string]$MavenUrl = "https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.zip"
)

$ErrorActionPreference = "Stop"

$toolchain = Join-Path $ProjectRoot ".toolchain"
New-Item -ItemType Directory -Force -Path $toolchain | Out-Null

function Expand-Download {
    param([string]$Url, [string]$OutFile, [string]$DestDir)
    Write-Host "Downloading $Url" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $Url -OutFile $OutFile
    Write-Host "Extracting to $DestDir" -ForegroundColor Cyan
    Expand-Archive -Path $OutFile -DestinationPath $DestDir -Force
}

# --- JDK 7 ---
$jdkDir = Join-Path $toolchain "jdk7"
if (-not (Test-Path $jdkDir)) {
    if (-not $JdkUrl) {
        Write-Warning @"
No JDK 7 URL was provided. JDK 7 binaries usually require an approved mirror.
Options:
  1. Re-run with -JdkUrl '<url-to-jdk7-zip>' (e.g. an Azul Zulu 7 .zip).
  2. Manually place an extracted JDK 7 under: $jdkDir
Azul Zulu free JDK 7 downloads:
  https://www.azul.com/downloads/?version=java-7-lts&package=jdk
"@
    } else {
        Expand-Download -Url $JdkUrl -OutFile (Join-Path $toolchain "jdk7.zip") -DestDir $jdkDir
    }
}

# The archive typically extracts to a nested folder; find the real JAVA_HOME.
$javaHome = Get-ChildItem -Path $jdkDir -Directory -ErrorAction SilentlyContinue |
    Where-Object { Test-Path (Join-Path $_.FullName "bin\javac.exe") } |
    Select-Object -First 1 -ExpandProperty FullName
if (-not $javaHome -and (Test-Path (Join-Path $jdkDir "bin\javac.exe"))) {
    $javaHome = $jdkDir
}

# --- Maven 3.3.9 ---
$mavenDir = Join-Path $toolchain "maven"
if (-not (Test-Path (Join-Path $mavenDir "apache-maven-3.3.9"))) {
    Expand-Download -Url $MavenUrl -OutFile (Join-Path $toolchain "maven.zip") -DestDir $mavenDir
}
$m2Home = Join-Path $mavenDir "apache-maven-3.3.9"

# --- Export environment for the CURRENT session ---
if ($javaHome) {
    $env:JAVA_HOME = $javaHome
    $env:PATH = (Join-Path $javaHome "bin") + [IO.Path]::PathSeparator + $env:PATH
    Write-Host "JAVA_HOME = $env:JAVA_HOME" -ForegroundColor Green
} else {
    Write-Warning "JAVA_HOME not set (JDK 7 not found). Provide -JdkUrl or extract manually."
}

if (Test-Path $m2Home) {
    $env:M2_HOME = $m2Home
    $env:PATH = (Join-Path $m2Home "bin") + [IO.Path]::PathSeparator + $env:PATH
    Write-Host "M2_HOME   = $env:M2_HOME" -ForegroundColor Green
}

Write-Host "`nVerifying toolchain..." -ForegroundColor Cyan
try { & java -version } catch { Write-Warning "java not runnable yet." }
try { & mvn -version } catch { Write-Warning "mvn not runnable yet." }

Write-Host "`nToolchain ready for this session. Re-run this script in new terminals." -ForegroundColor Green
