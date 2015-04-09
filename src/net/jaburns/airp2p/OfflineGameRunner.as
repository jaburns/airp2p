package net.jaburns.airp2p
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    internal class OfflineGameRunner implements IGameRunner
    {
        private var _gameStateClass :Class;
        private var _gameState :Object;

        private var _tickLength :Number;
        private var _log :Function;
        private var _client :IClient;

        private var _loopTimer :Timer;
        private var _frameTimer :Sprite;

        public function start(gameStateClass:Class, clientLogic:IClient, tickLength:Number, log:Function=null):void
        {
            if (!Util.checkForUpdateMethod(gameStateClass)) {
                throw new Error ("Class supplied as gameStateClass must have a public method update(Object):void");
            }

            _gameStateClass = gameStateClass;
            _client = clientLogic;
            _tickLength = tickLength;
            _gameState = new _gameStateClass;

            if (log !== null) {
                _log = function(msg:String) :void {
                    log("[OfflineGameRunner] "+msg);
                };
            } else {
                _log = function(msg:String) :void { };
            }

            if (isNaN(_tickLength)) {
                log("Using ENTER_FRAME timer");
                _frameTimer = new Sprite;
                _frameTimer.addEventListener(Event.ENTER_FRAME, timer_tick);
            }
            else {
                log("Using flash.utils.Timer");
                _loopTimer = new Timer(_tickLength);
                _loopTimer.addEventListener(TimerEvent.TIMER, timer_tick);
                _loopTimer.start();
            }

            _log("Starting single player session.");
            _client.notifyConnected(true);
        }

        private function timer_tick(e:Event) :void
        {
            _gameState.update({"p1": Util.deepClone(_client.readInput())});
            _client.notifyGameState(Util.deepClone(_gameState));
        }

        public function stop() :void
        {
            _log("Stopping single player session.");
            _client.notifyConnected(false);

            if (_loopTimer) {
                _loopTimer.stop();
                _loopTimer.removeEventListener(TimerEvent.TIMER, timer_tick);
                _loopTimer = null;
            }
            else if (_frameTimer) {
                _frameTimer.removeEventListener(TimerEvent.TIMER, timer_tick);
                _frameTimer = null;
            }
        }
    }
}
