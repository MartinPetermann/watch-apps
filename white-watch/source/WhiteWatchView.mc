import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time.Gregorian;

import Complicated;

import Misc;

class SimpleAnalogView extends WatchUi.WatchFace {
	private const mySettings = System.getDeviceSettings();
    private const screen_width = mySettings.screenWidth;

    private const hour_hand_length = Misc.AdaptSize(Application.Properties.getValue("hour_hand_length"));
    private const min_hand_length = Misc.AdaptSize(Application.Properties.getValue("min_hand_length"));
    private const sec_hand_length = Misc.AdaptSize(Application.Properties.getValue("sec_hand_length"));
    private const hour_hand_stroke = Misc.AdaptSize(Application.Properties.getValue("hour_hand_stroke"));
    private const min_hand_stroke = Misc.AdaptSize(Application.Properties.getValue("min_hand_stroke"));
    private const sec_hand_stroke = Misc.AdaptSize(Application.Properties.getValue("sec_hand_stroke"));
    private const hour_hand_width_1 = Misc.AdaptSize(Application.Properties.getValue("hour_hand_width_1"));
    private const hour_hand_width_2 = Misc.AdaptSize(Application.Properties.getValue("hour_hand_width_2"));
    private const min_hand_width_1 = Misc.AdaptSize(Application.Properties.getValue("min_hand_width_1"));
    private const min_hand_width_2 = Misc.AdaptSize(Application.Properties.getValue("min_hand_width_2"));
    private const sec_hand_width = Misc.AdaptSize(Application.Properties.getValue("sec_hand_width"));
	private const sec_hand_diam = Misc.AdaptSize(Application.Properties.getValue("sec_hand_diam"));

    private const backgroundColor = Application.Properties.getValue("BackgroundColor");
	private const second_hand_color = Application.Properties.getValue("SecondHandColor");
	private const hour_min_hand_color = Application.Properties.getValue("HourMinHandColor");
	private const text_color_f = Application.Properties.getValue("TextColorF");
	private const text_color_b = Application.Properties.getValue("TextColorB");

    private var lowPower = false;
	private var _complications as Array<ComplicationDrawable>;

    function initialize() {
        WatchFace.initialize();
		_complications = new Array<ComplicationDrawable>[4];
    }

    // Load your resources here
    function onLayout(dc) {
		dc.setAntiAlias(true);

			//increase the size of resources so they are visible on the Venu
		updateValues();

		setLayout(Rez.Layouts.WatchFace(dc));

		_complications[0] = View.findDrawableById("Complication1") as ComplicationDrawable;
        var prop = Application.Properties.getValue("Complication1");
        _complications[0].setModelUpdater(Complicated.getComplication(prop));

        _complications[1] = View.findDrawableById("Complication2") as ComplicationDrawable;    
        prop = Application.Properties.getValue("Complication2");
        _complications[1].setModelUpdater(Complicated.getComplication(prop));
    }

    // Update the view
    function onUpdate(dc) {
		dc.setAntiAlias(true);

		View.onUpdate(dc);	

		updateValues();

		drawBackground(dc);			
    }
    
	//use this to update values controlled by settings
	function updateValues() {
	}

	function drawBackground(dc) {
		var clockTime = System.getClockTime();
		// screen width == screen height
    	drawDate(dc, screen_width/2, screen_width/8);
		drawElev(dc, screen_width/2, screen_width - screen_width/4);
		drawHands(dc, clockTime.hour, clockTime.min, clockTime.sec);
	}

	function getRGB(color) {
		var color1 = color.format("%X");
		var r = 0;
		var g = 0;
		var b = 0;

		if(color1.length() <= 2 && color1.length() > 0) {
			r = 0;
			g = 0;
			b = color1.toLongWithBase(16);
		} else if(color1.length() == 3) {
			r = 0;
			g = color1.substring(0, 1).toLongWithBase(16);
			b = color1.substring(1, 3).toLongWithBase(16);
		} else if(color1.length() == 4){
			r = 0;
			g = color1.substring(0, 2).toLongWithBase(16);
			b = color1.substring(2, 4).toLongWithBase(16);
		} else if(color1.length() == 5) {
			r = color1.substring(0, 1).toLongWithBase(16);
			g = color1.substring(1, 3).toLongWithBase(16);
			b = color1.substring(3, 5).toLongWithBase(16);
		} else if(color1.length() == 6) {
			r = color1.substring(0, 2).toLongWithBase(16);
			g = color1.substring(2, 4).toLongWithBase(16);
			b = color1.substring(4, 6).toLongWithBase(16);
		}

		return [r, g, b];
	}
   
