import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

class Background extends WatchUi.Drawable {
    private var image1 as BitmapType;
    private var image2 as BitmapType;

    var width_screen;
	var height_screen;

    // like on https://codepen.io/jobe451/pen/rNWrqPw
	// see schweizer_bahnhofsuhr.jpg
	var relative_length = Application.getApp().getProperty("relative_length");

	private var hour_tick_length = 12*relative_length*(260/100);
	private var hour_tick_stroke = 3.5*relative_length*(260/100);
	private var min_tick_length = 3.5*relative_length*(260/100);
	private var min_tick_stroke = 1.4*relative_length*(260/100);
    private var rim = 1.5*relative_length*(260/100);

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);

        image1 = Application.loadResource( Rez.Drawables.background15 ) as BitmapResource;
        image2 = Application.loadResource( Rez.Drawables.rim ) as BitmapResource;
    }

    function drawTicks(dc, length, stroke, num) {
		var tickAngle = 360/num;
        var coords = [ 
            [-(stroke/2), width_screen / 2 - rim, ],
            [-(stroke/2), width_screen / 2 - length - rim],
            [stroke/2, width_screen / 2 - length - rim ],
            [stroke/2, width_screen / 2 - rim  ]
        ];
        var result = new [4];
        var centerX = width_screen / 2;
        var centerY = height_screen / 2;

		for(var i = 0; i < num; i++) {
			var angle = Math.toRadians(tickAngle * i);
        	var cos = Math.cos(angle);
        	var sin = Math.sin(angle);

			// Transform the coordinates
			for (var j = 0; j < 4; j += 1)
			{
				var x = (coords[j][0] * cos) - (coords[j][1] * sin);
				var y = (coords[j][0] * sin) + (coords[j][1] * cos);
				result[j] = [ centerX + x, centerY + y];
			}

			// Draw the polygon
			dc.fillPolygon(result);
		}
    }

    function draw(dc) {
        // Set the background color then call to clear the screen
        // dc.setColor(Graphics.COLOR_TRANSPARENT, Application.getApp().getProperty("BackgroundColor"));
        // dc.clear();

        width_screen = dc.getWidth();
		height_screen = dc.getHeight();

        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        dc.drawBitmap( 0, 0, image1 );
        //dc.drawBitmap( 0, 0, image2 );

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		drawTicks(dc, hour_tick_length, hour_tick_stroke, 12);
		drawTicks(dc, min_tick_length, min_tick_stroke, 60);
    }

}
