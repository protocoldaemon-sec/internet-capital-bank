# ICB Protocol - Monorepo Structure

## Overview

The Internet Central Bank (ICB) protocol is organized as a **monorepo** using npm workspaces for efficient dependency management and build orchestration across multiple packages.

## Directory Structure

```
icb-protocol/
├── backend/                 # Backend API services (Node.js + TypeScript)
│   ├── src/                # Source code
│   ├── package.json        # Backend dependencies
│   ├── tsconfig.json       # TypeScript configuration
│   └── README.md           # Backend documentation
│
├── frontend/               # Frontend dashboard (Vite + React + TypeScript)
│   ├── src/                # Source code (to be created)
│   ├── package.json        # Frontend dependencies (to be created)
│   └── README.md           # Frontend documentation (to be created)
│
├── programs/               # Solana smart contracts (Anchor/Rust)
│   ├── icb-core/          # Core protocol logic (ILI, futarchy, governance)
│   ├── icb-reserve/       # Reserve vault management
│   ├── icb-token/         # ICU token program
│   └── README.md          # Programs documentation
│
├── .kiro/                  # Kiro AI specifications
│   └── specs/
│       └── internet-central-bank/
│           ├── requirements.md  # Project requirements
│           ├── design.md        # Technical design
│           └── tasks.md         # Implementation tasks
│
├── documentation/          # Project documentation
│   ├── hackathon/         # Hackathon-specific docs
│   └── development/       # Development resources
│
├── scripts/               # Build and deployment scripts
│
├── package.json           # Root workspace configuration
├── Anchor.toml            # Anchor workspace configuration
├── Cargo.toml             # Rust workspace configuration
└── README.md              # Main project documentation
```

## Workspace Configuration

### Root Package.json

The root `package.json` is configured with npm workspaces to manage the monorepo:

```json
{
  "name": "icb-protocol",
  "private": true,
  "workspaces": [
    "backend",
    "frontend"
  ]
}
```

### Key Features

1. **Shared Dependencies**: Common dependencies are hoisted to the root `node_modules`
2. **Workspace Scripts**: Run commands across all workspaces with `--workspace` flag
3. **Parallel Development**: Backend and frontend can be developed independently
4. **Unified Build**: Single command to build all packages

## NPM Scripts

### Root Level Scripts

```bash
# Install all dependencies (root + workspaces)
npm install

# Build all packages
npm run build

# Run all tests
npm run test

# Clean all build artifacts
npm run clean

# Run backend and frontend dev servers concurrently
npm run dev
```

### Backend Scripts

```bash
# Install backend dependencies only
npm run backend:install

# Run backend dev server
npm run backend:dev

# Build backend
npm run backend:build

# Start production backend
npm run backend:start

# Run backend tests
npm run backend:test
```

### Frontend Scripts

```bash
# Install frontend dependencies only
npm run frontend:install

# Run frontend dev server
npm run frontend:dev

# Build frontend for production
npm run frontend:build

# Preview production build
npm run frontend:preview

# Run frontend tests
npm run frontend:test
```

### Solana Programs Scripts

```bash
# Build Anchor programs
npm run build:programs

# Test Anchor programs
npm run test:programs

# Deploy to devnet
npm run deploy:devnet

# Deploy to mainnet
npm run deploy:mainnet

# List program keys
npm run keys
```

## Workspace Benefits

### 1. Dependency Management
- **Shared Dependencies**: Common packages (TypeScript, testing libraries) are installed once at the root
- **Version Consistency**: Ensures all workspaces use the same versions of shared dependencies
- **Reduced Disk Space**: No duplicate `node_modules` across workspaces

### 2. Development Workflow
- **Independent Development**: Each workspace can be developed independently
- **Cross-Workspace References**: Workspaces can reference each other (e.g., shared types)
- **Parallel Execution**: Run dev servers for backend and frontend simultaneously

### 3. Build Orchestration
- **Unified Build**: Single command builds all packages in correct order
- **Incremental Builds**: Only rebuild changed packages
- **CI/CD Integration**: Simplified deployment pipeline

