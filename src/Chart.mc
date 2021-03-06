// -*- mode: Javascript;-*-

class Chart {
    var model;

    function initialize(a_model) {
        model = a_model;
    }

    function draw(dc, x1y1x2y2,
                  line_color, block_color,
                  range_min_size, draw_min_max, draw_axes,
                  strict_min_max_bounding, formatter) {
        // Work around 10 arg limit!
        var x1 = x1y1x2y2[0];
        var y1 = x1y1x2y2[1];
        var x2 = x1y1x2y2[2];
        var y2 = x1y1x2y2[3];

        var data = model.get_values();

        var range_border = 5;

        var width = x2 - x1;
        var height = y2 - y1;
        var x = x1;
        var x_next;
        var item;

        var min = model.get_min();
        var max = model.get_max();

        var range_min = min - range_border;
        var range_max = max + range_border;
        if (range_max - range_min < range_min_size) {
            range_max = range_min + range_min_size;
        }

        var x_old = null;
        var y_old = null;
        for (var x = x1; x <= x2; x++) {
            item = data[x_item(x, x1, width, data.size())];
            if (item != null && item > range_max) {
                dc.setColor(block_color, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x, y1, x, y2);
                x_old = null;
                y_old = null;
            }
            else if (item != null && item >= range_min) {
                var y = item_y(item, y2, height, range_min, range_max);
                dc.setColor(block_color, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x, y, x, y2);
                if (x_old != null) {
                    dc.setColor(line_color, Graphics.COLOR_TRANSPARENT);
                    dc.drawLine(x_old, y_old, x, y);
                    // TODO is the below line needed due to a CIQ bug
                    // or some subtlety I don't understand?
                    dc.drawPoint(x, y);
                }
                x_old = x;
                y_old = y;
            }
            else {
                x_old = null;
                y_old = null;
            }
        }

        if (draw_axes) {
            dc.setColor(line_color, Graphics.COLOR_TRANSPARENT);
            tick_line(dc, x1, y1, y2, -5, true);
            tick_line(dc, x2, y1, y2, 5, true);
            tick_line(dc, y2, x1, x2 + 1, 5, false);
        }

        if (draw_min_max and model.get_min_max_interesting()) {
            dc.setColor(line_color, Graphics.COLOR_TRANSPARENT);
            var bg_color = line_color == Graphics.COLOR_WHITE
                ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
            label_text(dc, item_x(model.get_min_i(), x1, width, data.size()),
                       item_y(min, y2, height, range_min, range_max),
                       x1y1x2y2, line_color, bg_color, formatter.fmt_num(min),
                       strict_min_max_bounding, false);
            label_text(dc, item_x(model.get_max_i(), x1, width, data.size()),
                       item_y(max, y2, height, range_min, range_max),
                       x1y1x2y2, line_color, bg_color, formatter.fmt_num(max),
                       strict_min_max_bounding, true);
        }
    }

    function item_x(i, orig_x, width, size) {
        return orig_x + i * width / (size - 1);
    }

    function x_item(x, orig_x, width, size) {
        return (x - orig_x) * (size - 1) / width;
    }

    function item_y(item, orig_y, height, min, max) {
        return orig_y - height * (item - min) / (max - min);
    }

    function label_text(dc, x, y, x1y1x2y2, fg, bg, txt, strict, above) {
        var x1 = x1y1x2y2[0];
        var y1 = x1y1x2y2[1];
        var x2 = x1y1x2y2[2];
        var y2 = x1y1x2y2[3];

        var dims = dc.getTextDimensions(txt, Graphics.FONT_XTINY);
        var w = dims[0];
        var h = dims[1];

        x -= w / 2;
        if (x < x1 + 2) {
            x = x1 + 2;
        } else if (x > x2 - w - 2) {
            x = x2 - w - 2;
        }
        if (above) {
            y -= h;
        }
        if (strict) {
            if (y > y2 - h) {
                y = y2 - h;
            }
            else if (y < y1) {
                y = y1;
            }
        }
        text_outline(dc, x, y, fg, bg, Graphics.FONT_XTINY, txt);
    }

    function text_outline(dc, x, y, fg, bg, font, s) {
        dc.setColor(bg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x-2, y, font, s, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(x+2, y, font, s, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(x, y-2, font, s, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(x, y+2, font, s, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(fg, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function tick_line(dc, c, end1, end2, tick_size, vert) {
        tick_line0(dc, c, end1, end2, vert);
        for (var n = 1; n <= 3; n++) {
            tick_line0(dc, ((4 - n) * end1 + n * end2) / 4, c, c + tick_size,
                       !vert);
        }
    }

    function tick_line0(dc, c, end1, end2, vert) {
        if (vert) {
            dc.drawLine(c, end1, c, end2);
        } else {
            dc.drawLine(end1, c, end2, c);
        }
    }
}
