import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

import Misc;

class Background extends WatchUi.Drawable {
    private var image1 as BitmapType;

    private var mySettings = System.getDeviceSettings();
    private var screen_width = mySettings.screenWidth;

	private var hour_tick_length = Misc.AdaptSize(Application.Properties.getValue("hour_tick_length"));
	private var hour_tick_stroke = Misc.AdaptSize(Application.Properties.getValue("hour_tick_stroke"));
	private var min_tick_length = Misc.AdaptSize(Application.Properties.getValue("min_tick_length"));
	private var min_tick_stroke = Misc.AdaptSize(Application.Properties.getValue("min_tick_stroke"));
	private var rim = Misc.AdaptSize(Application.Properties.getValue("rim"));

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);

        image1 = Application.loadResource( Rez.Drawables.background15 ) as BitmapResource;
    }

    function drawTicks(dc, length, stroke, num) {
		var tickAngle = 360/num;
        var coords = [ 
            [-(stroke/2), screen_width / 2 - rim, ],
            [-(stroke/2), screen_width / 2 - length - rim],
            [stroke/2, screen_width / 2 - length - rim ],
            [stroke/2, screen_width / 2 - rim  ]
        ];
        var result = new [4];
        var centerX = screen_width / 2;
        var centerY = screen_width / 2;

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
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
        dc.drawBitmap( 0, 0, image1 );

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		drawTicks(dc, hour_tick_length, hour_tick_stroke, 12);
		drawTicks(dc, min_tick_length, min_tick_stroke, 60);
    }

}
