package net.jaburns.airp2p
{
    import flash.events.NetStatusEvent;
    import flash.net.GroupSpecifier;
    import flash.net.NetConnection;
    import flash.net.NetGroup;

    public class Lobby
    {
        static private const GROUP_NAME :String = "airp2p/localgroup";
        static private const MULTICAST_ADDRESS :String = "225.225.0.1";
        static private const MULTICAST_PORT :String = "30321";

        private var _traceFn :Function;

        private var _ip :String;
        private var _nc :NetConnection;
        private var _group :NetGroup;
        private var _userName :String;
        private var _hasSharedIP :Boolean;

        //http://tomkrcha.com/?p=1803

        public function Lobby(traceFn:Function)
        {
            _traceFn = traceFn;

            // Connect to local RTMFP group and share IP.

            // Each time someone new connects to the group, broadcast own IP.
            // When receiving other IPs add them to a list.
            // Should now have a list of IPs on this LAN which we can make socket connections to.
        }

        public function connect() :void
        {
            _ip = LANAddress.find();
            if (_ip === null) {
                throw new Error("Could not determine IP adress on local network.");
            }

            _traceFn("Lobby: Local IP is "+_ip);

            _nc = new NetConnection();
            _nc.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
            _nc.connect("rtmfp:");
        }

        private function netStatus(event:NetStatusEvent) :void
        {
            _traceFn("Lobby:NetStatusEvent: "+event.info.code);

            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    setupGroup();
                    break;

                case "NetGroup.Neighbor.Connect":
                    _group.post(_ip);
                    break;

                case "NetGroup.Posting.Notify":
                    _traceFn("Lobby:MessageReceived: "+event.info.message);

                    if (!_hasSharedIP) {
                        _hasSharedIP = true;
                        _group.post(_ip);
                    }
                    break;

                // TODO Handle disconnect and neighbor connection
            }
        }

        private function setupGroup() :void
        {
            var groupspec :GroupSpecifier = new GroupSpecifier(GROUP_NAME);
            groupspec.postingEnabled = true;
            groupspec.ipMulticastMemberUpdatesEnabled = true;

            try {
                groupspec.addIPMulticastAddress(MULTICAST_ADDRESS, MULTICAST_PORT);
            } catch (e:ArgumentError) {
                _traceFn("Caught ArgumentError thrown from addIPMulticastAddress");
            }

            _group = new NetGroup(_nc, groupspec.groupspecWithAuthorizations());
            _group.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
        }
    }
}

