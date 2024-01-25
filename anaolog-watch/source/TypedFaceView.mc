//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Application;

import Complicated;

//! Main watch face view
class TypedFaceView extends WatchUi.WatchFace {
    // We can't initialize time label in the initializer
    // so it has to be declared as accepting null
    private var _timeLabel as Text?;  
    private var _complications as Array<ComplicationDrawable>;
    private var showSeconds as Boolean;

    //! Constructor
    function initialize() {
        WatchFace.initialize();
        _complications = new Array<ComplicationDrawable>[4];
        showSeconds = true;
    }

    //! Load layout
    //! @param dc Draw context
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        _timeLabel = View.findDrawableById("TimeLabel") as Text;

        _complications[0] = View.findDrawableById("Complication1") as ComplicationDrawable;
        var prop = Application.getApp().getProperty("Complication1");
        _complications[0].setModelUpdater(Complicated.getComplication(prop));

        _complications[1] = View.findDrawableById("Complication2") as ComplicationDrawable;    
        prop = Application.getApp().getProperty("Complication2");
        _complications[1].setModelUpdater(Complicated.getComplication(prop));

        _complications[2] = View.findDrawableById("Complication3") as ComplicationDrawable;    
        prop = Application.getApp().getProperty("Complication3");
        _complications[2].setModelUpdater(Complicated.getComplication(prop));

        _complications[3] = View.findDrawableById("Complication4") as ComplicationDrawable;    
        prop = Application.getApp().getProperty("Complication4");
        _complications[3].setModelUpdater(Complicated.getComplication(prop));

    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() as Void {
    }

    //! Update the view
    //! @param dc Draw context
    function onUpdate(dc as Dc) as Void {
        // Get the current time and format it correctly
        var timeString;

        if ( showSeconds == true ) {
            var timeFormat = "$1$:$2$:$3$";
            var clockTime = System.getClockTime();
            var hours = clockTime.hour;

            timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d"), clockTime.sec.format("%02d")]);
        } else {
            var timeFormat = "$1$:$2$";
            var clockTime = System.getClockTime();
            var hours = clockTime.hour;

            timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
        }

        // Update the view
        _timeLabel.setColor(Application.getApp().getProperty("ForegroundColor"));
        _timeLabel.setText(timeString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        showSeconds = true;
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        showSeconds = false;
    }

}
