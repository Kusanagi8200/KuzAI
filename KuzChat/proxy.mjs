import express from 'express';
import fetch from 'node-fetch';

const app = express();
app.use(express.json());

app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.sendStatus(200);
  next();
});

app.post('/proxy', async (req, res) => {
  const { prompt, model } = req.body;

  if (!prompt || !model) return res.status(400).send('Missing prompt or model');

  try {
    const response = await fetch('http://127.0.0.1:11434/api/generate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ model, prompt })
    });

    response.body.on('data', chunk => res.write(chunk));
    response.body.on('end', () => res.end());

  } catch (err) {
    console.error(err);
    res.status(500).send('Error connecting to Ollama');
  }
});

app.listen(3000, () => console.log('Proxy running on port 3000'));
