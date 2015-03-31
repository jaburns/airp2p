package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.text.TextField;

    import net.jaburns.airp2p.NetGame;

    public class Main extends Sprite
    {
        private var _tf :TextField;

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

            NetGame.start(new Host, new Client, log);
        }

        private function log(msg:String) :void
        {
            _tf.appendText(msg);
            _tf.appendText("\n");
        }
    }
}

import net.jaburns.airp2p.IClient;
import net.jaburns.airp2p.IHost;

class Client implements IClient {

    public function readInputs():Object
    {
        return {};
    }

    public function renderState(state:Object):void
    {
    }
}

class Host implements IHost
{
    public function setState(state:Object):void
    {
    }

    public function getState():Object
    {
        return {};
    }

    public function step(inputs:Object):void
    {
    }
}
