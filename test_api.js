const https = require('https');

const key = 'AIzaSyBwZvn71CY3gtlRCzNQv0WS-vpELwXIxH8';
const postData = JSON.stringify({
  contents: [{ role: 'user', parts: [{ text: 'Hello' }] }],
  generationConfig: { temperature: 0.7, maxOutputTokens: 1024 }
});

const options = {
  hostname: 'generativelanguage.googleapis.com',
  port: 443,
  path: '/v1beta/models/gemini-2.5-flash:streamGenerateContent?key=' + key,
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

const req = https.request(options, (res) => {
  console.log('Status:', res.statusCode);
  let body = '';
  res.on('data', (chunk) => {
    body += chunk;
    console.log('Chunk:', chunk.toString().substring(0, 200));
  });
  res.on('end', () => {
    console.log('---END---');
    console.log('Full body:', body);
  });
});

req.on('error', (e) => console.error('Error:', e.message));
req.write(postData);
req.end();