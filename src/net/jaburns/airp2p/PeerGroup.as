package net.jaburns.airp2p
{
    import flash.events.EventDispatcher;
    import flash.events.NetStatusEvent;
    import flash.events.TimerEvent;
    import flash.net.GroupSpecifier;
    import flash.net.NetConnection;
    import flash.net.NetGroup;
    import flash.utils.Timer;

    internal class PeerGroup extends EventDispatcher
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

        private var _pickHostTimer :Timer = null;
        private var _hostIP :String = null;
        private var _potentialHosts :Array = null;


        public function get localIP () :String { return _ip; }
        public function get hostIP () :String { return _hostIP; }


        public function PeerGroup(log:Function=null)
        {
            if (log !== null) {
                _log = function(msg:String) :void {
                    log("[com.jaburns.airp2p.PeerGroup] "+msg);
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

            _netConn = new NetConnection;
            _netConn.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
            _netConn.connect("rtmfp:");

            _log("IP: "+_ip);
            _potentialHosts = [_ip];
        }

        public function getIPs() :Vector.<String>
        {
            var ret :Vector.<String> = new <String> [];
            for (var k:String in _peerIPs) {
                ret.push(_peerIPs[k]);
            }
            return ret;
        }

    // ========================================================================

        private function netStatus(e:NetStatusEvent) :void
        {
            _log("Status: "+e.info.code);

            switch (e.info.code) {
                case "NetConnection.Connect.Success":
                    var groupspec :GroupSpecifier = new GroupSpecifier(GROUP_NAME);
                    groupspec.postingEnabled = true;
                    groupspec.ipMulticastMemberUpdatesEnabled = true;

                    try { // iOS throws an ArgError here for some reason, but doesn't mind if you continue.
                        groupspec.addIPMulticastAddress(MULTICAST_ADDRESS, MULTICAST_PORT);
                    } catch (e:ArgumentError) { }

                    _group = new NetGroup(_netConn, groupspec.groupspecWithAuthorizations());
                    _group.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
                    break;

                case "NetGroup.Connect.Success":
                    _id = _group.convertPeerIDToGroupAddress(_netConn.nearID);
                    _log("ID: "+_id);
                    setPeer(_id, _ip);
                    broadcastSelf();

                    _pickHostTimer = new Timer(5000, 1);
                    _pickHostTimer.addEventListener(TimerEvent.TIMER, pickHostTimer_tick);
                    _pickHostTimer.start();

                    break;

                case "NetGroup.Neighbor.Connect":
                    broadcastSelf();
                    break;

                case "NetGroup.Posting.Notify":
                    if (e.info.message.host) {
                        setHost(e.info.message.host);
                    }
                    else if (_potentialHosts) {
                        _potentialHosts.push(e.info.message.ip);
                    }

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

        private function pickHostTimer_tick(e:TimerEvent) :void
        {
            setHost(_potentialHosts.sort().pop());
            broadcastSelf();
        }

        private function setHost(ip:String) :void
        {
            if (_hostIP) return;

            _log("Host IP determined: " + ip);
            _hostIP = ip;

            if (_pickHostTimer) {
                _pickHostTimer.stop();
                _pickHostTimer.removeEventListener(TimerEvent.TIMER, pickHostTimer_tick);
                _pickHostTimer = null;
            }
            _potentialHosts = null;

            dispatchEvent(new PeerGroupEvent(PeerGroupEvent.HOST_DETERMINED, _hostIP));
        }

        private function broadcastSelf() :void
        {
            _group.post({ id:_id, ip:_ip, host:_hostIP });
        }

        private function setPeer(id:String, ip:String) :void
        {
            if (_peerIPs[id] !== ip) {
                _peerIPs[id] = ip;
                _log(ip + " has connected to lobby");
                dispatchEvent(new PeerGroupEvent(PeerGroupEvent.PEER_CONNECTED, ip));
            }
        }

        private function deletePeer(id:String) :void
        {
            if (_peerIPs[id]) {
                var deadIP:String = _peerIPs[id];
                delete _peerIPs[id];
                _log(localIP + " has left the lobby");
                dispatchEvent(new PeerGroupEvent(PeerGroupEvent.PEER_DISCONNECTED, deadIP));
            }
        }
    }
}
