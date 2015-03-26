package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    import net.jaburns.airp2p.Lobby;
    import net.jaburns.airp2p.P2PEvent;

    public class Main extends Sprite
    {
        private var _tf :TextField;
        private var _lobby :Lobby;

        public function Main()
        {
            super();

            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            _tf = new TextField;
            _tf.y = 100;
            _tf.width = stage.stageWidth;
            _tf.height = stage.stageHeight - 100;
            addChild(_tf);

            stage.addEventListener(MouseEvent.CLICK, stage_click);

            _lobby = new Lobby(log);
            _lobby.addEventListener(P2PEvent.PEER_CONNECTED, peerConnect);
            _lobby.addEventListener(P2PEvent.PEER_DISCONNECTED, peerDisconnect);
            _lobby.addEventListener(P2PEvent.PEER_COMMITTED, peerCommit);
            _lobby.addEventListener(P2PEvent.PEER_UNCOMMITTED, peerUncommit);
            _lobby.addEventListener(P2PEvent.LOBBY_COMPLETE, lobbyComplete);
            _lobby.connect();
        }

        private function log(msg:String) :void
        {
            _tf.appendText(msg);
            _tf.appendText("\n");
        }

        private function stage_click(e:*) :void
        {
            log("hi");
            if (_lobby.committed) {
                _lobby.uncommit();
            } else {
                _lobby.commit();
            }
        }

        private function peerConnect(e:P2PEvent) :void
        {
            log("Joined lobby: "+e.data);
        }

        private function peerDisconnect(e:P2PEvent) :void
        {
            log("Left lobby: "+e.data);
        }

        private function peerCommit(e:P2PEvent) :void
        {
            log("Committed to match: "+e.data);
        }

        private function peerUncommit(e:P2PEvent) :void
        {
            log("Left match: "+e.data);
        }

        private function lobbyComplete(e:P2PEvent) :void
        {
            log("Everyone's in! Starting match!");
        }
    }
}
