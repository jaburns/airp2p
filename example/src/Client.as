package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.getTimer;

    import net.jaburns.airp2p.IClient;
    import net.jaburns.airp2p.Interpolate;

    public class Client implements IClient
    {
        private var _input :InputState = new InputState;
        private var _root :Sprite;

        private var _prevState :GameState;
        private var _thisState :GameState;
        private var _stateArriveTime :Number;

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
            if (_prevState === null || _thisState === null) return;

            var t:Number = (Number(getTimer()) - _stateArriveTime) / Main.TICK_LENGTH;

            var interState:GameState = Interpolate.preserveType(
                t, _prevState, _thisState, GameState.interpolationPaths
            ) as GameState;

            renderState(interState);
        }

        private function renderState(state:GameState) :void
        {
            _root.graphics.clear();

            for each (var player:Player in state.players) {
                _root.graphics.beginFill(0, 1);
                _root.graphics.drawCircle(player.x, player.y, player.squished ? 5 : 20);
                _root.graphics.endFill();
            }
        }

    // IClient implementation

        public function readInput():Object { return _input; }

        public function notifyGameState(stateObj:Object):void
        {
            _prevState = _thisState;
            _thisState = stateObj as GameState;
            _stateArriveTime = getTimer();
        }
    }
}
