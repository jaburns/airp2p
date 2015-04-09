package net.jaburns.airp2p
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    public class TickTimer extends EventDispatcher
    {
        static public const TICK :String = "tick";

        private var _timer :Timer = null;
        private var _sprite :Sprite = null;
        private var _running :Boolean = false;

        public function get running() :Boolean { return _running; }

        public function TickTimer(interval:Number)
        {
            if (isNaN(interval)) {
                _sprite = new Sprite;
            } else {
                _timer = new Timer(interval);
            }
        }

        public function start() :void
        {
            if (_running) return;
            _running = true;

            if (_sprite) {
                _sprite.addEventListener(Event.ENTER_FRAME, timer_tick);
            } else {
                _timer.addEventListener(TimerEvent.TIMER, timer_tick);
                _timer.start();
            }
        }

        public function stop() :void
        {
            if (!_running) return;
            _running = false;

            if (_sprite) {
                _sprite.removeEventListener(Event.ENTER_FRAME, timer_tick);
            } else {
                _timer.removeEventListener(TimerEvent.TIMER, timer_tick);
                _timer.stop();
            }
        }

        private function timer_tick(e:Event) :void
        {
            dispatchEvent(new Event(TICK));
        }
    }
}
