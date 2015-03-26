package net.jaburns.airp2p
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.NetStatusEvent;
    import flash.net.GroupSpecifier;
    import flash.net.NetConnection;
    import flash.net.NetGroup;

    // Reference: http://tomkrcha.com/?p=1803

    public class Lobby extends EventDispatcher
    {
        static public const EVENT_PEER_CONNECTED :String = "peerConnected";
        static public const EVENT_PEER_DISCONNECTED :String = "peerDisconnected";

        static private const GROUP_NAME :String = "airp2p/localgroup";
        static private const MULTICAST_ADDRESS :String = "225.225.0.1";
        static private const MULTICAST_PORT :String = "30321";


        private var _log :Function = null;

        private var _id :String = null;
        private var _ip :String = null;

        private var _netConn :NetConnection = null;
        private var _group :NetGroup = null;

        private var _hasSharedIP :Boolean = false;
        private var _peerCount :int = 0;
        private var _peerIPs :Object = {};


        public function Lobby(log:Function=null)
        {
            if (log !== null) {
                _log = function(msg:String) :void {
                    log("[com.jaburns.airp2p.Lobby] "+msg);
                };
            } else {
                _log = function(msg:String) :void { };
            }
        }

        public function connect() :void
        {
            _ip = LANAddress.find();
            if (_ip === null) {
                throw new Error("Could not determine IP adress on local network.");
            }

            _netConn = new NetConnection();
            _netConn.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
            _netConn.connect("rtmfp:");

            _log("IP: "+_ip);
        }

        public function getIPs() :Vector.<String>
        {
            var ret :Vector.<String> = new <String> [];
            for (var k:String in _peerIPs) {
                ret.push(_peerIPs[k]);
            }
            return ret;
        }

        private function netStatus(e:NetStatusEvent) :void
        {
            _log("Status: "+e.info.code);

            switch (e.info.code) {
                case "NetConnection.Connect.Success":
                    setupGroup();
                    break;

                case "NetGroup.Connect.Success":
                    _id = _group.convertPeerIDToGroupAddress(_netConn.nearID);
                    _log("ID: "+_id);
                    setPeer(_id, _ip);
                    broadcastSelf();
                    break;

                case "NetGroup.Neighbor.Connect":
                    broadcastSelf();
                    break;

                case "NetGroup.Posting.Notify":
                    setPeer(e.info.message.id, e.info.message.ip);
                    if (!_hasSharedIP) {
                        _hasSharedIP = true;
                        broadcastSelf();
                    }
                    break;

                case "NetGroup.Neighbor.Disconnect":
                    deletePeer(e.info.neighbor);
                    break;
            }
        }

        private function broadcastSelf() :void
        {
            _group.post({ id:_id, ip:_ip });
        }

        private function setPeer(id:String, ip:String) :void
        {
            if (_peerIPs[id] !== ip) {
                _peerIPs[id] = ip;
                dispatchEvent(new Event(EVENT_PEER_CONNECTED));
            }
        }

        private function deletePeer(id:String) :void
        {
            if (_peerIPs[id]) {
                delete _peerIPs[id];
                dispatchEvent(new Event(EVENT_PEER_DISCONNECTED));
            }
        }

        private function setupGroup() :void
        {
            var groupspec :GroupSpecifier = new GroupSpecifier(GROUP_NAME);
            groupspec.postingEnabled = true;
            groupspec.ipMulticastMemberUpdatesEnabled = true;

            try {
                groupspec.addIPMulticastAddress(MULTICAST_ADDRESS, MULTICAST_PORT);
            } catch (e:ArgumentError) { }

            _group = new NetGroup(_netConn, groupspec.groupspecWithAuthorizations());
            _group.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
        }
    }
}