### 4. Code Sharing
- **Shared Types**: TypeScript types can be shared between backend and frontend
- **Shared Utilities**: Common utility functions in a shared package
- **Consistent Configuration**: ESLint, Prettier, TypeScript configs can be shared

## Package Relationships

```
┌─────────────────────────────────────────────────────────┐
│                    icb-protocol (root)                   │
│                                                          │
│  ┌──────────────────┐         ┌──────────────────┐     │
│  │     backend      │         │     frontend     │     │
│  │  (Node.js/TS)    │◄────────┤   (Vite/React)   │     │
│  │                  │  Types  │                  │     │
│  └────────┬─────────┘         └──────────────────┘     │
│           │                                              │
│           │ JSON-RPC / WebSocket                        │
│           │                                              │
│  ┌────────▼─────────────────────────────────────┐      │
│  │         programs/ (Solana/Anchor)             │      │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐   │      │
│  │  │icb-core  │  │icb-reserve│  │icb-token │   │      │
│  │  └──────────┘  └──────────┘  └──────────┘   │      │
│  └───────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘
```

## Development Workflow

### Initial Setup

```bash
# 1. Clone repository
git clone <repository-url>
cd icb-protocol

# 2. Install all dependencies
npm install

# 3. Build Solana programs
npm run build:programs

# 4. Deploy to devnet
npm run deploy:devnet
```

### Daily Development

```bash
# Start backend and frontend dev servers
npm run dev

# Or start individually:
npm run backend:dev    # Terminal 1
npm run frontend:dev   # Terminal 2
```

### Testing

```bash
# Run all tests
npm run test

# Or test individually:
npm run test:programs  # Anchor tests
npm run backend:test   # Backend tests
npm run frontend:test  # Frontend tests
```

### Production Build

```bash
# Build everything
npm run build

# Deploy programs
npm run deploy:mainnet

# Start backend
npm run backend:start

# Frontend is static - deploy dist/ to CDN
```

## Adding New Workspaces

To add a new workspace (e.g., `sdk/`):

1. Create the directory: `mkdir sdk`
2. Initialize package: `cd sdk && npm init -y`
3. Add to root `package.json`:
   ```json
   {
     "workspaces": [
       "backend",
       "frontend",
       "sdk"
     ]
   }
   ```
4. Run `npm install` at root to link the workspace

## Best Practices

### 1. Workspace Naming
- Use lowercase, hyphenated names (e.g., `icb-backend`, `icb-frontend`)
- Prefix with project name for clarity in global namespace

### 2. Dependency Management
- Install shared dependencies at root: `npm install -D typescript --workspace-root`
- Install workspace-specific deps: `npm install express --workspace=backend`

### 3. Scripts
- Use consistent script names across workspaces (`dev`, `build`, `test`)
- Prefix workspace-specific scripts in root (e.g., `backend:dev`)

### 4. Version Control
- Commit `package-lock.json` at root
- Don't commit workspace `node_modules/`
- Use `.gitignore` to exclude build artifacts

### 5. CI/CD
- Cache root `node_modules/` for faster builds
- Run tests in parallel across workspaces
- Build in dependency order (programs → backend → frontend)

## Troubleshooting

### Issue: Workspace not found
```bash
# Solution: Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### Issue: Version conflicts
```bash
# Solution: Use npm overrides in root package.json
{
  "overrides": {
    "package-name": "^1.0.0"
  }
}
```

### Issue: Circular dependencies
```bash
# Solution: Restructure to avoid circular refs
# Or use a shared package for common code
```

## Resources

- [npm Workspaces Documentation](https://docs.npmjs.com/cli/v7/using-npm/workspaces)
- [Anchor Workspace Guide](https://www.anchor-lang.com/docs/workspace)
- [Monorepo Best Practices](https://monorepo.tools/)

---

**Status**: ✅ Monorepo structure initialized and configured  
**Last Updated**: February 4, 2026
