package net.jaburns.airp2p
{
    import flash.events.Event;

    public class LobbyEvent extends Event
    {
        static public const PEER_CONNECTED :String = "peerConnected";
        static public const PEER_DISCONNECTED :String = "peerDisconnected";
        static public const PEER_COMMITTED :String = "peerCommitted";
        static public const PEER_UNCOMMITTED :String = "peerUncommitted";

        static public const LOBBY_COMPLETE :String = "lobbyComplete";


        public var data:Object = null;

        public function LobbyEvent(type:String, data:Object=null)
        {
            super(type);
            this.data = data;
        }

        override public function clone():Event
        {
            return new LobbyEvent(type, data);
        }
    }
}
