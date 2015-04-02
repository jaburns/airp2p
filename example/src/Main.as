package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.text.TextField;

    import net.jaburns.airp2p.NetGame;

    public class Main extends Sprite
    {
        private var _tf :TextField = new TextField;

        public function Main()
        {
            super();

            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            _tf.y = 100;
            _tf.width = stage.stageWidth;
            _tf.height = 9000;
            addChild(_tf);

            NetGame.registerTypes(
                InputState,
                GameState,
                Player
            );

            NetGame.start(GameState, new Client(this), log);
        }

        private function log(msg:String) :void
        {
            _tf.appendText(msg);
            _tf.appendText("\n");
        }
    }
}
