import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time.Gregorian;

import Complicated;

class SimpleAnalogView extends WatchUi.WatchFace {
    var lowPower = false;
    var is24;
	var isDistanceMetric;
	var showTicks;
	var mainFont;
	var iconFont;
	var RBD = 0;
	var showBoxes;
	var background_color_1;
	var foreground_color;
	var box_color;
	var second_hand_color;
	var hour_min_hand_color;
	var text_color;
	var show_min_ticks;
	
	var mySettings = System.getDeviceSettings();
    var screen_width = mySettings.screenWidth;

    // like on https://codepen.io/jobe451/pen/rNWrqPw
	// see schweizer_bahnhofsuhr.jpg

    var hour_hand_length = 32*(screen_width/100.0);
    var min_hand_length = 46*(screen_width/100.0);
    var sec_hand_length = 31.2*(screen_width/100.0);

    var hour_hand_stroke = 12*(screen_width/100.0);
    var min_hand_stroke = 12*(screen_width/100.0);
    var sec_hand_stroke = 16.5*(screen_width/100.0);

	
    var hour_hand_width_1 = 6.4*(screen_width/100.0);
    var hour_hand_width_2 = 5.2*(screen_width/100.0);

    var min_hand_width_1 = 5.2*(screen_width/100.0);
    var min_hand_width_2 = 3.6*(screen_width/100.0);

    var sec_hand_width = 1.4*(screen_width/100.0);

	// orig value is double in size
	var sec_hand_diam = 5.25*(screen_width/100.0);

	var rim = 1.5*(screen_width/100.0);

    var relative_center_radius = .025;

	var text_padding = [1, 2];
	var dow_size = [44, 19];
	var date_size = [24, 19];
	var time_size = [48, 19];
	var floors_size = [40, 19];
	var battery_size = [32, 19];
	var status_box_size = [94, 19];

	var image as BitmapType;
	var secBitmap as BitmapType;
	var secBitmapX;
	var secBitmapY;
	var _complications as Array<ComplicationDrawable>;

    function initialize() {
        WatchFace.initialize();
		image = Application.loadResource( Rez.Drawables.background4 ) as BitmapResource;
		secBitmap = Application.loadResource(Rez.Drawables.second);
		secBitmapX = secBitmap.getWidth();
		secBitmapY = secBitmap.getHeight();
		_complications = new Array<ComplicationDrawable>[4];
    }

    // Load your resources here
    function onLayout(dc) {
		dc.setAntiAlias(true);

			//increase the size of resources so they are visible on the Venu
		mainFont = WatchUi.loadResource(Rez.Fonts.BigFont);
		iconFont = WatchUi.loadResource(Rez.Fonts.BigIconFont);
		dow_size = [44 * 1.5, 19* 1.5];
		date_size = [24* 1.5, 19* 1.5];
		time_size = [48* 1.5, 19* 1.5];
		floors_size = [48* 1.5, 19* 1.5];
		battery_size = [32*1.5, 19*1.5];
		status_box_size = [94*1.5, 19*1.5];

		updateValues();

		setLayout(Rez.Layouts.WatchFace(dc));

		_complications[0] = View.findDrawableById("Complication1") as ComplicationDrawable;
        var prop = Application.Properties.getValue("Complication1");
        _complications[0].setModelUpdater(Complicated.getComplication(prop));

        _complications[1] = View.findDrawableById("Complication2") as ComplicationDrawable;    
        prop = Application.Properties.getValue("Complication2");
        _complications[1].setModelUpdater(Complicated.getComplication(prop));

        // _complications[2] = View.findDrawableById("Complication3") as ComplicationDrawable;    
        // prop = Application.Properties.getValue("Complication3");
        // _complications[2].setModelUpdater(Complicated.getComplication(prop));

        // _complications[3] = View.findDrawableById("Complication4") as ComplicationDrawable;    
        // prop = Application.Properties.getValue("Complication4");
        // _complications[3].setModelUpdater(Complicated.getComplication(prop));
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
		var UMF = Application.Properties.getValue("Use24HourFormat");
		if(UMF == 0) {
			is24 = true;
		}
		if(UMF == 1) {
			is24 = false;
		}
		if(UMF == 2) {
			is24 = System.getDeviceSettings().is24Hour;
		}

		var distanceMetric = System.getDeviceSettings().distanceUnits;
		if(distanceMetric == System.UNIT_METRIC) {
			isDistanceMetric = true;
		} else {
			isDistanceMetric = false;
		}

		showTicks = Application.Properties.getValue("ShowTicks");
		RBD = Application.Properties.getValue("RightBoxDisplay1");
		showBoxes = Application.Properties.getValue("ShowBoxes");
		
		background_color_1 = getColor(Application.Properties.getValue("BackgroundColor"));
		foreground_color = getColor(Application.Properties.getValue("ForegroundColor"));
		box_color = getColor(Application.Properties.getValue("BoxColor"));
		second_hand_color = getColor(Application.Properties.getValue("SecondHandColor"));
		hour_min_hand_color = getColor(Application.Properties.getValue("HourMinHandColor"));
		text_color = getColor(Application.Properties.getValue("TextColor"));
		show_min_ticks = Application.Properties.getValue("ShowMinTicks");

	}

