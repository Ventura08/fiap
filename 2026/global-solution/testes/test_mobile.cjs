// Validação real da interface em navegador com viewport de celular.
const { chromium } = require('playwright');
const assert = require('node:assert/strict');
(async () => {
  const browser = await chromium.launch({headless: true, executablePath: process.env.CHROME_PATH || '/usr/bin/google-chrome', args: ['--no-sandbox']});
  const page = await browser.newPage({viewport: {width: 390, height: 844}, deviceScaleFactor: 1});
  try {
    await page.goto('http://localhost:8080');
    await page.locator('#login [name=email]').fill('admin@example.test');
    await page.locator('#login [name=senha]').fill('EscolhaUmaSenhaForte123');
    await page.locator('#login button').click();
    await page.locator('#inicio').waitFor({state:'visible'});
    assert.match(await page.locator('#inicio').innerText(), /Olá, Administrador/);
    console.log('OK: login e tela inicial mobile');
    await page.locator('[data-view=locais]').click();
    await page.getByText('Córrego Esperança', {exact:false}).first().waitFor();
    console.log('OK: tela de locais lê dados da API');
    await page.locator('[data-view=simulacao]').click();
    await page.locator('#sensores').selectOption('1');
    await page.locator('#medicao [name=valor]').fill('2.5');
    await page.locator('#medicao button').click();
    await page.getByText('Medição registrada e alerta gerado.').waitFor();
    await page.locator('[data-view=alertas]').click();
    await page.getByText('Limite de NIVEL atingido', {exact:false}).first().waitFor();
    console.log('OK: medição enviada e alerta exibido');
    const overflow=await page.evaluate(() => document.documentElement.scrollWidth > innerWidth);
    assert.equal(overflow, false, 'interface não deve ter rolagem horizontal na tela de 390 px');
    console.log('OK: layout sem rolagem horizontal em 390 px');
    await page.locator('#sair').click();
    await page.locator('#login').waitFor({state:'visible'});
    await page.route('**/api/login', route => route.abort('failed'));
    await page.locator('#login [name=email]').fill('admin@example.test');
    await page.locator('#login [name=senha]').fill('EscolhaUmaSenhaForte123');
    await page.locator('#login button').click();
    await page.getByText('Não foi possível conectar.', {exact:false}).waitFor();
    console.log('OK: erro de conexão apresentado ao usuário');
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode=1; });
