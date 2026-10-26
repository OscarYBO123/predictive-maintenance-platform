# CLAUDE.md — predictive-maintenance-platform

## Qué es este proyecto

Plataforma SaaS multiempresa de **mantenimiento predictivo industrial**. Las máquinas envían
telemetría en tiempo real; el sistema detecta anomalías, las muestra en un dashboard en vivo y
un agente de IA las explica, consulta la agenda de técnicos y programa el mantenimiento.

Es el proyecto de portafolio de Oscar Bautista (Tech Lead Java/Angular, 7 años de experiencia).
Su objetivo es **aprender arquitectura moderna y a dirigir IA**, no solo obtener código.

## Cómo trabajar conmigo (importante)

- Yo decido y tú implementas. Antes de cualquier cambio no trivial, presenta un plan breve y
  espera mi aprobación.
- Trabaja en pasos pequeños y verificables. Corre las pruebas antes de decir que algo está listo.
- Al terminar cada tarea, explícame **en español**, en no más de ~10 líneas: qué hiciste, por qué
  elegiste ese enfoque, qué alternativa descartaste y qué debo revisar yo.
- Si tomas una decisión de arquitectura relevante, regístrala como ADR en `docs/adr/`.
- No inventes versiones: verifica la versión estable actual (start.spring.io, Maven Central, npm)
  antes de fijar una dependencia.
- Si algo es ambiguo, pregúntame en vez de suponer.
- Nunca hagas `git push`, crees repositorios o abras PRs sin que yo lo pida.

## Idiomas

- Código, nombres, comentarios, mensajes de commit, README y ADRs: **inglés**.
- Conversación y explicaciones conmigo: **español**.

## Arquitectura objetivo

```
simulator ──(Kafka: telemetry)──> telemetry-processor ──> TimescaleDB
                                         │
                                         ├──(WebSocket)──> frontend (dashboard en vivo)
                                         └──(Kafka: anomalies)──> core-service / ai-agent

core-service : empresas (tenants), plantas, máquinas, técnicos, alertas, órdenes de trabajo
ai-agent     : Spring AI; explica anomalías y agenda mantenimiento usando herramientas
frontend     : Angular; dashboard, administración y chat con el agente
auth         : Keycloak (OIDC), aislamiento por tenant
```

| Servicio              | Responsabilidad                                   | Etapa |
|-----------------------|---------------------------------------------------|-------|
| `core-service`        | Núcleo SaaS multi-tenant, REST API                | 1–2   |
| `frontend`            | App Angular                                       | 1–3   |
| `simulator`           | Genera telemetría realista e inyecta fallas       | 3     |
| `telemetry-processor` | Consume Kafka, guarda series de tiempo, WebSocket | 3–4   |
| `ai-agent`            | Agente conversacional con herramientas            | 5     |

## Stack

- **Backend:** Java 25, Spring Boot 4.1.x, Spring AI 2.x (etapa 5), Maven con wrapper (`./mvnw`).
  Hilos virtuales habilitados (`spring.threads.virtual.enabled=true`).
- **Frontend:** Angular 22, componentes standalone, signals, zoneless.
- **Datos:** PostgreSQL 18; TimescaleDB (etapa 3); pgvector (etapa 5). Migraciones con Flyway.
- **Mensajería:** Apache Kafka en modo KRaft (sin ZooKeeper).
- **Seguridad:** Keycloak (etapa 2).
- **Pruebas:** JUnit (versión gestionada por Spring Boot), Testcontainers para integración.
- **Infra:** Docker Compose en local, GitHub Actions para CI.

## Estructura del repositorio

```
pom.xml                 # agregador Maven de services/*
services/<servicio>/    # un proyecto Spring Boot por microservicio
frontend/               # app Angular
infra/compose/          # docker-compose.yml y configuración local
docs/adr/               # Architecture Decision Records
.github/workflows/      # CI
```

## Comandos

> Mantén esta sección actualizada cuando cambien los comandos.

- Levantar infraestructura: `docker compose -f infra/compose/docker-compose.yml up -d`
- Compilar y probar todo el backend: `./mvnw verify`
- Ejecutar un servicio: `./mvnw -pl services/core-service spring-boot:run`
- Frontend: `cd frontend && npm ci && npm start` · pruebas: `npm test`

## Convenciones

- **Paquete base:** `io.github.<usuario-github>.pmp.<servicio>`
  (obtén el usuario con `gh api user -q .login`).
- Organización por funcionalidad (package-by-feature), no por capa técnica.
- DTOs como `record`; inyección por constructor; sin Lombok.
- API REST versionada (`/api/v1/...`), documentada con springdoc-openapi.
- Configuración por variables de entorno. **Nunca** secretos en el repo; usa `.env.example`.
- Toda lógica de negocio con pruebas unitarias; integración con Testcontainers.
- Git: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`),
  ramas `feat/<tema>`, commits pequeños, `main` siempre compila.

## Estado actual

- **Etapa actual:** 1 — Cimientos (walking skeleton). En progreso.
- **Entorno:** Ubuntu, Java 25, Node 24, Angular CLI 22, Docker 29, Compose 5, GitHub CLI.

### Roadmap

1. Cimientos: monorepo, core-service mínimo, frontend mínimo, Postgres en Compose, CI.
2. Núcleo SaaS: tenants, plantas, máquinas, técnicos; Keycloak.
3. Telemetría en vivo: simulator → Kafka → telemetry-processor → TimescaleDB → WebSocket.
4. Detección de anomalías y alertas.
5. Agente de IA con Spring AI (chat web; después Telegram/WhatsApp).
6. Producción: Kubernetes, Prometheus/Grafana, despliegue en la nube, documentación final.
