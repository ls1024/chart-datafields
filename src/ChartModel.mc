// -*- mode: Javascript;-*-

using Toybox.System as System;
using Toybox.Application as App;

class ChartModel {
    var current = null;
    var values_size = 150;
    var values;
    var range_mult;
    var range_mult_count = 0;

    var min;
    var max;
    var min_i;
    var max_i;

    function initialize() {
        set_range_minutes(5);
    }

    function get_values() {
        return values;
    }

    function get_range_minutes() {
        return (values.size() * range_mult / 60);
    }

    function set_range_minutes(range) {
        var new_mult = range * 60 / values_size;
        if (new_mult != range_mult) {
            range_mult = new_mult;
            values = new [values_size];
        }
    }

    function get_current() {
        return current;
    }

    function get_min() {
        return min;
    }

    function get_max() {
        return max;
    }

    function get_min_i() {
        return min_i;
    }

    function get_max_i() {
        return max_i;
    }

    function get_min_max_interesting() {
        return max != 0 and min != max;
    }

    function new_value(new_value) {
        current = new_value;
        range_mult_count++;
        if (range_mult_count >= range_mult) {
            for (var i = 1; i < values.size(); i++) {
                values[i-1] = values[i];
            }
            values[values.size() - 1] = current;
            range_mult_count = 0;
        }

        update_min_max();
    }

    function update_min_max() {
        min = 999999;
        max = 0;
        min_i = 0;
        max_i = 0;

        for (var i = 0; i < values.size(); i++) {
            var item = values[i];
            if (item != null) {
                if (item < min) {
                    min_i = i;
                    min = item;
                }
                
                if (item > max) {
                    max_i = i;
                    max = item;
                }
            }
        }
    }

    function read_data() {
        var app = App.getApp();
        var old_range_mult = app.getProperty(RANGE_MULT);
        if (old_range_mult != null) {
            range_mult = old_range_mult;
        }
        else {
            range_mult = 1;
        }

        var old_values = app.getProperty(LAST_VALUES);
        var old_time = app.getProperty(LAST_VALUE_TIME);
        if (old_values != null && old_time != null) {
            values = new[values_size];
            var delta = (System.getTimer() - old_time) / 1000 / range_mult;
            if (delta > 0) { // Ignore old data from before reboot
                for (var i = 0; i < values.size() - delta; i++) {
                    values[i] = old_values[i + delta];
                }
            }
        }
        else {
            values = new[values_size];
        }

        update_min_max();
    }

    function write_data() {
        var app = App.getApp();
        app.setProperty(LAST_VALUES, values);
        app.setProperty(LAST_VALUE_TIME, System.getTimer());
        app.setProperty(RANGE_MULT, range_mult);
    }
}
