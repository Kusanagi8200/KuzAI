import express from 'express';
import fetch from 'node-fetch';

const app = express();
app.use(express.json());

// Middleware global CORS
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*'); // toutes origines autorisées
  res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200); // réponse aux pré-demandes CORS
  }
  next();
});

app.post('/proxy', async (req, res) => {
  const { prompt } = req.body;

  try {
    const response = await fetch('http://10.12.248.187:11434/api/generate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ model: 'mistral', prompt })
    });

    // Ajouter les headers CORS avant de streamer
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    response.body.pipe(res);

  } catch (err) {
    res.status(500).send('Error');
  }
});
