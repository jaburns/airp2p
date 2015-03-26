package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
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

            _lobby = new Lobby(/*log*/);
            _lobby.addEventListener(P2PEvent.PEER_CONNECTED, peerConnect);
            _lobby.addEventListener(P2PEvent.PEER_DISCONNECTED, peerDisconnect);
            _lobby.connect();
        }

        private function log(msg:String) :void
        {
            _tf.appendText(msg);
            _tf.appendText("\n");
        }

        private function peerConnect(e:P2PEvent) :void
        {
            log("Joined lobby: "+e.data);
        }

        private function peerDisconnect(e:P2PEvent) :void
        {
            log("Left lobby: "+e.data);
        }
    }
}
