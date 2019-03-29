import dotenv from 'dotenv';
import router from './routes';
import boom from 'express-boom';
import bodyParser from 'body-parser';
import cors from 'cors';
import { createSocketListener } from './sockets';

dotenv.config();

const app = require('express')();
const http = require('http').Server(app);

app.use(boom());
app.use(cors());
app.use(bodyParser.json()); 
app.use(bodyParser.urlencoded({ extended: true }));

app.use('/', router);

http.listen(3000, () => {
  console.log('listening on *:3000');
});

export const listener = createSocketListener(http);

export default app;