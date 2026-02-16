# Project Organization & Build Workflow

This document describes the project structure and build workflow for RawScraper.

## Directory Organization

### Source Code Layout

#### TypeScript/Node.js
```
src/
└── index.ts              # Express server entry point with type definitions
```

TypeScript is compiled to `dist/` by the build process:
```
dist/
├── index.js              # Compiled JavaScript
├── index.d.ts            # Type definitions
├── index.js.map          # Source map for debugging
└── index.d.ts.map        # Type definition source map
```

#### Python
```
python/
├── __init__.py           # Makes python/ a package
└── scraper.py            # Web scraper using BeautifulSoup
```

Python modules are referenced directly from their source location. They are not compiled but can be bundled in Docker.

### Build Outputs

```
dist/                     # TypeScript compiled output
  ├── index.js           # Production JavaScript
  ├── index.d.ts         # Type definitions for consumers
  └── *.map              # Source maps
```

### Configuration Files

```
tsconfig.json             # TypeScript compiler options
  - Target: ES2020
  - Module: CommonJS
  - Output: dist/
  - Strict mode enabled

package.json              # Node.js dependencies and scripts
  - Build: npm run build
  - Dev: npm run dev
  - Prod: npm start
  - Lint: npm run lint

requirements.txt          # Python dependencies
  - requests
  - beautifulsoup4
  - certifi
```

### Scripts & Utilities

```
scripts/
├── local-ci.sh          # Pre-push validation
│   - Checks Node/Python versions
│   - Installs dependencies
│   - Lints TypeScript
│   - Builds project
│   - Verifies outputs
│
└── smoke_test.sh        # Docker integration tests
    - Builds dev Docker image
    - Starts container
    - Tests endpoints
    - Cleans up
```

### Deployment & CI/CD

```
Dockerfile                # Multi-stage Docker build
  - Base: node:20-slim + python3
  - Builder: Compiles TypeScript
  - Dev: Development with hot-reload
  - Prod: Optimized production image

compose.yaml              # Docker Compose orchestration
  - server: Production service
  - server-dev: Development service with volumes

.github/workflows/
└── build-test.yml       # GitHub Actions pipeline
    - Runs on push/PR to main/develop
    - Tests Node 18.x and 20.x
    - Lints and builds
    - Builds Docker images
```

### VS Code Configuration

```
.vscode/
└── tasks.json           # IDE task definitions
    - Build tasks
    - Development tasks
    - Test tasks
    - Docker tasks
    - Deploy tasks
```

## Build Workflow

### Development Build

```
npm run dev
  ↓
ts-node reads tsconfig.json
  ↓
Executes src/index.ts (transpiled on-the-fly)
  ↓
Server listens on port 65000
  ↓
Nodemon watches src/ for changes
  ↓
Auto-restarts on file modification
```

### Production Build

```
npm run build
  ↓
tsc (TypeScript compiler)
  ↓
Reads tsconfig.json
  ↓
Compiles src/*.ts → dist/*.js
  ↓
Generates type definitions (dist/*.d.ts)
  ↓
Creates source maps (*.map)
```

### Production Run

```
npm start
  ↓
node dist/index.js
  ↓
Executes pre-compiled JavaScript
  ↓
Imports Python scraper as subprocess
```

## Python Integration

### Source Code Location
- **Development:** `python/scraper.py` (direct import)
- **Docker Container:** `/app/python/scraper.py` (COPY in Dockerfile)

### Execution Flow

```typescript
// src/index.ts
spawn('python3', ['python/scraper.py'])
  ↓
Python process starts
  ↓
Imports requests, BeautifulSoup, certifi
  ↓
Executes scrape() function
  ↓
Returns JSON to stdout
  ↓
Node.js parses JSON response
```

### Python Dependencies
Located in `requirements.txt`:
```
requests              # HTTP client
beautifulsoup4        # HTML parsing
certifi              # SSL CA bundle
```

Installation:
```bash
pip install -r requirements.txt
```

## Docker Build Process

### Multi-Stage Build

#### Stage 1: Base
- Node.js 20 + Python 3
- Install system dependencies
- Create non-root user
- Install pip packages and npm packages

#### Stage 2: Builder
- Install dev dependencies
- Copy TypeScript source
- Compile TypeScript → dist/

