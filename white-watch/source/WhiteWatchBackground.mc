import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

class Background extends WatchUi.Drawable {
    private var image1 as BitmapType;
    private var image2 as BitmapType;

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);

        image1 = Application.loadResource( Rez.Drawables.background15 ) as BitmapResource;
        image2 = Application.loadResource( Rez.Drawables.rim ) as BitmapResource;
    }

    function draw(dc) {
        // Set the background color then call to clear the screen
        // dc.setColor(Graphics.COLOR_TRANSPARENT, Application.getApp().getProperty("BackgroundColor"));
        // dc.clear();

        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        dc.drawBitmap( 0, 0, image1 );
        //dc.drawBitmap( 0, 0, image2 );
    }

}
