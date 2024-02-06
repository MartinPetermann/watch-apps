//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.Application;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

module Complicated {

    //! Class to generate the battery model
    class Battery {

        //! Battery icons
        private var _icon as BitmapType;  
        private var _label as String;
        private var _show_icon as Boolean;

        //! Constructor
        public function initialize() {
            _icon = Application.loadResource(Rez.Drawables.battery);
            _label = "🔋";
            _show_icon = true;
        }

        //! Update the model 
        public function updateModel() as Complicated.Model {
            var stats = System.getSystemStats();
            var battery = stats.battery;

            // Return the new model
            return new PercentModel(_label, battery.toNumber(), _icon, _show_icon);
        }    

    }

}