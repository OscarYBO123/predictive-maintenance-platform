# Plan de trabajo — predictive-maintenance-platform

> Lista de todo lo que vamos a construir, en orden. Se marca `[x]` al terminar cada paso.
> Leyenda: `[x]` hecho · `[~]` en curso · `[ ]` pendiente · 🧑‍💻 lo hace Oscar en modo práctica

---

## Etapa 1 — Cimientos ("walking skeleton")

**Objetivo:** un esqueleto mínimo que atraviese todas las capas y funcione de punta a punta.
Todavía no hace nada útil, pero demuestra que todas las piezas se conectan.

- [x] **1. Repositorio y archivos base** — Git, README, `.gitignore`, `.gitattributes`.
  *Por qué:* es la carpeta oficial del proyecto y su historial de cambios.
- [x] **2. Maven parent + wrapper** — `pom.xml` raíz y `./mvnw`.
  *Por qué:* un solo lugar para fijar las versiones de todos los servicios, y un build que
  funciona igual en cualquier máquina.
- [x] **3. core-service mínimo** — Spring Boot con `GET /api/v1/ping`, health check y pruebas.
  *Por qué:* es el primer backend; prueba que Java, Spring y las pruebas funcionan.
- [x] **4. Frontend mínimo** — app Angular que llama al ping y muestra la respuesta.
  *Por qué:* prueba que el navegador puede hablar con el backend.
- [x] **5. PostgreSQL con Docker Compose** — base de datos levantada con un solo comando.
  *Por qué:* nada se instala en tu máquina; todo corre en contenedores.
- [x] **6. Prueba de punta a punta** — navegador → Angular → Spring → PostgreSQL.
  *Por qué:* confirmar que todo el camino funciona junto.
- [x] **7. CI y ADR 0001** — GitHub Actions compila y prueba en cada cambio; documentar decisiones.
  *Por qué:* nadie puede subir código roto sin que se note.
- [x] **8. Publicar en GitHub** — crear el repo, hacer push y ver el CI en verde.
  Repo: https://github.com/OscarYBO123/predictive-maintenance-platform

## Etapa 2 — Núcleo SaaS

**Objetivo:** la parte "administrativa": empresas, plantas, máquinas y técnicos, con login.

- [~] **1. Modelo de datos** — tablas con migraciones de Flyway.
  - Claude: migración V2 con `tenants` y `plants` (patrón de referencia).
  - 🧑‍💻 Migración V3 con `machines` y `technicians`.
- [ ] **2. API REST** — crear, consultar, editar y borrar, con validaciones y documentación OpenAPI.
  - Claude: CRUD de `plants` (patrón de referencia).
  - 🧑‍💻 CRUD de `machines` con sus pruebas.
- [ ] **3. Keycloak** — servidor de login; el frontend inicia sesión con OIDC.
  - Claude: Keycloak en Compose, realm exportado, resource server y login en Angular.
  - 🧑‍💻 Crear a mano un usuario, un rol y una organización en la consola y compararlo con el realm.
- [ ] **4. Multi-tenant** — cada empresa solo ve sus propios datos.
  - Claude: aislamiento por tenant (pieza de seguridad crítica).
  - 🧑‍💻 Prueba de aislamiento: el tenant A no puede ver ni modificar datos del tenant B.
- [ ] **5. Pantallas de administración** en Angular.
  - Claude: lista y formulario de plantas (componentes base, guards, errores).
  - 🧑‍💻 Pantallas de máquinas.
- [ ] **6. Flujo profesional** — a partir de aquí, trabajar con ramas y pull requests.
  - Claude: plantilla de PR y `CODEOWNERS` (protección de `main` ya configurada).
  - 🧑‍💻 Revisar un PR de Claude y dejar comentarios en GitHub.

## Etapa 3 — Telemetría en vivo

**Objetivo:** máquinas virtuales que envían datos y un dashboard que los muestra al instante.

