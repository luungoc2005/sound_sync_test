import { Router } from 'express';
import channelsRouter from './channels';
import playerRouter from './player';

const router = Router();

router.get('/', (req, res) => {
  res.send('<h1>Hello world</h1>');
});

router.use('/channels', channelsRouter);
router.use('/player', playerRouter);

export default router;