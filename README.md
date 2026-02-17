# Fullstack Template (Rails 8 + Inertia + React)

A modern, Dockerized full-stack application template built with Ruby on Rails 8 and React (via Inertia.js). Provides a solid foundation with authentication, authorization, and best practices pre-configured.

## System Dependencies

Any machine that can run Docker will work. VS Code is the preferred IDE.

| Dependency | Version |
|---|---|
| GIT VCS | any modern version |
| Docker | v20.10.10+ |
| Docker Rootless Plugin | installed |
| Ruby (Container) | 3.4 |
| PostgreSQL (Container) | 18 |
| Redis (Container) | 8 |

> This project uses dotenv for configuration. Secrets like `RAILS_MASTER_KEY` should be placed in `.env.local` or `.env.development.local`.

## Getting Started

This project uses rootless Docker for correct file permissions (no root-owned files on Linux/Mac). Pass your current user's `UID` and `GID` to Docker commands.

### Clone and set up:

```bash
git clone <repo-url>
cd <repo-dir>
```

### Prepare environment variables:

```bash
touch .env.local
cp .env.example .env.development.local
cp .env.example .env.test.local
```

### Build Docker images:

```bash
UID=${UID} GID=${GID} docker compose --progress=plain build project-base project-test-base
```

### Run the application:

```bash
DROP_TO_SHELL=false UID=${UID} GID=${GID} docker compose run --rm --service-ports project-rails-server
```

Open http://localhost:3000 in your browser when you see `* Listening on http://0.0.0.0:3000`.

### Seed data:

```bash
UID=${UID} GID=${GID} docker compose run --rm project-rails-server rails db:seed
```

> Seeds run automatically on first boot. This command is for reference.

### Demo Credentials:

- Email: `demo@example.com` / Password: `password`

## Running Tests

Uses RSpec with FactoryBot:

```bash
DROP_TO_SHELL=false UID=${UID} GID=${GID} docker compose run --rm project-test-local
```

## Tech Stack

- **Backend:** Ruby on Rails 8 (session-based auth)
- **Frontend:** React + TypeScript + TailwindCSS via Inertia.js (Vite)
- **Database:** PostgreSQL 18 (UUIDs, citext, pg_trgm, pgcrypto)
- **Authorization:** Pundit
- **Serialization:** Blueprinter
- **Testing:** RSpec, FactoryBot, Shoulda Matchers, Faker
- **Infrastructure:** Docker (rootless), Redis, Sidekiq

## Project Structure

```
app/
  controllers/    # Rails controllers (thin, delegate to services)
  models/         # ActiveRecord models
  blueprints/     # JSON serializers (Blueprinter)
  policies/       # Authorization policies (Pundit)
  services/       # Service objects for business logic
  frontend/
    components/   # Shared React components
    pages/        # Inertia page components
    types/        # TypeScript type definitions
    entrypoints/  # Vite entrypoints
```

## Recommended VS Code Extensions

- Docker
- Ruby LSP
- ESLint / Prettier
- Tailwind CSS IntelliSense