- [ ] **1. Kafka en Docker Compose** (modo KRaft).
- [ ] **2. simulator** — máquinas virtuales con datos realistas y un botón para provocar fallas.
- [ ] **3. telemetry-processor** — lee de Kafka y guarda en TimescaleDB.
- [ ] **4. WebSocket** — empuja los datos al navegador en tiempo real.
- [ ] **5. Dashboard** — gráficas en vivo por máquina.

## Etapa 4 — Detección de anomalías

**Objetivo:** que el sistema se dé cuenta solo de que algo anda mal.

- [ ] **1. Reglas por umbral** — por ejemplo, "temperatura mayor a 90 °C".
- [ ] **2. Estadística simple** — detectar valores fuera de lo normal para esa máquina.
- [ ] **3. Eventos de anomalía** — se publican en Kafka y core-service crea la alerta.
- [ ] **4. Alertas en el dashboard.**

## Etapa 5 — Agente de IA

**Objetivo:** un asistente que explica la falla y agenda al técnico.

- [ ] **1. ai-agent con Spring AI** — conectado a un modelo de lenguaje.
- [ ] **2. Herramientas del agente** — consultar máquinas, telemetría y agenda; agendar
  mantenimiento (siempre con confirmación).
- [ ] **3. Chat en Angular.**
- [ ] **4. RAG con pgvector** — el agente consulta manuales de las máquinas.
- [ ] **5. Canal externo** — Telegram (opcional); WhatsApp como extra.

## Etapa 6 — Nivel producción

**Objetivo:** que funcione como un sistema real, en la nube.

- [ ] **1. Imagen Docker por servicio.**
- [ ] **2. Kubernetes.**
- [ ] **3. Observabilidad** — métricas y paneles con Prometheus y Grafana.
- [ ] **4. Despliegue en la nube** con URL pública.
- [ ] **5. Cierre del portafolio** — README final, video demo, actualizar CV y LinkedIn.

---

## Pendientes técnicos

> Cosas que decidimos posponer a propósito, con el motivo y cuándo retomarlas.

- [ ] **Maven 3.10** — seguimos en 3.9.16 (sigue mantenida). No necesitamos nada de la 3.10 y trae
  cambios incompatibles (validación de POM más estricta, otro orden del classpath, cambios en el
  Super POM). *Retomar:* cuando salga la 3.10.1. Se cerró el PR #1 de Dependabot.

---

## Plan de aprendizaje

> Lo que necesito dominar para defender cada decisión del proyecto en una entrevista.
> Misma leyenda: `[x]` hecho · `[~]` en curso · `[ ]` pendiente

### Hábito de lectura

- 15 a 20 minutos al día, a la misma hora. Meta: 1 capítulo por semana.
- Al terminar cada capítulo, explicarlo en 3 a 5 líneas con mis palabras y compartirlo con Claude.
- Si un capítulo se pone pesado, saltar al siguiente. Leer lo que sirve a la etapa actual, no todo en orden.

### Bloque 0 — Fundamentos de herramientas (ahora, en paralelo con la etapa 2)

- [ ] **Git:** ramas, merge vs. squash, rebase, remotos y resolver conflictos. *Recurso: libro Pro Git, gratuito y en español.*
- [ ] **Docker:** imagen vs. contenedor, volúmenes, redes y Compose.
- [ ] **Terminal de Linux:** navegación, permisos, procesos y variables de entorno.
- [ ] **CI/CD:** leer y modificar un workflow de GitHub Actions sin ayuda.

### Libro 1 — *Fundamentos de la arquitectura de software* (Richards y Ford, 2.ª ed., en español)

**Antes y durante la etapa 2**
- [ ] Cap. 1 — Introducción
- [ ] Cap. 2 — Pensamiento arquitectónico
- [ ] Cap. 4 — Características arquitectónicas definidas
- [ ] Cap. 5 — Identificar las características arquitectónicas
- [ ] Cap. 21 — Decisiones arquitectónicas *(los ADRs que ya escribimos)*

**Etapas 2 y 3**
- [ ] Cap. 3 — Modularidad
- [ ] Cap. 8 — Pensamiento basado en componentes
- [ ] Cap. 14 — Estilo de arquitectura basada en servicios
- [ ] Cap. 18 — Arquitectura de microservicios

