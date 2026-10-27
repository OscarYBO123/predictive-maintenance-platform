# ADR 0001: Monorepo and technology stack

- **Status:** Accepted
- **Date:** 2026-10-26

## Context

The platform is a multi-tenant SaaS for industrial predictive maintenance built as a set of
services (core-service, simulator, telemetry-processor, ai-agent) plus an Angular frontend.
It is developed by a single engineer as a portfolio project whose main goal is learning modern
architecture, so the setup must be cheap to maintain, easy to run locally with one command and
easy for a reviewer to clone and understand.

Stage 1 needs a walking skeleton: browser → Angular → Spring Boot → PostgreSQL, built and tested
in CI on every change.

## Decision

### Single repository (monorepo)

All services, the frontend, local infrastructure, docs and CI live in one Git repository:

```
pom.xml                 # Maven parent + aggregator
services/<service>/     # one Spring Boot project per microservice
frontend/               # Angular app
infra/compose/          # docker-compose.yml
docs/                   # PLAN.md and ADRs
.github/                # CI workflow and Dependabot
```

### Stack

| Area      | Choice                                                    | Notes                                          |
|-----------|-----------------------------------------------------------|------------------------------------------------|
| Backend   | Java 25, Spring Boot 4.1.2, virtual threads               | Latest LTS Java; latest stable Boot            |
| Build     | Maven 3.9.16 via wrapper (checksum-pinned)                | Maven 4 still a release candidate              |
| Frontend  | Angular 22 (standalone, signals, zoneless), Vitest, ESLint | CLI defaults for new v22 workspaces            |
| Database  | PostgreSQL 18, Flyway, `ddl-auto=validate`                | Flyway is the single source of truth for schema |
| Testing   | JUnit 6, Testcontainers 2 with `@ServiceConnection`       | Versions managed by the Spring Boot BOM        |
| Local env | Docker Compose; one root `.env` from `.env.example`       | Shared by Compose and core-service             |
| CI        | GitHub Actions, Dependabot                                | Actions pinned by commit SHA                   |

Later stages add Kafka (KRaft), TimescaleDB, Keycloak, Spring AI and pgvector; they get their own
ADRs when introduced.

### Maven build: root pom as both parent and aggregator

The root `pom.xml` inherits from `spring-boot-starter-parent` and lists every service under
`<modules>`. Each service declares the root pom as its parent.

The root pom also configures the test split inherited by every service:
Surefire runs unit tests (`*Test`, `*Tests`) and Failsafe runs integration tests (`*IT`)
during `integration-test`/`verify`. An enforcer rule requires Java 25+ and Maven 3.9+.

### Frontend data fetching: `httpResource`

The frontend fetches data with `httpResource` (`@angular/common/http`), which exposes value,
loading state and error as signals and fits the zoneless, signal-based setup.
`httpResource` is a **stable** API since Angular 22.0 (verified 2026-10-26 on
[angular.dev](https://angular.dev/api/common/http/httpResource) and in the `@publicApi 22.0`
tag of `@angular/common` 22.2.3); it was experimental in earlier versions.

### Configuration and secrets

Configuration comes from environment variables. A single root `.env` (git-ignored, created from
`.env.example`) feeds Docker Compose (`--env-file .env`) and core-service
(`spring.config.import: optional:file:../../.env[.properties]`). There is no default database
password: a missing `POSTGRES_PASSWORD` fails fast in Compose and in the application.

### Continuous integration

`.github/workflows/ci.yml` runs on every pull request and on pushes to `main`, with two parallel
jobs on `ubuntu-24.04`: backend (`./mvnw verify`, including Testcontainers ITs) and frontend
(lint, test, build). The workflow has `permissions: contents: read`, actions are pinned to full
commit SHAs, and test reports are uploaded as artifacts only when a job fails. Dependabot
proposes weekly updates for Maven, npm and GitHub Actions (which also keeps the SHA pins
current); major TypeScript bumps are ignored because Angular defines the supported range.

A ruleset on `main` requires a pull request (no approvals, single maintainer) and green
`Backend (Java 25)` and `Frontend (Node 24)` checks, and blocks force pushes and deletion.

## Alternatives considered

- **Polyrepo (one repository per service):** realistic for large teams, but multiplies CI,
  versioning and cross-repo changes for a single developer. Rejected for now.
- **Gradle instead of Maven:** faster incremental builds, but Maven is the tool the author knows
  best and Spring Initializr supports both equally. Rejected to keep the focus on architecture.
- **Root pom importing only the Spring Boot BOM** (no `spring-boot-starter-parent`): more control,
  but every Boot plugin default would have to be replicated by hand. Rejected.
- **`ddl-auto=update`:** convenient but lets Hibernate change the schema silently. Rejected in
  favour of Flyway migrations validated by Hibernate.
- **H2 in tests:** fast, but behaves differently from PostgreSQL. Rejected in favour of
  Testcontainers with the same PostgreSQL 18 image used in Compose.

## Consequences

- **Positive:** one clone and one Compose command give a working environment; atomic commits can
  change backend, frontend and infrastructure together; one CI workflow covers everything.
- **Positive:** a single Spring Boot version is shared by all services and bumped in one place;
  plugin configuration (compiler, test split, enforcer) is defined once and inherited.
- **Negative:** every service is coupled to the same Spring Boot version, so services cannot be
  upgraded independently; a breaking upgrade must be handled across all services at once.
- **Mitigation if needed:** a service can drop the root parent and inherit
  `spring-boot-starter-parent` directly while staying listed as a module of the aggregator.
- **Negative:** CI builds the whole repository on every change; as services grow, path filters
  per job may be needed to keep runs fast.
- **Negative:** integration tests require Docker, both locally and in CI.
