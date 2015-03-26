package net.jaburns.airp2p
{
    import flash.events.Event;

    public class P2PEvent extends Event
    {
        static public const PEER_CONNECTED :String = "peerConnected";
        static public const PEER_DISCONNECTED :String = "peerDisconnected";

        public var data:Object = null;

        public function P2PEvent(type:String, data:Object=null)
        {
            super(type);
            this.data = data;
        }

        override public function clone():Event
        {
            return new P2PEvent(type, data);
        }
    }
}
