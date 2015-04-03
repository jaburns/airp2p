package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.text.TextField;

    import net.jaburns.airp2p.NetGame;

    [SWF(frameRate="60", backgroundColor="#FFFFFF")]
    public class Main extends Sprite
    {
        static public const TICK_LENGTH :Number = 40;//ms (25 ticks per second)

        private var _tf :TextField = new TextField;

        public function Main()
        {
            super();

            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            _tf.width = stage.stageWidth;
            _tf.height = 9000;
            addChild(_tf);

            log("Start");

            NetGame.registerTypes(
                InputState,
                GameState,
                Player
            );
            NetGame.start(GameState, new Client(this), TICK_LENGTH, log);
        }

        private function log(msg:String) :void
        {
            trace(msg);
            _tf.appendText(msg);
            _tf.appendText("\n");
        }
    }
}
