package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.text.TextFormat;

    import net.jaburns.airp2p.Lobby;

    //import net.jaburns.airp2p.LANAddress;

    public class Main extends Sprite
    {
        private var _tf :TextField;
        private var _lobby :Lobby;

        public function Main()
        {
            super();

            // support autoOrients
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            _tf = new TextField;
            _tf.y = 100;
            _tf.width = stage.stageWidth;
            _tf.height = stage.stageHeight - 100;
            addChild(_tf);

            _lobby = new Lobby(log);
            _lobby.addEventListener(Lobby.EVENT_PEER_CONNECTED, peersChanged);
            _lobby.addEventListener(Lobby.EVENT_PEER_DISCONNECTED, peersChanged);
            _lobby.connect();
        }

        private function log(msg:String) :void
        {
            _tf.appendText(msg);
            _tf.appendText("\n");
        }

        private function peersChanged(e:Event) :void
        {
            log("Lobby:");
            log(JSON.stringify(_lobby.getIPs()));
        }
    }
}
