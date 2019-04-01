import { Router } from 'express';
import { listener } from '../app';
import konsole from '../utils/konsole';
import path from 'path';
import multer from 'multer';
import Uuid from 'uuid';

import { Media } from '../sockets/media';

const SAVE_DIR = '_tmp'
const storage = multer.diskStorage({
  destination: function(req, file, callback) {
    callback(null, SAVE_DIR);
  },
  filename: function(req, file, callback) {
      // callback(null, file.fieldname + "_" + Date.now() + "_" + file.originalname);
      callback(null, `${Uuid.v1()}_${file.originalname}`);
  }
})

const router = Router();

router.get('/', (req, res) => {
  res.send('<h1>Hello world</h1>');
});

const fileFilter = (req, file, cb) => {
  const reqBody = req.body;
  if (reqBody.channelId 
    && reqBody.token 
    && reqBody.fileName
    && listener.getChannels()
        .findIndex(item => item.id === reqBody.channelId && item.token === reqBody.token) > -1) {
    cb(null, true);
  }
  else {
    cb(null, false);
  }
}

const uploadMedia = multer({
  storage,
  fileFilter
}).single('media')

router.post('/start', uploadMedia, (req, res) => {
  if (!req.file) {
    res.boom('An error orcurred');
  }
  else {
    const reqBody = req.body;
  
    const channel = listener.getChannels()
      .find(item => item.id === reqBody.channelId
        && item.token === reqBody.token);
  
    if (!channel) {
      res.boom.badRequest('channelId or token is invalid');
      return;
    }
    const metadata = {
      path: req.file.path,
      fileSize: req.file.size,
      ...reqBody,
    }
    channel.media = new Media(reqBody.fileName, metadata);
    konsole.log(metadata);
    res.json({message: 'File uploaded sucessfully'});
  }
});

router.get('/download', (req, res) => {
  const { channelId } = req.query
  if (channelId) {
    const channel = listener.getChannels()
      .find(item => item.id === channelId);
    konsole.log(channelId);
    if (channel && channel.media) {
      res.download(channel.media.path);
    }
    else {
      res.boom.badRequest('Media not found');
    }
  }
  else {
    res.boom.badRequest('channelId not found');
  }
});

export default router;