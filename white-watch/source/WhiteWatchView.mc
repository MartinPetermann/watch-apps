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
	
	

    //similar values like on https://codepen.io/jobe451/pen/rNWrqPw
	// 0.75 chosen by trying out
	var relative_length = 0.75;

    var hour_hand_length = 32/relative_length*(260/100);
    var min_hand_length = 46/relative_length*(260/100);
    var sec_hand_length = 31.2/relative_length*(260/100);

    var hour_hand_stroke = 12/relative_length*(260/100);
    var min_hand_stroke = 12/relative_length*(260/100);
    var sec_hand_stroke = 16.5/relative_length*(260/100);

	
    var hour_hand_width = 5.8/relative_length*(260/100);
    var min_hand_width = 4.4/relative_length*(260/100);
    var sec_hand_width = 1.4/relative_length*(260/100);

	// orig value is double in size
	var sec_hand_diam = 5.25/relative_length*(260/100);


    var relative_center_radius = .025;

	var text_padding = [1, 2];
	var dow_size = [44, 19];
	var date_size = [24, 19];
	var time_size = [48, 19];
	var floors_size = [40, 19];
	var battery_size = [32, 19];
	var status_box_size = [94, 19];

	var image as BitmapType;
	var _complications as Array<ComplicationDrawable>;

	var width_screen;
	var height_screen;

    function initialize() {
        WatchFace.initialize();
		image = Application.loadResource( Rez.Drawables.background4 ) as BitmapResource;
		_complications = new Array<ComplicationDrawable>[4];
    }

    // Load your resources here
    function onLayout(dc) {
		dc.setAntiAlias(true);

		width_screen = dc.getWidth();
		height_screen = dc.getHeight();

			//increase the size of resources so they are visible on the Venu
		mainFont = WatchUi.loadResource(Rez.Fonts.BigFont);
		iconFont = WatchUi.loadResource(Rez.Fonts.BigIconFont);
		dow_size = [44 * 1.5, 19* 1.5];
		date_size = [24* 1.5, 19* 1.5];
		time_size = [48* 1.5, 19* 1.5];
		floors_size = [48* 1.5, 19* 1.5];
		battery_size = [32*1.5, 19*1.5];
		status_box_size = [94*1.5, 19*1.5];

		updateValues(dc.getWidth());

		setLayout(Rez.Layouts.WatchFace(dc));

		_complications[0] = View.findDrawableById("Complication1") as ComplicationDrawable;
        var prop = Application.getApp().getProperty("Complication1");
        _complications[0].setModelUpdater(Complicated.getComplication(prop));

        _complications[1] = View.findDrawableById("Complication2") as ComplicationDrawable;    
        prop = Application.getApp().getProperty("Complication2");
        _complications[1].setModelUpdater(Complicated.getComplication(prop));

        // _complications[2] = View.findDrawableById("Complication3") as ComplicationDrawable;    
        // prop = Application.getApp().getProperty("Complication3");
        // _complications[2].setModelUpdater(Complicated.getComplication(prop));

        _complications[3] = View.findDrawableById("Complication4") as ComplicationDrawable;    
        prop = Application.getApp().getProperty("Complication4");
        _complications[3].setModelUpdater(Complicated.getComplication(prop));
    }

    // Update the view
    function onUpdate(dc) {
		dc.setAntiAlias(true);

		View.onUpdate(dc);	
		var width = dc.getWidth();

		updateValues(dc.getWidth());

		drawBackground(dc);			

		// dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
		// dc.fillCircle(dc.getWidth()/2-1, dc.getHeight()/2-1, relative_center_radius*width);
    }
    
	//use this to update values controlled by settings
	function updateValues(width) {
		var UMF = Application.getApp().getProperty("Use24HourFormat");
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

		showTicks = Application.getApp().getProperty("ShowTicks");
		RBD = Application.getApp().getProperty("RightBoxDisplay1");
		showBoxes = Application.getApp().getProperty("ShowBoxes");
		
		background_color_1 = getColor(Application.getApp().getProperty("BackgroundColor"));
		foreground_color = getColor(Application.getApp().getProperty("ForegroundColor"));
		box_color = getColor(Application.getApp().getProperty("BoxColor"));
		second_hand_color = getColor(Application.getApp().getProperty("SecondHandColor"));
		hour_min_hand_color = getColor(Application.getApp().getProperty("HourMinHandColor"));
		text_color = getColor(Application.getApp().getProperty("TextColor"));
		show_min_ticks = Application.getApp().getProperty("ShowMinTicks");

	}

	function drawBackground(dc) {
		var clockTime = System.getClockTime();
        var width = dc.getWidth();
        var height = dc.getHeight();
           	

		dc.setColor(foreground_color, Graphics.COLOR_TRANSPARENT);
    	drawDate(dc, height/2, width/8);	  	
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
    function drawHand(dc, angle, length, width, overheadLine, drawCircleOnTop)
    {
        // Map out the coordinates of the watch hand
        var coords = [ 
            [-(width/2), 0 + overheadLine],
            [-(width/2), -length],
            [width/2, -length],
            [width/2, 0 + overheadLine]
        ];
        var result = new [4];
        var centerX = width_screen / 2;
        var centerY = height_screen / 2;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);



        // Transform the coordinates
        for (var i = 0; i < 4; i += 1)
        {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [ centerX + x, centerY + y];
            if(drawCircleOnTop)
            {
                if(i == 1)
                {
                    var xCircle = ((coords[i][0]+(width/2)) * cos) - ((coords[i][1]) * sin);
                    var yCircle = ((coords[i][0]+(width/2)) * sin) + ((coords[i][1]) * cos);
                    dc.fillCircle(centerX + xCircle, centerY + yCircle, sec_hand_diam);
                }
            }
        }

        // Draw the polygon
        dc.fillPolygon(result);
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
        drawHand(dc, hour, hour_hand_length, hour_hand_width, hour_hand_stroke, false);

        // Draw the minute
        min = ( clock_min / 60.0) * Math.PI * 2;
        dc.setColor(min_color, Graphics.COLOR_TRANSPARENT);
        drawHand(dc, min, min_hand_length, min_hand_width, min_hand_stroke, false);

        // Draw the seconds
        if(lowPower == false){
            sec = ( clock_sec / 60.0) *  Math.PI * 2;
            dc.setColor(sec_color, Graphics.COLOR_TRANSPARENT);
            drawHand(dc, sec, sec_hand_length, sec_hand_width, sec_hand_stroke, true);
        }
    }

	function drawDate(dc, x, y) {
		
		var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var dateString = Lang.format("$1$.$2$.$3$", [info.day.format("%02d"), info.month.format("%02d"), info.year % 100]);
		// var dateString = Lang.format("$1$.$2$", [dc.getWidth(), dc.getHeight()]);
		drawTextBox(dc, dateString, x, y, dow_size[0], dow_size[1]);
    }
    
	function drawTextBox(dc, text, x, y, width, height) {
		var boxText = new WatchUi.Text({
            :text=>text,
            :color=>text_color,
            :font=>Graphics.FONT_TINY,
            :locX =>x + text_padding[0],
            :locY=>y,
			:justification=>Graphics.TEXT_JUSTIFY_CENTER
        });

		boxText.draw(dc);
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
