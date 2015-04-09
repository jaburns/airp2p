package net.jaburns.airp2p
{
    import flash.display.Stage;

    public class TickRate
    {
        static private var s_canInstantiate :Boolean = false;

        private var _interval :Number;
        private var _boundToEnterFrame :Boolean;

        public function get interval() :Number { return _interval; }
        public function get boundToEnterFrame() :Boolean { return _boundToEnterFrame; }

        public function TickRate()
        {
            if (!s_canInstantiate) {
                throw new Error ("Cannot instantiate TickRate with new. Use static factory methods instead.");
            }
        }

        static public function onEnterFrame(stage:Stage) :TickRate
        {
            s_canInstantiate = true;
            var ret :TickRate = new TickRate;
            s_canInstantiate = false;

            ret._interval = 1000 / stage.frameRate;
            ret._boundToEnterFrame = true;

            return ret;
        }

        static public function timer(interval:Number) :TickRate
        {
            s_canInstantiate = true;
            var ret :TickRate = new TickRate;
            s_canInstantiate = false;

            ret._interval = interval;
            ret._boundToEnterFrame = false;

            return ret;
        }
    }
}
