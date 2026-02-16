# RawScraper

A lightweight Node.js + Python web scraper service that combines Express.js with BeautifulSoup.

## Features

- 🚀 **Express.js Server** - RESTful API for web scraping
- 🐍 **Python Integration** - BeautifulSoup for HTML parsing
- 🔄 **Hot Reload** - Nodemon for development updates
- 🐳 **Docker Support** - Multi-stage builds for dev and production
- 📝 **TypeScript** - Fully typed for better code safety
- 🔄 **CI/CD** - GitHub Actions pipeline for automated testing and builds
- ⚡ **VS Code Tasks** - Built-in build, test, develop, deploy, and production tasks

## Quick Start

### Prerequisites

- Node.js 18+ and npm
- Python 3.7+

### Local Development

```bash
# Create Python virtual environment
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
npm install

# Start development server
npm run dev
```

The server runs on `http://localhost:65000` with hot-reload.

### Test the API

```bash
# Health check
curl http://localhost:65000/

# Scrape a webpage
curl http://localhost:65000/scrape
```

## VS Code Development

This project includes comprehensive build, test, develop, and deploy tasks.

**Access tasks:** Terminal > Run Task (or **Ctrl+Shift+B** for build)

Popular tasks:
- **Develop (Node + TypeScript)** - Start dev server with hot-reload
- **Build (TypeScript)** - Compile TypeScript
- **Local CI (Pre-push Check)** - Validate before pushing
- **Health Check** - Test API endpoints
- **Docker Build/Deploy** - Container operations

See [README.VSCode.md](./README.VSCode.md) for complete task reference.

## Available Commands

| Command | Description |
|---------|-------------|
| `npm run build` | Compile TypeScript to JavaScript |
| `npm run dev` | Start dev server with hot-reload |
| `npm run dev:watch` | Watch TypeScript changes (compile only) |
| `npm run start` | Run production build |
| `npm run lint` | Type-check TypeScript |
| `npm test` | Run tests |

## Docker

See [README.Docker.md](./README.Docker.md) for Docker-specific instructions.

## TypeScript & CI/CD Setup

See [README.TypeScript.md](./README.TypeScript.md) for:

- TypeScript configuration details
- Development setup guide
- CI/CD pipeline documentation
- Deployment instructions
- Troubleshooting tips

## Project Structure

```
RawScraper/
├── src/                     # TypeScript source code
│   └── index.ts            # Server entry point
├── dist/                   # Compiled JavaScript (generated)
├── python/                 # Python scrapers & utilities
│   ├── __init__.py        # Python package marker
│   └── scraper.py         # Web scraper implementation
├── scripts/                # Automation scripts
│   ├── local-ci.sh        # Pre-push validation
│   └── smoke_test.sh      # Docker integration tests
├── .vscode/               # VS Code configuration
│   └── tasks.json         # Build/test/dev/deploy tasks
├── .github/workflows/     # GitHub Actions CI/CD
├── package.json           # Node dependencies
├── requirements.txt       # Python dependencies
├── tsconfig.json          # TypeScript config
├── Dockerfile             # Multi-stage Docker build
└── compose.yaml           # Docker Compose config
```

## API Endpoints

### GET `/`

Health check endpoint.

**Response:**
```
RawScraper running
```

### GET `/scrape`

Scrapes a webpage and extracts the title.

**Response:**
```json
{
  "url": "https://en.wikipedia.org/wiki/Plain_text",
  "title": "Plain text - Wikipedia"
}
```

## License

MIT

## Contributing

1. Create a branch for your feature (`git checkout -b feature/my-feature`)
2. Commit your changes (`git commit -am 'Add my feature'`)
3. Push to the branch (`git push origin feature/my-feature`)
4. Open a Pull Request

The CI/CD pipeline will automatically run tests and build checks.

