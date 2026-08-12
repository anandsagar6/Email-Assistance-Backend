# ✉️ Email Assistance Backend

A Spring Boot REST API that generates professional email replies using Google's **Gemini** model. Send it the email you received plus an optional tone, and it returns a ready-to-send reply.

Built to power an email-assistant frontend or browser extension — CORS is open, the API is stateless, and it ships with a Docker build for one-click cloud deployment.

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.3-6DB33F)
![Maven](https://img.shields.io/badge/Maven-3.9.9-C71A36)
![Docker](https://img.shields.io/badge/Docker-ready-2496ED)

---

## ✨ Features

- **AI-generated replies** — forwards your email content to the Gemini API and returns a clean, professional response
- **Tone control** — request a `professional`, `casual`, `friendly`, or any other tone; omit it for the default
- **No subject line noise** — the prompt explicitly asks Gemini to return the reply body only
- **Reactive HTTP client** — outbound calls made with Spring WebFlux's `WebClient`
- **Stateless** — no database, no session; every request stands on its own
- **CORS enabled** — callable directly from a browser extension or SPA
- **Container-ready** — multi-stage `Dockerfile` builds and runs the JAR with no local Maven install needed

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Language | Java 17 |
| Framework | Spring Boot 3.4.3 |
| Web | `spring-boot-starter-web` (MVC controller) |
| HTTP client | `spring-boot-starter-webflux` (`WebClient`) |
| JSON | Jackson (`ObjectMapper`) |
| Boilerplate | Lombok |
| Build | Maven (wrapper included, 3.9.9) |
| Container | Eclipse Temurin 17 JDK |
| AI provider | Google Gemini API |

---

## 📂 Project Structure

```
Email-Assistance-Backend/
├── src/
│   ├── main/
│   │   ├── java/com/email/writer/
│   │   │   ├── EmailWriterSbApplication.java     # Spring Boot entry point
│   │   │   └── app/
│   │   │       ├── EmailGeneratorController.java # REST layer — POST /api/email/generate
│   │   │       ├── EmailGeneratorService.java    # Prompt building + Gemini call + parsing
│   │   │       └── EmailRequest.java             # Request DTO (emailContent, tone)
│   │   └── resources/
│   │       └── application.properties            # Env-driven config
│   └── test/java/com/email/writer/
│       └── EmailWriterSbApplicationTests.java
├── Dockerfile
├── pom.xml
└── mvnw · mvnw.cmd
```

---

## 🔌 API Reference

### Generate an email reply

```http
POST /api/email/generate
Content-Type: application/json
```

**Request body**

| Field | Type | Required | Description |
|---|---|---|---|
| `emailContent` | string | ✅ | The original email you're replying to |
| `tone` | string | ⬜ | Desired tone, e.g. `professional`, `casual`, `friendly`. Omitted or empty → model default |

**Example**

```bash
curl -X POST http://localhost:8080/api/email/generate \
  -H "Content-Type: application/json" \
  -d '{
        "emailContent": "Hi, could we push our Thursday sync to next week? Something came up on my end.",
        "tone": "professional"
      }'
```

**Response** — `200 OK`, `text/plain`

```
No problem at all — I completely understand that things come up.
Next week works well on my end. Would Tuesday or Wednesday suit you better?
...
```

The response is the raw reply text, not JSON. If the upstream call or parsing fails, the endpoint still returns `200` with a body beginning `Error processing request: ...` — worth handling on the client side.

---

## 🚀 Getting Started

### Prerequisites

- **JDK 17** or newer
- A **Gemini API key** from [Google AI Studio](https://aistudio.google.com/apikey)
- **Docker** (optional, for the containerized path)

Maven is not required — the project includes a wrapper (`mvnw`).

### 1. Clone

```bash
git clone https://github.com/anandsagar6/Email-Assistance-Backend.git
cd Email-Assistance-Backend
```

### 2. Set environment variables

The app reads two required variables at startup — it will fail to boot without them.

| Variable | Description |
|---|---|
| `GEMINI_URL` | Full Gemini endpoint, **ending in `?key=`** |
| `GEMINI_KEY` | Your Gemini API key |
| `PORT` | Optional; server port (defaults to `8080`) |

> ⚠️ **Important:** the service concatenates the two values directly (`geminiApiUrl + geminiApiKey`), so `GEMINI_URL` **must** end with `?key=` for the final URL to be valid.

```bash
export GEMINI_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key="
export GEMINI_KEY="your_api_key_here"
```

On Windows PowerShell:

```powershell
$env:GEMINI_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key="
$env:GEMINI_KEY="your_api_key_here"
```

### 3. Run

```bash
# macOS / Linux
./mvnw spring-boot:run

# Windows
mvnw.cmd spring-boot:run
```

The API is now live at `http://localhost:8080`.

### Build a JAR

```bash
./mvnw clean package
java -jar target/email-writer-sb-0.0.1-SNAPSHOT.jar
```

---

## 🐳 Docker

The included `Dockerfile` uses a multi-stage build — it compiles with the Maven wrapper inside the container, then runs only the resulting JAR.

```bash
docker build -t email-assistance-backend .

docker run -p 8080:8080 \
  -e GEMINI_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" \
  -e GEMINI_KEY="your_api_key_here" \
  email-assistance-backend
```

---

## ☁️ Deployment

The project is configured for **Render**-style platforms out of the box:

- `server.port=${PORT:8080}` binds to the port the host injects
- The `Dockerfile` needs no build command configuration — point the service at the repo and select Docker as the environment
- Add `GEMINI_URL` and `GEMINI_KEY` as environment variables in the dashboard

The same setup works on Railway, Fly.io, Google Cloud Run, or any container host.

---

## 🧭 Roadmap

Ideas for extending the project:

- [ ] Return structured JSON (`{ "reply": "...", "tone": "..." }`) instead of a raw string
- [ ] Proper error handling — map upstream failures to `4xx`/`5xx` via `@ControllerAdvice` rather than a `200` with an error string
- [ ] Bean validation (`@NotBlank` on `emailContent`) with `@Valid`
- [ ] Restrict `@CrossOrigin` to known origins before going to production
- [ ] Rate limiting to protect the Gemini quota
- [ ] Reactive end-to-end — return `Mono<String>` instead of calling `.block()`
- [ ] Unit and integration tests with `MockWebServer` for the Gemini call
- [ ] OpenAPI/Swagger docs via `springdoc-openapi`
- [ ] Multiple reply variants per request
- [ ] Remove the unused `pp3.java` placeholder class

---

## 🤝 Contributing

1. Fork the repository
2. Create a branch — `git checkout -b feature/your-feature`
3. Commit your changes — `git commit -m "Add your feature"`
4. Push — `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

No license file is currently included, which means all rights are reserved by default. If you'd like others to reuse this code, consider adding one — the [MIT License](https://choosealicense.com/licenses/mit/) is a common choice.

---

## 📬 Contact

**Anand Sagar** — anandsagar0006@gmail.com

Project link: [github.com/anandsagar6/Email-Assistance-Backend](https://github.com/anandsagar6/Email-Assistance-Backend)
