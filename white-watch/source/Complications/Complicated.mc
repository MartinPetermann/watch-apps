//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.Lang;
import Toybox.Graphics;

//! Module for all the complications.
//! Fun fact! Avril Lavigne's "Complicated" came out in 2002 and is now considered "Dad Rock". How does that make you feel?
module Complicated {
    //! Model for complications that have the following appearance:
    //! 1. An arc fill around a circle
    //! 2. A icon or number in the middle
    //! This class is the standard return value for all of them.
    class PercentModel {
        //! Label
        public var label as String;
        //! Percent to fill the arc.
        public var percent as Number;
        //! Graphics.BitmapType is a new named type that covers
        //! all image representations (? => can be null)
        public var icon as BitmapType?;

        //! Constructor
        //! @param p 0 - 100 value for progress bar
        //! @param i Icon to display
        public function initialize(l as String, p as Number, i as BitmapType?) {
            // Initializing the members in the constructor
            // allows you to declare them as not being null
            label = l;
            percent = p;
            icon = i;
        }
    }

    //! Model for complications that have the following appearance
    //! 1. An identifier icon
    //! 2. A label under the icon
    class LabelModel {
        //! Label
        var label as String;
        //! Icon
        var icon as BitmapType;

        //! Constructor
        //! @param label Text label to display under icon
        //! @param icon Icon to display
        public function initialize(l as String, i as BitmapType) {
            label = l;
            icon = i;
        }
    }

    //! Model for complications that have the following appearance
    //! 1. A label under the icon
    class StringModel {
        //! Label
        var label as String;

        //! Constructor
        //! @param label Text label to display under icon
        public function initialize(l as String) {
            label = l;
        }
    }

    typedef Model as PercentModel or LabelModel or StringModel;

    //! Interface that covers our various
    //! complication update callbacks
    typedef ModelUpdater as interface {
        //! Function that provides an updated status 
        //! for the complication
        function updateModel() as Complicated.Model;
    };
}