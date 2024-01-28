import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

class Background extends WatchUi.Drawable {
    private var image as BitmapType;

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);

        image = Application.loadResource( Rez.Drawables.background6 ) as BitmapResource;
    }

    function draw(dc) {
        // Set the background color then call to clear the screen
        // dc.setColor(Graphics.COLOR_TRANSPARENT, Application.getApp().getProperty("BackgroundColor"));
        // dc.clear();

        dc.drawBitmap( 0, 0, image );
    }

}
