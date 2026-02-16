"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const child_process_1 = require("child_process");
const app = (0, express_1.default)();
const port = process.env.PORT || 65000;
app.get('/scrape', (_req, res) => {
    const py = (0, child_process_1.spawn)('python3', ['python/scraper.py']);
    let output = '';
    let err = '';
    py.stdout.on('data', (data) => {
        output += data.toString();
    });
    py.stderr.on('data', (data) => {
        err += data.toString();
    });
    py.on('close', (code) => {
        if (code === 0) {
            try {
                const result = JSON.parse(output);
                res.type('json').send(result);
            }
            catch (e) {
                res.type('text').send(output);
            }
        }
        else {
            res.status(500).send({ error: err || `python exited ${code}` });
        }
    });
});
app.get('/', (_req, res) => {
    res.send('RawScraper running');
});
app.listen(port, () => {
    console.log(`RawScraper listening on ${port}`);
});
//# sourceMappingURL=index.js.map