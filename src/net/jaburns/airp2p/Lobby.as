package net.jaburns.airp2p
{
    import flash.events.EventDispatcher;
    import flash.events.NetStatusEvent;
    import flash.net.GroupSpecifier;
    import flash.net.NetConnection;
    import flash.net.NetGroup;

    public class Lobby extends EventDispatcher
    {
        static private const GROUP_NAME :String = "airp2p/localgroup";
        static private const MULTICAST_ADDRESS :String = "225.225.0.1";
        static private const MULTICAST_PORT :String = "30321";


        private var _log :Function = null;

        private var _id :String = null;
        private var _ip :String = null;

        private var _netConn :NetConnection = null;
        private var _group :NetGroup = null;

        private var _hasSharedIP :Boolean = false;
        private var _peerIPs :Object = {};
        private var _committedPeerIPs :Vector.<String> = new <String> [];


        public function get ip () :String { return _ip; }
        public function get committed() :Boolean { return _committedPeerIPs.indexOf(_ip) >= 0; }


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

        public function commit() :void
        {
            setThisCommit(true);
        }

        public function uncommit() :void
        {
            setThisCommit(false);
        }

        public function getIPs() :Vector.<String>
        {
            var ret :Vector.<String> = new <String> [];
            for (var k:String in _peerIPs) {
                ret.push(_peerIPs[k]);
            }
            return ret;
        }

        public function getCommittedIPs() :Vector.<String>
        {
            return _committedPeerIPs.slice();
        }

    // ========================================================================

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
                    if (e.info.message.id) {
                        setPeer(e.info.message.id, e.info.message.ip);
                        if (!_hasSharedIP) {
                            _hasSharedIP = true;
                            broadcastSelf();
                        }
                    }
                    else {
                        setCommit(e.info.message.ip, e.info.message.commit);
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

        private function setThisCommit(commit:Boolean) :void
        {
            if (!_group) {
                throw new Error("Lobby is not connected, cannot commit to a match.");
            }

            // Duplicate messages are ignored, need to add random value to force Notify event.
            _group.post({ ip:_ip, commit:commit, rand:Math.random() });
            setCommit(_ip, commit);
        }

        private function setCommit(ip:String, commit:Boolean) :void
        {
            var index:int = _committedPeerIPs.indexOf(ip);

            if (commit) {
                if (index < 0) {
                    _committedPeerIPs.push(ip);
                    dispatchEvent(new P2PEvent(P2PEvent.PEER_COMMITTED, ip));
                    checkAllCommitted();
                }
            }
            else if (index >= 0) {
                _committedPeerIPs.splice(index, 1);
                dispatchEvent(new P2PEvent(P2PEvent.PEER_UNCOMMITTED, ip));
            }
        }

        private function checkAllCommitted() :void
        {
            if (getIPs().length === _committedPeerIPs.length) {
                dispatchEvent(new P2PEvent(P2PEvent.LOBBY_COMPLETE, null));
            }
        }

        private function setPeer(id:String, ip:String) :void
        {
            if (_peerIPs[id] !== ip) {
                _peerIPs[id] = ip;
                dispatchEvent(new P2PEvent(P2PEvent.PEER_CONNECTED, ip));
            }
        }

        private function deletePeer(id:String) :void
        {
            if (_peerIPs[id]) {
                var deadIP:String = _peerIPs[id];
                delete _peerIPs[id];
                dispatchEvent(new P2PEvent(P2PEvent.PEER_DISCONNECTED, deadIP));
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
