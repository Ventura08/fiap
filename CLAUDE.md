# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a FIAP university coursework repository, organized by academic year and semester. It contains multiple independent projects across different technologies — there is no single build system for the whole repo.

## Structure

- `2025/voltz-2025/` — Java + Maven project (crypto wallet system) using Oracle DB
- `2025/gs/` — Global Solutions assignment (zipped)
- `2026/1-semestre/fase-1/` — Android (Kotlin/Jetpack Compose) apps and HTML pages

## Build & Run Commands

### Voltz 2025 (Java/Maven)

```bash
cd 2025/voltz-2025
# With Maven
mvn clean compile
mvn exec:java -Dexec.mainClass="org.example.Main"

# Local Oracle DB
docker-compose up -d
```

SQL scripts run order: `DDL_Script.sql` first, then `DML_Script.sql`. Use `RESET_DB.sql` to wipe and start over.

Note: `pom.xml` sets `<sourceDirectory>` to project root (not `src/main/java`), so Java files live at the top level of that directory.

### Android Apps (2026/fase-1)

Each app (`ColumnRow`, `BoxApp`, `android`) is a standalone Android Studio/Gradle project using Kotlin and Jetpack Compose.

```bash
cd 2026/1-semestre/fase-1/<AppName>
./gradlew assembleDebug
./gradlew test
```

## Key Notes

- Projects are independent — changes in one folder don't affect others.
- The Voltz project connects to FIAP's Oracle DB by default; switch to local Docker Oracle by editing `DatabaseConnection.java` connection strings.
