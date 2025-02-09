import express from 'express';
import { regionInformations } from './region_informations';

const app = express();
const port = 3000;

app.get('/get_location')

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  return console.log(`Express is listening at http://localhost:${port}`);
});
