package net.jaburns.airp2p
{
    import flash.utils.ByteArray;
    import flash.utils.describeType;

    internal class Util
    {
        static public function deepClone(obj:Object) :Object
        {
            var ba:ByteArray = new ByteArray;
            ba.writeObject(obj);
            ba.position = 0;
            return ba.readObject();
        }

        static public function checkForUpdateMethod(klass:Class) :Boolean
        {
            var info:XML = describeType(klass);
            for each (var method:XML in info.factory.method) {
                if (method.@name == "update") {
                    if (method.@returnType != "void") return false;
                    for each (var child:XML in method.children()) {
                        if (child.name() == "parameter") {
                            if (child.@index != "1") return false;
                            if (child.@type != "Object") return false;
                        }
                    }
                    return true;
                }
            }
            return false;
        }
    }
}
