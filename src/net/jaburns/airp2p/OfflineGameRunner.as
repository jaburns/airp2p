package net.jaburns.airp2p
{
    import flash.events.Event;

    internal class OfflineGameRunner implements IGameRunner
    {
        private var _gameStateClass :Class;
        private var _gameState :Object;

        private var _log :Function;
        private var _client :IClient;

        private var _timer :TickTimer;

        public function start(gameStateClass:Class, clientLogic:IClient, tickRate:TickRate, log:Function=null) :void
        {
            if (!Util.checkForUpdateMethod(gameStateClass)) {
                throw new Error ("Class supplied as gameStateClass must have a public method update(Object):void");
            }

            _gameStateClass = gameStateClass;
            _client = clientLogic;
            _gameState = new _gameStateClass;

            if (log !== null) {
                _log = function(msg:String) :void {
                    log("[OfflineGameRunner] "+msg);
                };
            } else {
                _log = function(msg:String) :void { };
            }

            _log("Starting single player session.");
            _client.notifyConnected(true);

            _timer = new TickTimer(tickRate);
            _timer.addEventListener(TickTimer.TICK, timer_tick);
            _timer.start();
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

            _timer.stop();
            _timer = null;
        }
    }
}
