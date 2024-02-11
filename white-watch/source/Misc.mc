import Toybox.System;

module Misc {

    function AdaptSize(percentage)
    {
        var mySettings = System.getDeviceSettings();
        var screen_width = mySettings.screenWidth;

        return percentage*(screen_width/100.0);
    }
}