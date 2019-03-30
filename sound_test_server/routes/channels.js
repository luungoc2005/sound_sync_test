import { Router } from 'express';
import { listener } from '../app';

const router = Router();

router.get('/', (req, res) => {
  res.json(
    listener.getChannels()
      .filter(channel => channel.active)
      .map(channel => ({
        name: channel.name,
        id: channel.id,
        status: channel.getStatus(),
      }))
  );
});

router.post('/create', (req, res) => {
  const name = req.query.name;
  if (name) {
    const newChannel = listener.addChannel(name)
    res.json({
      channelId: newChannel.id,
      token: newChannel.token,
    })
  }
  else {
    res.boom.badRequest('Channel name must be specified');
  }
});

router.post('/destroy', (req, res) => {
  const id = req.query.id;
  if (id) {
    listener.removeChannel(id);
  }
  else {
    res.boom.badRequest('Channel id must be specified');
  }
});

export default router;