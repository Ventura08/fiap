#!/usr/bin/env node
/**
 * screenshot.js — Takes screenshots of URLs and saves to /tmp/
 * Usage:
 *   node screenshot.js <url> [output_path]
 *   node screenshot.js http://localhost:8080/agnello/
 *   node screenshot.js http://localhost:8080/agnello/ /tmp/catalogo.png full
 *
 * Args:
 *   url         - Required. URL to capture
 *   output      - Optional. Output file path (default: /tmp/screenshot.png)
 *   mode        - Optional. "full" for full page, "viewport" for above fold only (default: full)
 */

const puppeteer = require('puppeteer');

async function screenshot(url, outputPath = '/tmp/screenshot.png', mode = 'full') {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  console.log(`Navigating to ${url}...`);
  await page.goto(url, { waitUntil: 'networkidle2', timeout: 15000 });

  // Wait for fonts, animations and staggered card entrances to complete
  await new Promise(r => setTimeout(r, 1200));

  const fullPage = mode !== 'viewport';
  await page.screenshot({ path: outputPath, fullPage });

  console.log(`Screenshot saved: ${outputPath}`);
  await browser.close();
}

const [,, url, output, mode] = process.argv;
if (!url) {
  console.error('Usage: node screenshot.js <url> [output_path] [full|viewport]');
  process.exit(1);
}

screenshot(url, output || '/tmp/screenshot.png', mode || 'full').catch(e => {
  console.error(e.message);
  process.exit(1);
});
