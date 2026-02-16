#!/usr/bin/env bash
set -euo pipefail

# Local CI/CD verification script
# Run this before pushing to verify the build and tests pass locally

echo "🔍 RawScraper Local CI/CD Verification"
echo "======================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track failures
FAILED=0

# 1. Check Node and npm versions
echo "📦 Checking Node.js and npm..."
NODE_VERSION=$(node -v)
NPM_VERSION=$(npm -v)
echo "Node.js: $NODE_VERSION"
echo "npm: $NPM_VERSION"
echo ""

# 2. Install dependencies
echo "📥 Installing dependencies..."
npm ci > /dev/null 2>&1 || { echo -e "${RED}✗ npm install failed${NC}"; FAILED=$((FAILED+1)); }
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# 3. TypeScript lint check
echo "🔎 Linting TypeScript..."
if npm run lint > /dev/null 2>&1; then
  echo -e "${GREEN}✓ No TypeScript errors${NC}"
else
  echo -e "${RED}✗ TypeScript lint failed${NC}"
  npm run lint || true
  FAILED=$((FAILED+1))
fi
echo ""

# 4. Build TypeScript
echo "🏗️  Building TypeScript..."
if npm run build > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Build successful${NC}"
else
  echo -e "${RED}✗ TypeScript build failed${NC}"
  npm run build || true
  FAILED=$((FAILED+1))
fi
echo ""

# 5. Check dist output
echo "📂 Verifying dist output..."
if [ -f "dist/index.js" ]; then
  echo -e "${GREEN}✓ dist/index.js exists${NC}"
else
  echo -e "${RED}✗ dist/index.js not found${NC}"
  FAILED=$((FAILED+1))
fi
echo ""

# 6. Run tests (if any)
echo "🧪 Running tests..."
if npm test > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Tests passed${NC}"
else
  echo -e "${YELLOW}⚠ Tests not configured or failed${NC}"
fi
echo ""

# 7. Summary
echo "======================================"
if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All checks passed! Ready to push.${NC}"
  exit 0
else
  echo -e "${RED}❌ $FAILED check(s) failed. Review above for details.${NC}"
  exit 1
fi
