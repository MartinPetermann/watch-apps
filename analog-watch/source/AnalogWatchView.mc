import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time.Gregorian;

import Complicated;

class SimpleAnalogView extends WatchUi.WatchFace {
    var lowPower = false;
	var offScreenBuffer;
    var is24;
	var isDistanceMetric;
    var clip;
	var partialUpdates = false;
	var showTicks;
	var mainFont;
	var iconFont;
	var needsProtection = true;
	var lowMemDevice = true;
	var RBD = 0;
	var version;
	var showBoxes;
	var background_color_1;
	var background_color_2;
	var background_image;
	var use_background_image;
	var foreground_color;
	var box_color;
	var second_hand_color;
	var hour_min_hand_color;
	var text_color;
	var show_min_ticks;
	var ssloc = [100, 100];
	var xmult = 1.2;
	var ymult = 1.1;
	
    //relative to width percentage
	var relative_tick_stroke = .01;
    var relative_hour_tick_length = .08;
    var relative_min_tick_length = .04;
    var relative_hour_tick_stroke = .04;
    var relative_min_tick_stroke = .04;
    
    var relative_hour_hand_length = .20;
    var relative_min_hand_length = .40;
    var relative_sec_hand_length = .42;
    var relative_hour_hand_stroke = .026;
    var relative_min_hand_stroke = .026;
    var relative_sec_hand_stroke = .015;

	var relative_padding = .03;
    var relative_padding2 = .01;
    
    var relative_center_radius = .025;

	var text_padding = [1, 2];
	var box_padding = 2;
	var dow_size = [44, 19];
	var date_size = [24, 19];
	var time_size = [48, 19];
	var floors_size = [40, 19];
	var battery_size = [32, 19];
	var status_box_size = [94, 19];

	var image as BitmapType;
	var _complications as Array<ComplicationDrawable>;

    function initialize() {
        WatchFace.initialize();
		image = Application.loadResource( Rez.Drawables.background4 ) as BitmapResource;
		_complications = new Array<ComplicationDrawable>[4];
    }

