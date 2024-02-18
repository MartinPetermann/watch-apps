//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

module Complicated {

    //! Draw a complication
    class ComplicationDrawable extends WatchUi.Drawable {
        private const foregroundColor = Application.Properties.getValue("ForegroundColor");
        private const backgroundColor = Application.Properties.getValue("BackgroundColor");
        private const text_color_f = Application.Properties.getValue("TextColorF");
	    private const text_color_b = Application.Properties.getValue("TextColorB");
        private const arc_color_f = Application.Properties.getValue("ArcColorF");
	    private const arc_color_b = Application.Properties.getValue("ArcColorB");

        private var _background as BitmapType = Application.loadResource(Rez.Drawables.complication);
        private var _updater as ModelUpdater?;
        private var _radius as Float;
        private var _centerX as Number;
        private var _centerY as Number;

        private var mySettings = System.getDeviceSettings();
        private var screen_width = mySettings.screenWidth;
        private var screen_height = mySettings.screenHeight;

        //! Constructor
        //! @param params Drawable arguments
        public function initialize(params as { :identifier as Object, :locX as Numeric, :locY as Numeric, :width as Numeric, :height as Numeric }) {   

            // Use the given point as the center point
            var backgroundHeight = _background.getHeight();

            _centerX = params[:locX]*screen_width/100;
            _centerY = params[:locY]*screen_height/100;
            _radius = backgroundHeight / 1.25;

            var options = {
                :locX => params[:locX],
                :locY => params[:locY],
                :identifier => params[:identifier]
            };

            // Initialize superclass
            Drawable.initialize(options);
        }

        //! Set the model updater for the complication
        //! @param updater Model updater for the complication or null to disable
        public function setModelUpdater(updater as ModelUpdater?) as Void {
            _updater = updater;
        }

        //! Draw the complication
        //! @param dc Draw context
        public function draw(dc as Dc) as Void {            
            if (_updater != null) {
                var model = _updater.updateModel();

                if (model instanceof PercentModel or model instanceof LabelModel) {
                    if (model.icon != null) {
                        var icon = model.icon;
                        var iconWidth = icon.getWidth();
                        var iconHeight = icon.getHeight();                

                        // Draw the icon
                        dc.drawBitmap(_centerX - (iconWidth / 2), _centerY - (iconHeight / 2), icon);
                    }

                    var label = model.label;           

                    if (model instanceof PercentModel) {
                        // Handle drawing the percent
                        var percent = (model as PercentModel).percent;

                        dc.setPenWidth(4);
                        dc.setColor(arc_color_b, backgroundColor);
                        dc.drawCircle(_centerX, _centerY, _radius);

                        dc.setColor(arc_color_f, backgroundColor);
                        dc.setPenWidth(2);

                        // Start drawing from the top
                        if (percent > 0) {
                            if(percent <= 25) {
                                dc.drawArc(_centerX, _centerY, _radius, Graphics.ARC_CLOCKWISE, 90, 90 - (360 * (percent / 100.0)));
                            } else {
                                dc.drawArc(_centerX, _centerY, _radius, Graphics.ARC_CLOCKWISE, 90, 0);
                                dc.drawArc(_centerX, _centerY, _radius, Graphics.ARC_CLOCKWISE, 0, 360 - (360 * ((percent - 25.0) / 100.0)));
                            }
                        }                     
                    } 

                    // Draw the label
                    dc.setColor(text_color_b, backgroundColor);
                    dc.drawText(_centerX+1, _centerY+1, Graphics.FONT_TINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                    dc.setColor(text_color_f, backgroundColor);
                    dc.drawText(_centerX, _centerY, Graphics.FONT_TINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

                } else if (model instanceof StringModel) {
                    // Handle drawing the label
                    var label = model.label;

                    // Draw the label
                    dc.setColor(foregroundColor, backgroundColor);
                    dc.drawText(_centerX, _centerY + (_radius * .75), Graphics.FONT_TINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);                    
                }
            }
        }
    }
}