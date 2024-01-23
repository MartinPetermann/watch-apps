//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

//! Drawable to update the background
class Background extends WatchUi.Drawable {
    // private var image as BitmapType;

    //! Constructor
    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);

        // image = Application.loadResource( Rez.Drawables.background ) as BitmapResource;
    }

    //! Draws the background
    function draw(dc as Dc) as Void {
        // Set the background color then call to clear the screen
        dc.setColor(Graphics.COLOR_TRANSPARENT, Application.getApp().getProperty("BackgroundColor"));
       

        //dc.drawBitmap( 0, 0, image );
        dc.clear();
    }

}
