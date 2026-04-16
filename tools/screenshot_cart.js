const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch({ headless: 'new', args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });
  await page.goto('http://localhost:8080/agnello/catalogo.jsp', { waitUntil: 'networkidle2' });
  await new Promise(r => setTimeout(r, 800));
  // Add 2 wines
  const btns = await page.$$('.btn-add');
  await btns[0].click(); await new Promise(r => setTimeout(r, 200));
  await btns[2].click(); await new Promise(r => setTimeout(r, 200));
  // Open cart manually via icon
  await page.click('#navCartIcon');
  await new Promise(r => setTimeout(r, 600));
  await page.screenshot({ path: '/tmp/screen_cart.png', fullPage: false });
  console.log('Screenshot saved: /tmp/screen_cart.png');
  await browser.close();
})().catch(e => { console.error(e.message); process.exit(1); });
