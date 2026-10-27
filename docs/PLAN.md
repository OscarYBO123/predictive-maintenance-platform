# Plan de trabajo — predictive-maintenance-platform

> Lista de todo lo que vamos a construir, en orden. Se marca `[x]` al terminar cada paso.
> Leyenda: `[x]` hecho · `[~]` en curso · `[ ]` pendiente

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
- [~] **5. PostgreSQL con Docker Compose** — base de datos levantada con un solo comando.
  *Por qué:* nada se instala en tu máquina; todo corre en contenedores.
- [ ] **6. Prueba de punta a punta** — navegador → Angular → Spring → PostgreSQL.
  *Por qué:* confirmar que todo el camino funciona junto.
- [ ] **7. CI y ADR 0001** — GitHub Actions compila y prueba en cada cambio; documentar decisiones.
  *Por qué:* nadie puede subir código roto sin que se note.
- [ ] **8. Publicar en GitHub** — crear el repo, hacer push y ver el CI en verde.

## Etapa 2 — Núcleo SaaS

**Objetivo:** la parte "administrativa": empresas, plantas, máquinas y técnicos, con login.

- [ ] **1. Modelo de datos** — tablas con migraciones de Flyway.
- [ ] **2. API REST** — crear, consultar, editar y borrar, con validaciones y documentación OpenAPI.
- [ ] **3. Keycloak** — servidor de login; el frontend inicia sesión con OIDC.
- [ ] **4. Multi-tenant** — cada empresa solo ve sus propios datos.
- [ ] **5. Pantallas de administración** en Angular.
- [ ] **6. Flujo profesional** — a partir de aquí, trabajar con ramas y pull requests.

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
| **Flyway** | Aplica los cambios a la base de datos en orden, como si fueran commits del esquema. |
| **Testcontainers** | Levanta una base de datos real en Docker solo mientras corren las pruebas. |
| **CI (GitHub Actions)** | Robot que compila y prueba el código cada vez que subes cambios. |
| **ADR** | Documento corto que explica una decisión técnica y por qué se tomó. |
| **Microservicio** | Programa pequeño con una sola responsabilidad que habla con otros. |
| **Kafka** | "Cinta transportadora" de mensajes entre servicios. |
| **WebSocket** | Conexión abierta para que el servidor envíe datos al navegador sin que este pregunte. |
| **Multi-tenant** | Un solo sistema que atiende a varias empresas, cada una aislada de las demás. |
| **Keycloak / OIDC** | Servidor de login y el estándar que usa para identificar usuarios. |
| **Agente de IA** | Una IA que, además de responder, puede usar herramientas (consultar, agendar). |
| **RAG** | Darle a la IA documentos propios para que responda con información real. |
