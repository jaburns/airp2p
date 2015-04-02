package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import net.jaburns.airp2p.IClient;

    public class Client implements IClient
    {
        private var _input :InputState = new InputState;
        private var _root :Sprite;

        public function Client(root:Sprite)
        {
            _root = root;
            _root.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
            _root.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
            _root.addEventListener(Event.ENTER_FRAME, enterFrame);
        }

        private function stage_mouseDown(e:MouseEvent) :void
        {
            _input.tapping = true;
        }

        private function stage_mouseUp(e:MouseEvent) :void
        {
            _input.tapping = false;
        }

        private function enterFrame(e:Event) :void
        {
            // TODO interpolate game state and render
        }

    // IClient implementation

        public function readInput():Object { return _input; }

        public function notifyGameState(stateObj:Object):void
        {
            var state:GameState = stateObj as GameState;

            _root.graphics.clear();

            for each (var player:Player in state.players) {
                _root.graphics.beginFill(0, 1);
                _root.graphics.drawCircle(player.x, player.y, player.squished ? 5 : 20);
                _root.graphics.endFill();
            }
        }
    }
}
