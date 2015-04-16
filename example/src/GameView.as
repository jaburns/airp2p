package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.getTimer;

    import model.GameState;
    import model.InputState;
    import model.PlayerState;

    import net.jaburns.airp2p.IGameView;
    import net.jaburns.airp2p.Interpolate;

    public class GameView implements IGameView
    {
        private var _input :InputState = new InputState;
        private var _root :Sprite;
        private var _connected :Boolean = false;

        private var _prevState :GameState;
        private var _thisState :GameState;
        private var _interState :GameState;
        private var _stateArriveTime :Number;


        public function GameView(root:Sprite)
        {
            _root = root;
            _root.addEventListener(Event.ENTER_FRAME, enterFrame);
        }

        // IGameView
        public function readInput():Object { return _input; }

        // IGameView
        public function notifyConnected(connected:Boolean) :void
        {
            if (connected) {
                _root.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
                _root.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
            } else {
                _root.stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
                _root.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
            }
            _connected = connected;
        }

        // IGameView
        public function update(stateObj:Object):void
        {
            _prevState = _thisState;
            _thisState = stateObj as GameState;
            _stateArriveTime = getTimer();
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
            _root.graphics.clear();

            if (!_connected) {
                if (_interState !== null) {
                    renderState(_interState);
                }

                renderSpinner();
                return;
            }

            if (_prevState === null || _thisState === null) return;

            var t:Number = (Number(getTimer()) - _stateArriveTime) / Main.TICK_LENGTH;

            _interState = Interpolate.typedObject(
                t, _prevState, _thisState, GameState.interpolationPaths
            ) as GameState;

            renderState(_interState);
        }

        private function renderSpinner() :void
        {
            const RADIUS :Number = 20;
            var theta :Number = getTimer() / 500;

            _root.graphics.lineStyle(10, 0);
            _root.graphics.moveTo(
                _root.stage.stageWidth  / 2 + RADIUS*Math.cos(theta),
                _root.stage.stageHeight / 2 + RADIUS*Math.sin(theta)
            );
            _root.graphics.lineTo(
                _root.stage.stageWidth  / 2 - RADIUS*Math.cos(theta),
                _root.stage.stageHeight / 2 - RADIUS*Math.sin(theta)
            );
        }

        private function renderState(state:GameState) :void
        {
            for each (var player:PlayerState in state.players) {
                _root.graphics.beginFill(0, 1);
                _root.graphics.drawCircle(player.x, player.y, player.squished ? 5 : 20);
                _root.graphics.endFill();
            }
        }
    }
}