**Etapas 3 y 4**
- [ ] Cap. 15 — Estilo de arquitectura dirigida por eventos
- [ ] Cap. 19 — Elegir el estilo arquitectónico adecuado

**Etapa 6 y cierre**
- [ ] Cap. 22 — Analizar el riesgo de la arquitectura
- [ ] Cap. 23 — Diagramación de la arquitectura
- [ ] Cap. 25 — Habilidades de negociación y liderazgo
- [ ] Cap. 27 — Las leyes de la arquitectura del software, revisitadas

### Libro 2 — *Designing Data-Intensive Applications* (Kleppmann, en inglés) — desde la etapa 3

Solo los temas que toca cada etapa. Leerlo en inglés también es práctica del idioma.

- [ ] Etapa 3: *stream processing* y logs de eventos (cómo funciona Kafka por dentro)
- [ ] Etapa 4: los problemas de los sistemas distribuidos (fallas de red, relojes, procesos)
- [ ] Etapa 4: transacciones y consistencia

### Conceptos que debo poder explicar, por etapa

**Etapa 2 — Núcleo SaaS**
- [ ] OAuth2 vs. OIDC, y qué contiene un JWT
- [ ] Control de acceso por roles (RBAC)
- [ ] Estrategias multi-tenant y sus trade-offs
- [ ] Relaciones en JPA y el problema N+1
- [ ] Validación y manejo de errores en APIs (ProblemDetail, RFC 9457)

**Etapa 3 — Telemetría en vivo**
- [ ] Kafka: topics, particiones, consumer groups y offsets
- [ ] Comunicación síncrona vs. asíncrona: cuándo usar cada una
- [ ] WebSocket vs. polling
- [ ] Bases de datos de series de tiempo

**Etapa 4 — Anomalías**
- [ ] Idempotencia y entrega "al menos una vez"
- [ ] Consistencia eventual
- [ ] Patrón outbox
- [ ] Reintentos y circuit breaker

**Etapa 5 — Agente de IA**
- [ ] Cómo funciona un LLM a nivel práctico (tokens, contexto, temperatura)
- [ ] Tool calling: cómo una IA usa herramientas
- [ ] RAG y embeddings
- [ ] Riesgos de seguridad: prompt injection y acciones sin confirmar

**Etapa 6 — Producción**
- [ ] Kubernetes: pods, deployments y services
- [ ] Observabilidad: logs, métricas y trazas

**Transversales (en modo práctica)**
- [ ] Java moderno: records, sealed classes, pattern matching e hilos virtuales
- [ ] Angular moderno: signals, httpResource y zoneless
- [ ] Inglés técnico: leer documentación y escribir commits, README y ADRs

---

## Glosario mínimo

