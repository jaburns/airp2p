package net.jaburns.airp2p
{
    public class PeerGroup
    {
        private var _bf :Function = null;

        public function get broadcast() :Function { return _bf; }

        public function PeerGroup(broadcastFunction:Function)
        {
            _bf = broadcastFunction;
        }
    }
}
