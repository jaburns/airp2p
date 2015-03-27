package net.jaburns.airp2p
{
    public class PeerGroup
    {
        private var _broadcaster :Function = null;
        private var _receiver    :Function = null;

        public function PeerGroup()
        {
        }

        public function broadcast(msg:String) :void
        {
            if (_broadcaster) _broadcaster(msg);
        }

        public function bindReceiver(receiver:Function) :void
        {
            _receiver = receiver;
        }

        internal function receive(msg:String) :void
        {
            if (_receiver) _receiver(msg);
        }

        internal function bindBroadcaster(broadcaster:Function) :void
        {
            _broadcaster = broadcaster;
        }
    }
}
