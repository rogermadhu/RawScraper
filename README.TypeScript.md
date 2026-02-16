# RawScraper - TypeScript Setup & CI/CD Guide

This document describes the TypeScript setup and CI/CD pipeline for RawScraper.

## Project Structure

```
RawScraper/
├── src/
│   └── index.ts                 # TypeScript server entry point
├── dist/                        # Compiled JavaScript output (generated)
├── python/
│   ├── __init__.py             # Python package marker
│   └── scraper.py              # Web scraper implementation
├── scripts/
│   ├── local-ci.sh             # Pre-push validation script
│   └── smoke_test.sh           # Docker integration tests
├── .github/
│   └── workflows/
│       └── build-test.yml      # GitHub Actions CI/CD pipeline
├── .vscode/
│   └── tasks.json              # VS Code task definitions
├── tsconfig.json               # TypeScript configuration
├── package.json                # Node.js dependencies and scripts
├── requirements.txt            # Python dependencies
├── Dockerfile                  # Multi-stage Docker build
├── compose.yaml                # Docker Compose configuration
├── README.md                   # Project overview
├── README.VSCode.md            # VS Code tasks guide
└── README.TypeScript.md        # This file
```

## TypeScript Configuration

The project uses TypeScript with strict mode enabled. Configuration is in `tsconfig.json`:

- **Target:** ES2020 (Node.js 18+)
- **Module:** CommonJS
- **Output:** `dist/` directory
- **Strict Mode:** Enabled for type safety

## Development Setup

### Prerequisites

- Node.js 18+ (18.x or 20.x recommended)
- Python 3.7+
- npm or yarn

### Local Development

1. **Create a Python virtual environment:**
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   npm install
   ```

3. **Start the development server:**
   ```bash
   npm run dev
   ```
   The server runs on `http://localhost:65000` with hot-reload via nodemon.

### Available npm Scripts

- **`npm run build`** - Compile TypeScript to JavaScript (outputs to `dist/`)
- **`npm run dev`** - Start development server with hot-reload
- **`npm run dev:watch`** - Watch mode: only compile TypeScript without running the server
- **`npm run start`** - Run compiled production build (`npm run build` first)
- **`npm run lint`** - Type-check TypeScript without emitting JavaScript
- **`npm test`** - Run tests (not yet configured)

## Testing the API

After the dev server starts, test the endpoints:

```bash
# Health check
curl http://localhost:65000/

# Scrape a webpage
curl http://localhost:65000/scrape
```

Expected response from `/scrape`:
```json
{
  "url": "https://en.wikipedia.org/wiki/Plain_text",
  "title": "Plain text - Wikipedia"
}
```

## Docker Builds

The Dockerfile includes three build stages:

- **`base`** - Installs Node, Python, and dependencies
- **`builder`** - Compiles TypeScript (used internally for multi-stage)
- **`dev`** - Development image with all dev dependencies
- **`prod`** - Production image with optimized build

### Building Docker Images

```bash
# Build the production image
docker compose build --target=prod

# Build the development image
docker compose build --target=dev
```

### Running with Docker Compose

```bash
# Development
docker compose up server-dev

# Production
docker compose up server
```

## CI/CD Pipeline (GitHub Actions)

The CI/CD pipeline is defined in `.github/workflows/build-test.yml` and runs:

1. **On:** Push to `main` or `develop`, and on pull requests
2. **Steps:**
   - Check out code
   - Set up Node.js (18.x and 20.x)
   - Install dependencies
   - Lint TypeScript (`npm run lint`)
   - Build TypeScript (`npm run build`)
   - Run tests
   - Build Docker image (main branch only)

### Local CI/CD Testing

To test the CI/CD pipeline locally before pushing:

```bash
# Lint
npm run lint

# Build
npm run build

# Test (if configured)
npm test

# Build Docker
docker compose build
```

## Environment Variables

Configure environment variables via `.env` file or environment:

- `PORT` - Server port (default: `65000`)
- `NODE_ENV` - `development` or `production`

Example `.env`:
```
PORT=65000
NODE_ENV=development
```

## Troubleshooting

### TypeScript Compilation Errors

If you see TypeScript errors:

```bash
npm run lint  # Check for type errors
npm run build # Attempt to compile
```

### Port Already in Use

If port 65000 is already in use:

```bash
# Kill the process (Unix/Linux/Mac)
lsof -ti:65000 | xargs kill -9

# Or use a different port
PORT=3000 npm run dev
```

### Python Module Not Found

Ensure the Python virtual environment is activated before running the dev server:

```bash
source .venv/bin/activate  # Activate venv
npm run dev                 # Start server
```

## Production Deployment

For production deployment:

1. **Build the optimized Docker image:**
   ```bash
   docker build --target=prod -t rawscraper:latest .
   ```

2. **Run the container:**
   ```bash
   docker run -p 65000:65000 rawscraper:latest
   ```

3. **Verify health:**
   ```bash
   curl http://localhost:65000/
   ```

## Next Steps

- Add unit tests (Jest, Mocha, or similar)
- Configure additional CI/CD steps (e.g., code coverage, security scans)
- Set up deployment to production environments
- Add API documentation (Swagger/OpenAPI)

