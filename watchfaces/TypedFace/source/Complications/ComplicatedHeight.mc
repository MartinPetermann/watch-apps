//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.Application;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

module Complicated {

    //! Class to update the steps
    class Height {
        //! Constructor
        //! Height icon
        private var _icon as BitmapType;

        public function initialize() {
            _icon = Application.loadResource(Rez.Drawables.height);
        }

        //! Update the model 
        public function updateModel() as Complicated.Model {
            var height = Toybox.Activity.getActivityInfo().altitude;

            var output = "ALT.\n" + height.format("%d");

            if (Toybox.System.getDeviceSettings().elevationUnits == Toybox.System.UNIT_METRIC) {
                output = output + " m";
            } else {
                output = output + " ft";
            }

            return new LabelModel(output, _icon);
        }
    }
}