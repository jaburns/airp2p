package net.jaburns.airp2p
{
    import flash.events.Event;

    internal class OfflineGameRunner implements IGameRunner
    {
        private var _modelClass :Class;

        private var _model :Object;
        private var _view :IGameView;
        private var _controller :IGameController;

        private var _log :Function;
        private var _timer :TickTimer;

        public function start(
            modelClass:Class,
            controller:IGameController,
            view:IGameView,
            tickRate:TickRate,
            log:Function=null
        ):void
        {
            _modelClass = modelClass;
            _view = view;

            _model = new _modelClass;
            _controller = controller;

            if (log !== null) {
                _log = function(msg:String) :void {
                    log("[OfflineGameRunner] "+msg);
                };
            } else {
                _log = function(msg:String) :void { };
            }

            _log("Starting single player session.");
            _view.notifyConnected(true);

            _timer = new TickTimer(tickRate);
            _timer.addEventListener(TickTimer.TICK, timer_tick);
            _timer.start();
        }

        private function timer_tick(e:Event) :void
        {
            _controller.update(_model, {"p1": Util.deepClone(_view.readInput())});
            _view.update(Util.deepClone(_model));
        }

        public function stop() :void
        {
            _log("Stopping single player session.");
            _view.notifyConnected(false);

            _timer.stop();
            _timer = null;
        }
    }
}
