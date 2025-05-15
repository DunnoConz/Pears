#!/bin/bash

# Setup script for Pears documentation

# Make script exit on error
set -e

# Navigate to docs directory
cd "$(dirname "$0")/docs"

# Install dependencies
echo "Installing documentation dependencies..."
npm install

# Create public directory for assets if it doesn't exist
mkdir -p public

# Copy project logo to public directory if it exists
if [ -f "../src/assets/logo.png" ]; then
  echo "Copying logo to docs public directory..."
  cp "../src/assets/logo.png" "./public/logo.png"
else
  echo "Logo not found, using placeholder..."
  # You can add code here to generate or download a placeholder logo
fi

# Run development server
echo "Starting documentation server..."
echo "You can view the documentation at http://localhost:5173/"
echo "Press Ctrl+C to stop the server"
npm run dev
