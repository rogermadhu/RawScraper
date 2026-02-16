import express, { Request, Response } from 'express';
import { spawn } from 'child_process';

const app = express();
const port = process.env.PORT || 65000;

interface ScraperResponse {
  [key: string]: unknown;
}

app.get('/scrape', (_req: Request, res: Response): void => {
  const py = spawn('python3', ['python/scraper.py']);
  let output = '';
  let err = '';

  py.stdout.on('data', (data: Buffer) => {
    output += data.toString();
  });

  py.stderr.on('data', (data: Buffer) => {
    err += data.toString();
  });

  py.on('close', (code: number) => {
    if (code === 0) {
      try {
        const result: ScraperResponse = JSON.parse(output);
        res.type('json').send(result);
      } catch (e) {
        res.type('text').send(output);
      }
    } else {
      res.status(500).send({ error: err || `python exited ${code}` });
    }
  });
});

app.get('/', (_req: Request, res: Response): void => {
  res.send('RawScraper running');
});

app.listen(port, () => {
  console.log(`RawScraper listening on ${port}`);
});
