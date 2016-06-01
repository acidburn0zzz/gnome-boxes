// This file is part of GNOME Boxes. License: LGPLv2+
using Gtk;

private class Boxes.PropertiesPageWidget: Gtk.Box {
    public bool empty;
    public bool reboot_required;

    private Gtk.Grid grid;
    private List<Boxes.Property> properties;
    private List<DeferredChange> deferred_changes;

    public signal void refresh_properties ();

    private int num_rows = 0;

    public PropertiesPageWidget (PropertiesPage page, Machine machine) {
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

        properties = machine.get_properties (page);
        empty = properties.length () == 0;
        if (!empty) {
            foreach (var property in properties) {
                add_property (property.description,
                              property.widget,
                              property.extra_widget,
                              property.description_alignment);

                property.refresh_properties.connect (() => {
                    this.refresh_properties ();
                });
            }
        }

        show_all ();
    }

    public bool flush_changes () {
        var reboot_required = this.reboot_required;

        foreach (var property in properties) {
            property.flush ();
            reboot_required |= property.reboot_required;
        }

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
}
