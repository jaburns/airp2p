package net.jaburns.airp2p
{
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

            _loopTimer = new Timer(_tickLength);
            _loopTimer.addEventListener(TimerEvent.TIMER, loopTimer_tick);
            _loopTimer.start();

            _log("Starting single player session.");
            _client.notifyConnected(true);
        }

        private function loopTimer_tick(e:TimerEvent) :void
        {
            _gameState.update({"p1": Util.deepClone(_client.readInput())});
            _client.notifyGameState(Util.deepClone(_gameState));
        }

        public function stop() :void
        {
            _log("Stopping single player session.");
            _client.notifyConnected(false);
            _loopTimer.stop();
        }
    }
}
