/**
 * Simple deployment script for the Pears documentation
 * This can be enhanced to deploy to GitHub Pages, Netlify, or other services
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const distDir = path.resolve(__dirname, '../.vitepress/dist');
const deployDir = process.env.DEPLOY_DIR || distDir;

console.log('Deploying documentation...');

// Check if build directory exists
if (!fs.existsSync(distDir)) {
  console.error('Error: Build directory does not exist. Run npm run build first.');
  process.exit(1);
}

try {
  // If deploying to a specific directory
  if (deployDir !== distDir) {
    console.log(`Copying files to ${deployDir}...`);
    execSync(`mkdir -p ${deployDir} && cp -R ${distDir}/* ${deployDir}/`);
  }

  // Example: deploy to GitHub Pages
  if (process.env.DEPLOY_TO_GITHUB === 'true') {
    console.log('Deploying to GitHub Pages...');
    execSync('npx gh-pages -d .vitepress/dist');
  }

  console.log('Documentation deployed successfully!');
} catch (error) {
  console.error('Deployment failed:', error.message);
  process.exit(1);
}
