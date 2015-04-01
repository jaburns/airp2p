package
{
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import net.jaburns.airp2p.IClient;

    public class Client implements IClient
    {
        private var _inputs :Object;
        private var _root :Sprite;

        public function Client(root:Sprite)
        {
            _inputs = {
                tapping: false
            };

            _root = root;
            _root.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
            _root.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
        }

        public function readInputs():Object { return _inputs; }

        private function stage_mouseDown(e:MouseEvent) :void
        {
            _inputs.tapping = true;
        }

        private function stage_mouseUp(e:MouseEvent) :void
        {
            _inputs.tapping = false;
        }

        public function setState(state:Object):void
        {
            _root.graphics.clear();

            for each (var player:Object in state.players) {
                _root.graphics.beginFill(0, 1);
                _root.graphics.drawCircle(player.xpos, player.ypos, player.squished ? 5 : 20);
                _root.graphics.endFill();
            }
        }
    }
}
