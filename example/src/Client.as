package
{
    import flash.display.Sprite;

    import net.jaburns.airp2p.IClient;

    public class Client implements IClient
    {
        private var _root :Sprite;

        public function Client(root:Sprite)
        {
            _root = root;
        }

        public function readInputs():Object
        {
            return null;
        }

        public function setState(state:Object):void
        {
        }
    }
}