	function drawBackground(dc) {
		var clockTime = System.getClockTime();
;
           	
		dc.setColor(foreground_color, Graphics.COLOR_TRANSPARENT);
		// screen width == screen height
    	drawDate(dc, screen_width/2, screen_width/8);
		drawElev(dc, screen_width/2, screen_width - screen_width/4);	  	
    	dc.setColor(hour_min_hand_color, Graphics.COLOR_TRANSPARENT);
		drawHands(dc, clockTime.hour, clockTime.min, clockTime.sec, Graphics.COLOR_BLACK, Graphics.COLOR_BLACK, Graphics.COLOR_DK_RED);
	}

	//takes a number from settings and converts it to the assosciated color
	function getColor(num) {
		if(num == 0) {
			return Graphics.COLOR_BLACK;
		}

		if(num == 1) {
			return Graphics.COLOR_WHITE;
		}

		if(num == 2) {
			return Graphics.COLOR_LT_GRAY;
		}

		if(num == 3) {
			return Graphics.COLOR_DK_GRAY;
		}

		if(num == 4) {
			return Graphics.COLOR_BLUE;
		}

		if(num == 5) {
			return 0x02084f;
		}

		if(num == 6) {
			return Graphics.COLOR_RED;
		}

		if(num == 7) {
			return 0x730000;
		}

		if(num == 8) {
			return Graphics.COLOR_GREEN;
		}

		if(num == 9) {
			return 0x004f15;
		}

		if(num == 10) {
			return 0xAA00FF;
		}

		if(num == 11) {
			return Graphics.COLOR_PINK;
		}

		if(num == 12) {
			return Graphics.COLOR_ORANGE;
		}

		if(num == 13) {
			return Graphics.COLOR_YELLOW;
		}

		return null;
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
			dc.fillCircle(centerX + xCircle, centerY + yCircle, sec_hand_diam);
		}
    }

    function drawHands(dc, clock_hour, clock_min, clock_sec, hour_color, min_color, sec_color)
    {
        var hour, min, sec;

        // Draw the hour. Convert it to minutes and
        // compute the angle.
        hour = ( ( ( clock_hour % 12 ) * 60 ) + clock_min );
        hour = hour / (12 * 60.0);
        hour = hour * Math.PI * 2;
        dc.setColor(hour_color, Graphics.COLOR_TRANSPARENT);
        drawHand(dc, hour, hour_hand_length, hour_hand_width_1, hour_hand_width_2, hour_hand_stroke, false);

        // Draw the minute
        min = ( clock_min / 60.0) * Math.PI * 2;
        dc.setColor(min_color, Graphics.COLOR_TRANSPARENT);
        drawHand(dc, min, min_hand_length, min_hand_width_1, min_hand_width_2, min_hand_stroke, false);

        // Draw the seconds
        if(lowPower == false){
            sec = ( clock_sec / 60.0) *  Math.PI * 2;
            dc.setColor(sec_color, Graphics.COLOR_TRANSPARENT);
            drawHand(dc, sec, sec_hand_length, sec_hand_width, sec_hand_width, sec_hand_stroke, true);
        }
    }

	function drawDate(dc, x, y) {
		
		var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var dateString = Lang.format("$1$.$2$.$3$", [info.day.format("%02d"), info.month.format("%02d"), info.year % 100]);
		dc.drawText(x, y, Graphics.FONT_TINY, dateString, Graphics.TEXT_JUSTIFY_CENTER);
    }

	function drawElev(dc, x, y) {
		
		var height = Toybox.Activity.getActivityInfo().altitude;
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
