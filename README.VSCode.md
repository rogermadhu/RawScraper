# VS Code Development Guide

This project includes comprehensive VS Code tasks for all development workflows. Access tasks via **Terminal > Run Task** or **Ctrl+Shift+B** (build).

## Available Tasks

### Build Tasks

#### Build (TypeScript)
- **Shortcut:** Ctrl+Shift+B (default)
- **Command:** `npm run build`
- **Output:** Compiles TypeScript to `dist/index.js`
- **Use when:** Making changes to TypeScript source code

#### TypeScript Lint
- **Command:** `npm run lint`
- **Output:** Type-checks without emitting
- **Use when:** Validating TypeScript before commit

#### TypeScript Watch
- **Command:** `npm run dev:watch`
- **Output:** Continuously watches and compiles on changes
- **Use when:** Parallel development with separate terminal

#### Clean Build
- **Command:** Removes `dist/`, `node_modules/`, `.venv/` and rebuilds
- **Use when:** Starting fresh or resolving dependency issues

#### Production Build
- **Command:** Runs lint, then builds for production
- **Use when:** Preparing for deployment

### Development Tasks

#### Develop (Node + TypeScript)
- **Shortcut:** Default for "Test" group or Ctrl+Shift+B then select
- **Command:** `npm run dev`
- **Output:** Runs with nodemon and ts-node (auto-reload)
- **Use when:** Active development with hot-reload

#### Production Start
- **Command:** `npm start`
- **Output:** Runs compiled production build
- **Use when:** Testing production build locally

### Testing & Validation

#### Test
- **Command:** `npm test`
- **Output:** Runs test suite
- **Use when:** Running unit/integration tests

#### Local CI (Pre-push Check)
- **Command:** `bash ./scripts/local-ci.sh`
- **Output:** Comprehensive pre-push validation
- **Checks:**
  - Node/npm versions
  - Dependencies installation
  - TypeScript lint
  - Build success
  - Dist output verification
- **Use before:** Pushing to GitHub

#### Health Check
- **Command:** Tests both `/` and `/scrape` endpoints
- **Output:** JSON response from scraper
- **Use when:** Verifying server is responding correctly

### Docker Tasks

> **Note:** Docker tasks require Docker daemon access

#### Docker Build (Dev)
- **Command:** `docker compose build --no-cache server-dev`
- **Use when:** Building dev Docker image

#### Docker Build (Prod)
- **Command:** `docker compose build --no-cache server`
- **Use when:** Building production Docker image

#### Deploy (Docker Compose Up)
- **Command:** `docker compose up -d --build server-dev`
- **Use when:** Starting dev services in Docker

#### Deploy (Docker Compose Down)
- **Command:** `docker compose down`
- **Use when:** Stopping Docker services

### Install Dependencies
- **Command:** `npm install`
- **Use when:** Adding new packages or after `git clone`

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+B` | Run default build task (TypeScript build) |
| `Ctrl+Shift+T` | Run default test task (Develop) |
| `Ctrl+Shift+E` | Open Explorer (for file navigation) |
| `Ctrl+`` | Toggle integrated terminal |

## Task Quick Reference

### Local Development Workflow
1. **Start:** Run "Develop (Node + TypeScript)" task
2. **Edit:** TypeScript files in `src/`
3. **Test:** curl `http://localhost:65000/` and `/scrape`
4. **Validate:** Run "Local CI (Pre-push Check)" task
5. **Commit:** Push changes

### Production Deployment Workflow
1. **Validate:** Run "Local CI (Pre-push Check)" task
2. **Build:** Run "Production Build" task
3. **Test:** Run "Production Start" task
4. **Verify:** Run "Health Check" task
5. **Deploy:** Push to `main` branch (GitHub Actions will build/test)

### Docker Development Workflow
1. **Ensure Docker daemon is running:** `docker ps`
2. **Build:** Run "Docker Build (Dev)" task
3. **Deploy:** Run "Deploy (Docker Compose Up)" task
4. **Verify:** Run "Health Check" task
5. **Stop:** Run "Deploy (Docker Compose Down)" task

## Project Structure

```
RawScraper/
├── .vscode/
│   └── tasks.json              # VS Code task definitions
├── src/
│   └── index.ts               # TypeScript server code
├── dist/                       # Compiled JavaScript (generated)
│   ├── index.js
│   ├── index.d.ts
│   └── *.map                   # Source maps for debugging
├── python/
│   ├── __init__.py            # Python package marker
│   └── scraper.py             # Web scraper implementation
├── scripts/
│   ├── local-ci.sh            # Pre-push validation
│   └── smoke_test.sh          # Docker smoke tests
├── .github/workflows/
│   └── build-test.yml         # GitHub Actions CI/CD
├── Dockerfile                 # Multi-stage Docker build
├── compose.yaml               # Docker Compose config
├── tsconfig.json              # TypeScript configuration
├── package.json               # Node dependencies
├── requirements.txt           # Python dependencies
└── README.md                  # Project overview
```

## Troubleshooting

### Port Already in Use
If you see `Error: listen EADDRINUSE: address already in use :::65000`:
```bash
lsof -ti:65000 | xargs kill -9
npm run dev
```

### TypeScript Errors
Run the lint task to check:
```bash
npm run lint
```

### Python Module Not Found
Ensure virtualenv is activated and dependencies installed:
```bash
source .venv/bin/activate
pip install -r requirements.txt
```

### Docker Permission Denied
Add your user to docker group:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Clean State
Run the "Clean Build" task to reset everything:
```
Ctrl+Shift+B → Select "Clean Build"
```

## Advanced

### Custom Tasks
Edit `.vscode/tasks.json` to add project-specific tasks. VS Code will provide IntelliSense.

### Debug in VS Code
Add a `.vscode/launch.json` for debugging:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch Dev Server",
      "program": "${workspaceFolder}/dist/index.js",
      "preLaunchTask": "Build (TypeScript)",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"]
    }
  ]
}
```

Then press `F5` to start debugging.

### Environment Variables
Create `.env` for local development:
```
PORT=65000
NODE_ENV=development
```

Reference in code:
```typescript
const port = process.env.PORT || 65000;
```

## CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/build-test.yml`) automatically:
- Runs on push to `main`/`develop` branches
- Tests on Node 18.x and 20.x
- Lints TypeScript
- Builds production code
- Builds Docker images

View results in GitHub > Actions tab.
