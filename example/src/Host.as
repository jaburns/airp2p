package
{
    import net.jaburns.airp2p.IHost;

    public class Host implements IHost
    {
        private var _state :Object;

        public function Host()
        {
            _state = {
                players: {}
            };
        }

        public function getState():Object { return _state; }
        public function setState(state:Object):void { _state = state; }

        public function step(allInputs:Object):void
        {
            for (var k:String in allInputs) {
                if (_state.players[k] === undefined) {
                    _state.players[k] = newPlayer();
                }
            }

            for (k in _state.players) {
                _state.players[k].squished = allInputs[k].tapping;
            }
        }

        static private function newPlayer() :Object
        {
            return {
                xpos: 500 + 200*Math.random(),
                ypos: 100 + 600*Math.random(),
                squished: false
            };
        }
    }
}
