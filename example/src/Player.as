package
{
    public class Player
    {
        public var x :Number;
        public var y :Number;
        public var timeOffset :Number;
        public var squished :Boolean;

        public function Player()
        {
            x = 100 + 500*Math.random();
            y = 300 + 300*Math.random();
            timeOffset = 100*Math.random();
        }

        public function update(time:Number, input:InputState) :void
        {
            x += 2*Math.sin(timeOffset + time / 20);
            y += 2*Math.cos(timeOffset + time / 20);
            squished = input.tapping;
        }
    }
}
