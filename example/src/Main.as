package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.text.TextField;

    import net.jaburns.airp2p.Lobby;

    //import net.jaburns.airp2p.LANAddress;

    public class Main extends Sprite
    {
        public function Main()
        {
            super();

            var tf :TextField = new TextField;
            tf.y = 100;
            tf.width = stage.stageWidth;
            tf.height = stage.stageHeight - 100;
            addChild(tf);

            var log:Function = function(msg:String) :void {
                tf.appendText(msg);
                tf.appendText("\n");
            };

            // support autoOrients
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            var lobby:Lobby = new Lobby(log);
            lobby.connect();
        }
    }
}
