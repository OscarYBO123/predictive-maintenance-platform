# ADR 0001: Monorepo and technology stack

- **Status:** Draft — to be completed in stage 1, step 7
- **Date:** 2026-10-26

## Context

<!-- TODO (step 7): why a monorepo, team size, portfolio goals. -->

## Decision

<!-- TODO (step 7): monorepo layout, Java 25 + Spring Boot 4.1, Angular 22, PostgreSQL 18,
     Kafka (KRaft), Keycloak, Docker Compose, GitHub Actions. -->

### Maven build: root pom as both parent and aggregator

The root `pom.xml` inherits from `spring-boot-starter-parent` and lists every service under
`<modules>`. Each service declares the root pom as its parent.

The root pom also configures the test split inherited by every service:
Surefire runs unit tests (`*Test`, `*Tests`) and Failsafe runs integration tests (`*IT`)
during `integration-test`/`verify`.

### Frontend data fetching: `httpResource`

The frontend fetches data with `httpResource` (`@angular/common/http`), which exposes value,
loading state and error as signals and fits the zoneless, signal-based setup.
`httpResource` is a **stable** API since Angular 22.0 (verified 2026-10-26 on
[angular.dev](https://angular.dev/api/common/http/httpResource) and in the `@publicApi 22.0`
tag of `@angular/common` 22.2.3); it was experimental in earlier versions.

## Consequences

- **Positive:** a single Spring Boot version is shared by all services and bumped in one place;
  plugin configuration (compiler, test split, enforcer) is defined once and inherited.
- **Negative:** every service is coupled to the same Spring Boot version, so services cannot be
  upgraded independently; a breaking upgrade must be handled across all services at once.
- **Mitigation if needed:** a service can drop the root parent and inherit
  `spring-boot-starter-parent` directly while staying listed as a module of the aggregator.

<!-- TODO (step 7): remaining consequences and alternatives considered. -->
