#!/bin/bash

echo "🚀 Starting Agentic Reserve System (ARS) - Local Development"
echo "============================================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Redis is running
echo -e "${BLUE}Checking Redis...${NC}"
if ! redis-cli ping > /dev/null 2>&1; then
    echo -e "${YELLOW}Redis is not running. Starting Redis...${NC}"
    redis-server --daemonize yes
    sleep 2
    if redis-cli ping > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Redis started successfully${NC}"
    else
        echo -e "${RED}✗ Failed to start Redis${NC}"
        echo "Please install Redis: https://redis.io/download"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Redis is running${NC}"
fi

echo ""

# Check if Node.js is installed
echo -e "${BLUE}Checking Node.js...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js is not installed${NC}"
    echo "Please install Node.js: https://nodejs.org/"
    exit 1
fi
echo -e "${GREEN}✓ Node.js $(node --version)${NC}"

echo ""

# Install backend dependencies if needed
echo -e "${BLUE}Checking backend dependencies...${NC}"
cd backend
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing backend dependencies...${NC}"
    npm install
fi
echo -e "${GREEN}✓ Backend dependencies ready${NC}"
cd ..

echo ""

# Install frontend dependencies if needed
echo -e "${BLUE}Checking frontend dependencies...${NC}"
cd frontend
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing frontend dependencies...${NC}"
    npm install
fi
echo -e "${GREEN}✓ Frontend dependencies ready${NC}"
cd ..

echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}Starting services...${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""

# Start backend
echo -e "${BLUE}Starting Backend API (Port 3000)...${NC}"
cd backend
npm run dev > ../logs/backend.log 2>&1 &
BACKEND_PID=$!
echo -e "${GREEN}✓ Backend started (PID: $BACKEND_PID)${NC}"
cd ..

# Wait for backend to be ready
echo -e "${YELLOW}Waiting for backend to be ready...${NC}"
sleep 5

# Start frontend
echo -e "${BLUE}Starting Frontend (Port 5173)...${NC}"
cd frontend
npm run dev > ../logs/frontend.log 2>&1 &
FRONTEND_PID=$!
echo -e "${GREEN}✓ Frontend started (PID: $FRONTEND_PID)${NC}"
cd ..

echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}🎉 ARS is running!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
echo -e "${BLUE}Services:${NC}"
echo -e "  • Backend API:  ${GREEN}http://localhost:3000${NC}"
echo -e "  • Frontend:     ${GREEN}http://localhost:5173${NC}"
echo -e "  • Redis:        ${GREEN}localhost:6379${NC}"
echo ""
echo -e "${BLUE}Logs:${NC}"
echo -e "  • Backend:  tail -f logs/backend.log"
echo -e "  • Frontend: tail -f logs/frontend.log"
echo ""
echo -e "${BLUE}API Endpoints:${NC}"
echo -e "  • GET  /ili/current"
echo -e "  • GET  /icr/current"
echo -e "  • GET  /reserve/state"
echo -e "  • GET  /proposals"
echo -e "  • GET  /revenue/current"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"
echo ""

# Save PIDs to file
mkdir -p logs
echo "$BACKEND_PID" > logs/backend.pid
echo "$FRONTEND_PID" > logs/frontend.pid

# Wait for Ctrl+C
trap "echo ''; echo 'Stopping services...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; rm -f logs/*.pid; echo 'Services stopped'; exit 0" INT

# Keep script running
wait
