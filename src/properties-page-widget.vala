// This file is part of GNOME Boxes. License: LGPLv2+
using Gtk;

private class Boxes.PropertiesPageWidget: Gtk.Box {
    public bool empty { get { return (grid.get_children ().length () == 0); } }
    public bool reboot_required;

    private Gtk.Grid grid;
    private List<DeferredChange> deferred_changes;

    public signal void refresh_properties ();

    public delegate void SizePropertyChanged (PropertiesPageWidget widget, uint64 value);
    public delegate void StringPropertyChanged (PropertiesPageWidget widget, string value);

    private int num_rows = 0;

    private static void set_size_value_label_msg (Gtk.Label       label,
                                                  uint64          size,
                                                  uint64          allocation,
                                                  FormatSizeFlags format_flags) {
        var capacity = format_size (size, format_flags);

        if (allocation == 0) {
            label.set_text (capacity);
        } else {
            var allocation_str = format_size (allocation, format_flags);

            // Translators: This is memory or disk size. E.g. "2 GB (1 GB used)".
            label.set_markup (_("%s <span color=\"grey\">(%s used)</span>").printf (capacity, allocation_str));
        }
    }

    public PropertiesPageWidget (PropertiesPage page) {
        deferred_changes = new List<DeferredChange> ();

        switch (page) {
        case PropertiesPage.GENERAL:
            name = _("General");
            break;

        case PropertiesPage.SYSTEM:
            name = _("System");
            break;

        case PropertiesPage.DEVICES:
            name = _("Devices");
            break;

        case PropertiesPage.SNAPSHOTS:
            name = _("Snapshots");
            break;
        }

        get_style_context ().add_class ("transparent-bg");

        grid = new Gtk.Grid ();
        grid.margin = 20;
        grid.row_spacing = 10;
        grid.column_spacing = 20;
        var scrolled_win = new Gtk.ScrolledWindow (null, null);
        scrolled_win.margin_start = 20;
        scrolled_win.margin_end = 20;
        scrolled_win.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
        scrolled_win.add (grid);
        pack_end (scrolled_win, true, true);

        show_all ();
    }

    public bool flush_changes () {
        var reboot_required = this.reboot_required;

        foreach (var change in deferred_changes)
            change.flush ();
        deferred_changes = new List<DeferredChange> (); // FIXME: Better way to clear the list?

        return reboot_required;
    }

    public void add_deferred_change (DeferredChange change) {
        DeferredChange? deferred = null;

        foreach (var c in deferred_changes) {
            if (c.id == change.id) {
                deferred = c;

                break;
            }
        }

        if (deferred != null) {
            deferred.unschedule ();
            deferred_changes.remove (deferred);
        }

        deferred_changes.append (change);
    }

    public void add_property (string?     description,
                              Gtk.Widget  widget,
                              Gtk.Widget? extra_widget = null,
                              Gtk.Align   description_alignment = Gtk.Align.END) {
        if (description != null) {
            var label_name = new Gtk.Label.with_mnemonic (description);
            label_name.get_style_context ().add_class ("dim-label");
            label_name.halign = description_alignment;
            label_name.hexpand = false;
            grid.attach (label_name, 0, num_rows, 1, 1);
            widget.hexpand = true;
            grid.attach (widget, 1, num_rows, 1, 1);
            label_name.mnemonic_widget = widget;
        } else {
            widget.hexpand = true;
            grid.attach (widget, 0, num_rows, 2, 1);
        }

        num_rows++;

        if (extra_widget != null) {
            extra_widget.hexpand = true;
            grid.attach (extra_widget, 0, num_rows, 2, 1);

            num_rows++;
        }
    }

    public Gtk.Widget add_size_property (string              name,
                                         uint64              size,
                                         uint64              min,
                                         uint64              max,
                                         uint64              allocation,
                                         uint64              step,
                                         SizePropertyChanged changed,
                                         int64               recommended,
                                         out Gtk.Scale       out_scale,
                                         FormatSizeFlags     format_flags = FormatSizeFlags.DEFAULT) {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        var name_label = new Gtk.Label.with_mnemonic (name);
        name_label.halign = Gtk.Align.START;
        name_label.get_style_context ().add_class ("dim-label");
        box.add (name_label);
        var value_label = new Gtk.Label ("");
        set_size_value_label_msg (value_label, size, allocation, format_flags);
        value_label.halign = Gtk.Align.START;
        box.add (value_label);

        var scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, min, max, step);
        out_scale = scale;
        name_label.mnemonic_widget = scale;

        var size_str = format_size (min, format_flags);
        size_str = "<small>" + size_str + "</small>";
        scale.add_mark (min, Gtk.PositionType.BOTTOM, size_str);

        // Translators: This is memory or disk size. E.g. "1 GB (maximum)".
        size_str =  "<small>" + _("%s (maximum)").printf (format_size (max, format_flags)) + "</small>";
        scale.add_mark (max, Gtk.PositionType.BOTTOM, size_str);

        scale.set_show_fill_level (true);
        scale.set_restrict_to_fill_level (false);
        scale.set_value (size);
        scale.set_fill_level (size);
        scale.set_draw_value (false);
        scale.hexpand = true;
        scale.margin_bottom = 20;

        add_property (null, box, scale);

        if (recommended > 0 &&
            // FIXME: Better way to ensure recommended mark is not too close to min and max marks?
            recommended >= (scale.adjustment.lower + Osinfo.GIBIBYTES) &&
            recommended <= (scale.adjustment.upper - Osinfo.GIBIBYTES)) {

            // Translators: This is memory or disk size. E.g. "1 GB (recommended)".
            var str = "<small>" + _("%s (recommended)").printf (format_size (recommended, format_flags)) + "</small>";
            scale.add_mark (recommended, Gtk.PositionType.BOTTOM, str);
        }

        scale.value_changed.connect (() => {
            uint64 v = (uint64) scale.get_value ();
            set_size_value_label_msg (value_label, v, allocation, format_flags);
            scale.set_fill_level (v);

            changed (this, (uint64) scale.get_value ());
        });

        return box;
    }

    public void add_string_property (string name, string value, StringPropertyChanged? changed = null) {
        if (changed != null) {
            var entry = new Gtk.Entry ();

            add_property (name, entry, null);

            entry.text = value;

            entry.notify["text"].connect (() => {
                changed (this, entry.text);
            });
        } else {
            var label = new Gtk.Label (value);
            label.halign = Gtk.Align.START;
            label.selectable = true;

            add_property (name, label, null);
        }
    }
}
