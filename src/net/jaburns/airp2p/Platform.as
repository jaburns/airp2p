package net.jaburns.airp2p
{
    import flash.desktop.NativeApplication;
    import flash.desktop.SystemIdleMode;
    import flash.events.Event;
    import flash.system.Capabilities;

    internal class Platform
    {
        static private var s_originalIdleMode :String;

        static private function get isAndroid() :Boolean { return Capabilities.version.indexOf('AND') >= 0; }

        static public function start() :void
        {
            s_originalIdleMode = NativeApplication.nativeApplication.systemIdleMode;
            NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

            if (isAndroid) {
                NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, android_deactivate);
            }
        }

        static public function stop() :void
        {
            NativeApplication.nativeApplication.systemIdleMode = s_originalIdleMode;

            if (isAndroid) {
                NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, android_deactivate);
            }
        }

        static private function android_deactivate() :void
        {
            NetGame.stop();
            NativeApplication.nativeApplication.exit(0);
        }
    }
}
