package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    import net.jaburns.airp2p.Lobby;
    import net.jaburns.airp2p.LobbyEvent;
    import net.jaburns.airp2p.PeerGroup;

    public class Main extends Sprite
    {
        private var _tf :TextField;
        private var _lobby :Lobby;

        private var _clickFunction :Function;

        public function Main()
        {
            super();

            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            _tf = new TextField;
            _tf.y = 100;
            _tf.width = stage.stageWidth;
            _tf.height = 9000;
            addChild(_tf);

            stage.addEventListener(MouseEvent.CLICK, stage_click);

            _lobby = new Lobby(false, log);
            _lobby.addEventListener(LobbyEvent.PEER_CONNECTED, peerConnect);
            _lobby.addEventListener(LobbyEvent.PEER_DISCONNECTED, peerDisconnect);
            _lobby.addEventListener(LobbyEvent.PEER_COMMITTED, peerCommit);
            _lobby.addEventListener(LobbyEvent.PEER_UNCOMMITTED, peerUncommit);
            _lobby.addEventListener(LobbyEvent.LOBBY_COMPLETE, lobbyComplete);
            _lobby.connect();

            _clickFunction = toggleCommit;
        }

        private function peerConnect(e:LobbyEvent) :void { }
        private function peerDisconnect(e:LobbyEvent) :void { }
        private function peerCommit(e:LobbyEvent) :void { }
        private function peerUncommit(e:LobbyEvent) :void { }

        private function log(msg:String) :void
        {
            _tf.appendText(msg);
            _tf.appendText("\n");
        }

        private function stage_click(e:*) :void
        {
            if (_clickFunction) {
                _clickFunction();
            }
        }

        private function toggleCommit() :void
        {
            if (_lobby.committed) {
                _lobby.uncommit();
            } else {
                _lobby.commit();
            }
        }

        private function lobbyComplete(e:LobbyEvent) :void
        {
            var peers:PeerGroup = e.data as PeerGroup;

            peers.bindReceiver(function(msg:String) {
                log("Received: "+msg);
            });

            _clickFunction = function() :void {
                var msg:String = Math.random().toString();
                log("Sent: "+msg);
                peers.broadcast(msg);
            };
        }
    }
}