    // Load your resources here
    function onLayout(dc) {

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
		View.onUpdate(dc);	

		var clockTime = System.getClockTime();
		var hours = clockTime.hour;
		var minutes = clockTime.min;
		var seconds = clockTime.sec;
		var width = dc.getWidth();

		updateValues(dc.getWidth());

		drawBackground(dc);			

		if(partialUpdates && ((!lowMemDevice && !lowPower) || (!lowMemDevice && lowPower))) {
			dc.setColor(second_hand_color, Graphics.COLOR_TRANSPARENT);
			drawSecondHandClip(dc, 60, seconds, relative_sec_hand_length*width, relative_sec_hand_stroke*width);
		} else if(lowMemDevice && !lowPower) {
			dc.setColor(second_hand_color, Graphics.COLOR_TRANSPARENT);
			drawHand(dc, 60, seconds, relative_sec_hand_length*width, relative_sec_hand_stroke*width);
		}

		dc.setColor(box_color, Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(dc.getWidth()/2-1, dc.getHeight()/2-1, relative_center_radius*width);
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
		
		if(!showTicks) {
			relative_sec_hand_length = .46;
			relative_hour_hand_length = .23;
			relative_min_hand_length = .46;
		} else {
			relative_hour_hand_length = .20;
   			relative_min_hand_length = .40;
			relative_sec_hand_length = .42;
		}
		var total_colors = 14;

		background_color_1 = getColor(Application.getApp().getProperty("BackgroundColor"));
		background_color_2 = getColor(Application.getApp().getProperty("BackgroundColor1"));
		foreground_color = getColor(Application.getApp().getProperty("ForegroundColor"));
		box_color = getColor(Application.getApp().getProperty("BoxColor"));
		second_hand_color = getColor(Application.getApp().getProperty("SecondHandColor"));
		hour_min_hand_color = getColor(Application.getApp().getProperty("HourMinHandColor"));
		text_color = getColor(Application.getApp().getProperty("TextColor"));
		show_min_ticks = Application.getApp().getProperty("ShowMinTicks");
	}

	function drawBackground(dc) {
		var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        var seconds = clockTime.sec;
        var width = dc.getWidth();
        var height = dc.getHeight();
           	

		dc.setColor(foreground_color, Graphics.COLOR_TRANSPARENT);
		// if(show_min_ticks) {
		// 	drawTicks(dc, relative_hour_tick_length*width, relative_hour_tick_stroke*width, 12);
		// 	drawTicks(dc, relative_min_tick_length*width, relative_min_tick_stroke*width, 60);
		// } else {
		// 	drawTicks(dc, relative_min_tick_length*width, relative_min_tick_stroke*width, 12);
		// }


    	drawDate(dc, height/2, width/10);	
    	
    	dc.setColor(hour_min_hand_color, Graphics.COLOR_TRANSPARENT);
    	drawHandOffset(dc, 12.00, 60.00, hours, minutes, relative_hour_hand_length*width, relative_hour_hand_stroke*width);

    	drawHand(dc, 60, minutes, relative_min_hand_length*width, relative_min_hand_stroke*width);
	}

	//These functions center an object between the end of the hour tick and the edge of the center circle
	function centerOnLeft(dc, size) {
		var width = dc.getWidth();
		if(showTicks) {
			return relative_hour_tick_length * width + ((((relative_hour_tick_length * width) - (width/2 - (relative_center_radius * width)))/2).abs() - size/2);
		}
		return ((((width/2 - (relative_center_radius * width)))/2).abs() - size/2);		
	}

	function centerOnRight(dc, size) {
		var width = dc.getWidth();
		if(showTicks) {
			return width - relative_hour_tick_length * width - ((((width - relative_hour_tick_length * width) - (width/2 + (relative_center_radius * width)))/2).abs() + size/2);
		}
		return width - ((((width) - (width/2 + (relative_center_radius * width)))/2).abs() + size/2);
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
   
    function drawTicks(dc, length, stroke, num) {
		dc.setPenWidth(dc.getWidth() * relative_tick_stroke);
    	var tickAngle = 360/num;
    	var center = dc.getWidth()/2;
    	for(var i = 0; i < num; i++) {
    		var angle = Math.toRadians(tickAngle * i);
    		var x1 = center + Math.round(Math.cos(angle) * (center-length));
    		var y1 = center + Math.round(Math.sin(angle) * (center-length));
    		//2x^2 = 20
    		//x=10^0.5
    		var x2 = center + Math.round(Math.cos(angle) * (center));
    		var y2 = center + Math.round(Math.sin(angle) * (center));
    		
    		dc.drawLine(x1, y1, x2, y2);
    	}
    }

    function drawHand(dc, num, time, length, stroke) {
    	var angle = Math.toRadians((360/num) * time) - Math.PI/2;
    	
    	var center = dc.getWidth()/2;
    	
    	dc.setPenWidth(stroke);
    	
    	var x = center + Math.round((Math.cos(angle) * length));
    	var y = center + Math.round((Math.sin(angle) * length));
    	
    	dc.drawLine(center, center, x, y);
    	
    }
    
    function drawSecondHandClip(dc, num, time, length, stroke) {
		dc.drawBitmap(0, 0, offScreenBuffer);

    	var angle = Math.toRadians((360/num) * time) - Math.PI/2;
    	var center = dc.getWidth()/2;
    	dc.setPenWidth(stroke);
    	
    	var cosval = Math.round(Math.cos(angle) * length);
    	var sinval = Math.round(Math.sin(angle) * length);
    	
    	var x = center + cosval;
    	var y = center + sinval;
    	var width = dc.getWidth();
    	var height = dc.getHeight();
    	var width2 = (center-x).abs();
    	var height2 = (center-y).abs();
    	var padding = width * relative_padding;
    	var padding2 = width * relative_padding2;
    	
    	if(cosval < 0 && sinval > 0) {
    		dc.setClip(center-width2-padding2, center-padding, width2+padding+padding2, height2+padding+padding2);
    	}
    	
    	if(cosval < 0 && sinval < 0) {
    		dc.setClip(center-width2-padding2, center-height2-padding2, width2+padding+padding2, height2+padding+padding2);
    	}
    	
    	if(cosval > 0 && sinval < 0) {
    		dc.setClip(center-padding, center-height2-padding2, width2+padding+padding2, height2+padding+padding2);
    	}
    	
    	if(cosval > 0 && sinval > 0) {
	    	dc.setClip(center-padding, center-padding, width2+padding+padding2, height2+padding+padding2);
    	}
    	

    	dc.setColor(second_hand_color, Graphics.COLOR_TRANSPARENT);
    	dc.drawLine(center, center, x, y);    	
    }
    
	//Draws a hand with an offset for a seperate time set (eg. hour hand)
    function drawHandOffset(dc, num, offsetNum, time, offsetTime, length, stroke) {
    	var angle = Math.toRadians((360/num) * time ) - Math.PI/2;
    	var section = 360.00/num/offsetNum;
    	
    	angle += Math.toRadians(section * offsetTime);
    	
    	var center = dc.getWidth()/2;
    	
    	dc.setPenWidth(stroke);
    	
    	var x = center + Math.round(Math.cos(angle) * length);
    	var y = center + Math.round(Math.sin(angle) * length);
    	
    	dc.drawLine(center, center, x, y);
    }

	function drawDate(dc, x, y) {
		var width = dc.getWidth();
		var height = dc.getHeight();
		
		var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		var dateString = Lang.format("$1$.$2$.$3$", [info.day, info.month.format("%02d"), info.year % 100]);

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
