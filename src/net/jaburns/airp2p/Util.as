package net.jaburns.airp2p
{
    import flash.utils.ByteArray;

    internal class Util
    {
        static public function deepClone(obj:Object) :Object
        {
            var ba:ByteArray = new ByteArray;
            ba.writeObject(obj);
            ba.position = 0;
            return ba.readObject();
        }
    }
}
