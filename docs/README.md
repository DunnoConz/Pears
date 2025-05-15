# Pears Documentation

This directory contains the VitePress-powered documentation for Pears.

## Getting Started

To develop the documentation locally:

```bash
# Install dependencies
npm install

# Start the development server
npm run dev
```

## Building

To build the documentation:

```bash
npm run build
```

This will generate static files in the `.vitepress/dist` directory.

## Structure

- `.vitepress/` - VitePress configuration
- `public/` - Static assets like images
- `guide/` - User guide pages
- `reference/` - API reference pages
- `scripts/` - Helper scripts for documentation

## Deployment

To deploy the documentation:

```bash
npm run deploy
```

You can customize the deployment process by editing `scripts/deploy.js`.

## Environment Variables

- `DEPLOY_DIR` - Custom directory to deploy the built files
- `DEPLOY_TO_GITHUB` - Set to 'true' to deploy to GitHub Pages

## Customizing

To customize the documentation:

1. Edit `.vitepress/config.js` to update navigation, sidebar, etc.
2. Add or modify Markdown files in the appropriate directories
3. Add assets to the `public/` directory
