//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.Application;
import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

module Complicated {

    //! Class to update the steps
    class Steps {
        //! Steps icon (? => can be null)
        private var _icon as BitmapType?;

        //! Constructor
        public function initialize() {
            _icon = null;  
        }

        //! Update the model 
        public function updateModel() as Complicated.Model {
            var info = ActivityMonitor.getInfo();
            var stepsPercent = (info.steps.toFloat() / info.stepGoal.toFloat()) * 100;
            var steps = "STEPS\n" + info.steps.toString();
            return new PercentModel(steps, stepsPercent.toNumber(), _icon);
        }
    }
}