| Término | Qué es, en una línea |
|---|---|
| **Repositorio (repo)** | La carpeta del proyecto más todo su historial de cambios. |
| **Commit** | Una "foto" guardada del proyecto con una descripción de qué cambió. |
| **Maven** | Herramienta que descarga librerías, compila y corre pruebas en Java. |
| **pom.xml** | Archivo donde Maven lee qué librerías y versiones usa el proyecto. |
| **Parent / agregador** | Parent: los servicios heredan sus versiones. Agregador: compila varios módulos juntos. |
| **Wrapper (`./mvnw`)** | Script que descarga la versión exacta de Maven del proyecto. |
| **Spring Boot** | Framework para crear backends en Java con poca configuración. |
| **Endpoint** | Una URL del backend que responde algo, como `/api/v1/ping`. |
| **Checksum (SHA-256)** | "Huella digital" de un archivo; si cambia un solo byte, la huella no coincide y se detecta. |
| **Actuator / health check** | Endpoints de Spring que dicen si el servicio y sus dependencias (como la base de datos) están sanos. |
| **Hilos virtuales** | Hilos muy ligeros de Java que permiten atender muchas peticiones a la vez sin gastar mucha memoria. |
| **Prueba unitaria** | Prueba rápida de una pieza aislada del código, sin base de datos ni red. |
| **Prueba de integración (IT)** | Prueba que arranca la app completa con sus dependencias reales, como PostgreSQL. |
| **Surefire / Failsafe** | Plugins de Maven: Surefire corre las pruebas unitarias y Failsafe las de integración. |
| **Slice test (`@WebMvcTest`)** | Prueba que arranca solo la capa web de Spring, sin base de datos, para que sea rápida. |
| **`@ServiceConnection`** | Anotación que conecta la app al contenedor de pruebas sin configurar URL ni contraseña a mano. |
| **Angular** | Framework para crear la interfaz web (lo que ve el usuario). |
| **Proxy (Angular)** | En desarrollo, redirige las llamadas del frontend al backend. |
| **Componente standalone** | Componente de Angular que declara sus propias dependencias, sin necesitar un `NgModule`. |
| **Signal** | Variable "reactiva" de Angular: cuando cambia su valor, la pantalla se actualiza sola. |
| **Zoneless** | Angular sin `zone.js`: la pantalla se actualiza solo cuando cambia un signal, no "por si acaso". |
| **`httpResource`** | Forma de Angular de pedir datos por HTTP que entrega el resultado, la carga y el error como signals. |
| **Lazy loading** | Cargar el código de una pantalla solo cuando el usuario entra a ella, para que la app abra más rápido. |
| **Vitest** | Herramienta que corre las pruebas unitarias del frontend. |
| **ESLint (lint)** | Revisa el código en busca de errores y malas prácticas sin ejecutarlo. |
| **Docker / contenedor** | Empaqueta un programa con todo lo que necesita para correr igual en cualquier lugar. |
| **Docker Compose** | Levanta varios contenedores juntos con un solo comando. |
| **Volumen (Docker)** | Carpeta que Docker guarda fuera del contenedor para que los datos sobrevivan si el contenedor se borra. |
| **Healthcheck (contenedor)** | Comando que Docker corre periódicamente para saber si el servicio de adentro ya está listo. |
| **Variables de entorno / `.env`** | Configuración (como contraseñas) que se pasa al programa desde afuera, en lugar de escribirla en el código. |
| **Flyway** | Aplica los cambios a la base de datos en orden, como si fueran commits del esquema. |
| **Testcontainers** | Levanta una base de datos real en Docker solo mientras corren las pruebas. |
| **CI (GitHub Actions)** | Robot que compila y prueba el código cada vez que subes cambios. |
| **Workflow / job / step** | Workflow: el archivo de CI completo. Job: un grupo de tareas en una máquina. Step: cada tarea. |
| **Fijar por SHA** | Referenciar una action por el identificador exacto de su commit, que nadie puede cambiar después. |
| **Artifact (CI)** | Archivo que el CI guarda al terminar (por ejemplo, reportes de pruebas) para descargarlo después. |
| **Permisos mínimos** | Dar al CI solo los permisos que necesita (aquí, solo leer el repo), para limitar el daño si algo sale mal. |
| **Dependabot** | Bot de GitHub que revisa si hay versiones nuevas de tus dependencias y abre PRs para actualizarlas. |
| **gitleaks** | Herramienta que busca contraseñas o llaves filtradas por error en el historial de Git. |
| **Topics (GitHub)** | Etiquetas del repo que ayudan a que otros lo encuentren por tecnología o tema. |
| **ADR** | Documento corto que explica una decisión técnica y por qué se tomó. |
| **Microservicio** | Programa pequeño con una sola responsabilidad que habla con otros. |
| **Kafka** | "Cinta transportadora" de mensajes entre servicios. |
| **WebSocket** | Conexión abierta para que el servidor envíe datos al navegador sin que este pregunte. |
| **Multi-tenant** | Un solo sistema que atiende a varias empresas, cada una aislada de las demás. |
| **Keycloak / OIDC** | Servidor de login y el estándar que usa para identificar usuarios. |
| **Agente de IA** | Una IA que, además de responder, puede usar herramientas (consultar, agendar). |
| **RAG** | Darle a la IA documentos propios para que responda con información real. |
