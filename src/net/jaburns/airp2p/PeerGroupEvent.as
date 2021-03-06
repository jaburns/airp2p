package net.jaburns.airp2p
{
    import flash.events.Event;

    internal class PeerGroupEvent extends Event
    {
        static public const PEER_CONNECTED :String = "peerConnected";
        static public const PEER_DISCONNECTED :String = "peerDisconnected";
        static public const HOST_DETERMINED :String = "hostDetermined";
        static public const HOST_DISCONNECTED :String = "hostDisconnected";

        public var ip :String = null;

        public function PeerGroupEvent(type:String, ip:String=null)
        {
            super(type);
            this.ip = ip;
        }

        override public function clone():Event
        {
            return new PeerGroupEvent(type, ip);
        }
    }
}
