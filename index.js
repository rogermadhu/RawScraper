const express = require('express');
const { spawn } = require('child_process');
const app = express();
const port = process.env.PORT || 65000;

app.get('/scrape', (req, res) => {
  const py = spawn('python3', ['raw_scraper.py']);
  let output = '';
  let err = '';
  py.stdout.on('data', data => output += data.toString());
  py.stderr.on('data', data => err += data.toString());
  py.on('close', code => {
    if (code === 0) {
      try {
        res.type('json').send(JSON.parse(output));
      } catch (e) {
        res.type('text').send(output);
      }
    } else {
      res.status(500).send({ error: err || `python exited ${code}` });
    }
  });
});

app.get('/', (req, res) => res.send('RawScraper running'));

app.listen(port, () => console.log(`RawScraper listening on ${port}`));