#### Stage 3: Dev
- Copy all source
- Install dev dependencies
- Use nodemon for auto-reload
- Mount volumes for live editing

#### Stage 4: Prod
- Copy compiled dist/ from builder
- Copy python/ and requirements.txt
- Prune dev dependencies
- Minimal binary image
- Health checks enabled

### Build Command

```bash
# Development image (with live reload)
docker compose build server-dev

# Production image (optimized)
docker compose build server
```

## CI/CD Pipeline (GitHub Actions)

### Trigger
- Push to `main` or `develop`
- Pull requests to `main` or `develop`

### Steps
1. **Checkout code**
2. **Setup Node.js** (18.x and 20.x matrix)
3. **Cache npm packages**
4. **Install dependencies:** `npm ci`
5. **Lint:** `npm run lint` (type-check)
6. **Build:** `npm run build` (compile TypeScript)
7. **Test:** `npm test` (if configured)
8. **Docker Build** (main branch only)

### Artifacts
- Successful builds are cached
- Docker images are built but not pushed (unless configured)

## Development Workflow

### Setup
```bash
# Clone repository
git clone <repo>
cd RawScraper

# Create Python venv
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
npm install
```

### Development
```bash
# Start with hot-reload
npm run dev

# In separate terminal, edit src/index.ts
# Changes auto-reload (nodemon watches src/)

# Test endpoints
curl http://localhost:65000/
curl http://localhost:65000/scrape
```

### Before Commit
```bash
# Run pre-push validation
./scripts/local-ci.sh

# This will:
# 1. Check Node/Python versions
# 2. Install dependencies
# 3. Type-check TypeScript
# 4. Compile TypeScript
# 5. Verify dist/ output

# Fix any errors and commit
git add .
git commit -m "Fix: description"
git push
```

### Deployment

#### Local Production Test
```bash
npm run build    # Compile TypeScript
npm start        # Run production binary
curl http://localhost:65000/
```

#### Docker Container
```bash
docker compose up server-dev   # Development
docker compose up server       # Production
```

#### GitHub Actions
- Push to `main` triggers automated build/test
- View results in GitHub > Actions tab
- All checks must pass before merging PRs

## VS Code Tasks Integration

VS Code tasks (Terminal > Run Task) provide quick access to common workflows:

### Quick Start
```
Ctrl+Shift+B → "Develop (Node + TypeScript)"
```

### Common Workflow
1. `Ctrl+Shift+B` → Development
2. Edit `src/` files
3. Server auto-reloads (nodemon)
4. Test with curl or browser
5. `Ctrl+Shift+B` → Local CI (Pre-push Check)
6. Push when CI passes

## Performance Considerations

### TypeScript Compilation
- **Development:** Lazy compilation via ts-node (on-demand)
- **Production:** Pre-compiled JavaScript (faster startup)
- **Caching:** NPM packages cached in Docker layers

### Python Execution
- **Subprocess spawn:** Python runs as separate process
- **Performance:** ~100-200ms per request (includes network request)
- **Optimization:** Consider pooling for high throughput

### Docker Layering
- **Base layer:** Cached (Node + Python + deps)
- **Builder layer:** Cached (TypeScript compile)
- **Dev/Prod:** Minimal changes to cache

## Troubleshooting Build Issues

### TS2304: Cannot find name
- **Cause:** Types not installed
- **Fix:** `npm install --save-dev @types/[package]`

### Port Already in Use
- **Cause:** Previous process still running
- **Fix:** `lsof -ti:65000 | xargs kill -9`

### Python Module Not Found
- **Cause:** venv not activated
- **Fix:** `source .venv/bin/activate`

### Docker Build Fails
- **Cause:** Python dependencies not installed
- **Fix:** Re-run `docker compose build --no-cache`

## File Size Reference

Typical outputs (development):
```
dist/index.js           ~1-2 KB (compiled)
dist/index.d.ts         ~1 KB (types)
node_modules/           ~300+ MB
.venv/                  ~100+ MB
```

Production Docker image: ~500-600 MB (Node 20 + Python 3 + deps)

## Next Steps

1. **For Development:** See [README.VSCode.md](./README.VSCode.md)
2. **For TypeScript:** See [README.TypeScript.md](./README.TypeScript.md)
3. **For Docker:** See [README.Docker.md](./README.Docker.md)
4. **For Contribution:** See main [README.md](./README.md)