    //! Draw the watch hand
    //! @param dc Device Context to Draw
    //! @param angle Angle to draw the watch hand
    //! @param length Length of the watch hand
    //! @param width Width of the watch hand
    function drawHand(dc, angle, length, width_1, width_2, overheadLine, drawCircleOnTop)
    {
        // Map out the coordinates of the watch hand
        var coords = [ 
            [-(width_1/2), 0 + overheadLine],
            [-(width_2/2), -length],
            [width_2/2, -length],
            [width_1/2, 0 + overheadLine]
        ];
        var result = new [4];
        var centerX = screen_width / 2;
        var centerY = screen_width / 2;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);



        // Transform the coordinates
        for (var i = 0; i < 4; i += 1)
        {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [ centerX + x, centerY + y];
        }

        // Draw the polygon
        dc.fillPolygon(result);

		if ( drawCircleOnTop ) {
			var xCircle = ((coords[1][0]+(width_1/2)) * cos) - ((coords[1][1]) * sin);
			var yCircle = ((coords[1][0]+(width_1/2)) * sin) + ((coords[1][1]) * cos);
			// radius instead of diameter
			dc.fillCircle(centerX + xCircle, centerY + yCircle, sec_hand_diam/2);
		}
    }

    function drawHands(dc, clock_hour, clock_min, clock_sec)
    {
        var hour, min, sec;

        // Draw the hour. Convert it to minutes and
        // compute the angle.
        hour = ( ( ( clock_hour % 12 ) * 60 ) + clock_min );
        hour = hour / (12 * 60.0);
        hour = hour * Math.PI * 2;
        dc.setColor(hour_min_hand_color, backgroundColor);
        drawHand(dc, hour, hour_hand_length, hour_hand_width_1, hour_hand_width_2, hour_hand_stroke, false);

        // Draw the minute
        min = ( clock_min / 60.0) * Math.PI * 2;
        dc.setColor(hour_min_hand_color, backgroundColor);
        drawHand(dc, min, min_hand_length, min_hand_width_1, min_hand_width_2, min_hand_stroke, false);

        // Draw the seconds
        if(lowPower == false){
            sec = ( clock_sec / 60.0) *  Math.PI * 2;
            dc.setColor(second_hand_color, backgroundColor);
            drawHand(dc, sec, sec_hand_length, sec_hand_width, sec_hand_width, sec_hand_stroke, true);
        }
    }

	function drawDate(dc, x, y)
	{
		var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var dateString = Lang.format("$1$.$2$.$3$", [info.day.format("%02d"), info.month.format("%02d"), info.year % 100]);
		dc.setColor(text_color_b, backgroundColor);	
		dc.drawText(x+1, y+1, Graphics.FONT_TINY, dateString, Graphics.TEXT_JUSTIFY_CENTER);
		dc.setColor(text_color_f, backgroundColor);	
		dc.drawText(x, y, Graphics.FONT_TINY, dateString, Graphics.TEXT_JUSTIFY_CENTER);
    }

	function drawElev(dc, x, y)
	{
		var height = Toybox.Activity.getActivityInfo().altitude;
		dc.setColor(text_color_b, backgroundColor);	
		dc.drawText(x+1, y+1, Graphics.FONT_TINY, height.format("%d") + " m", Graphics.TEXT_JUSTIFY_CENTER);
		dc.setColor(text_color_f, backgroundColor);	
		dc.drawText(x, y, Graphics.FONT_TINY, height.format("%d") + " m", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
		lowPower = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
		lowPower = true;
    }

}
