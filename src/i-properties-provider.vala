// This file is part of GNOME Boxes. License: LGPLv2+
using Gtk;

private interface Boxes.IPropertiesProvider: GLib.Object {
    public abstract async PropertiesPageWidget get_properties (Boxes.PropertiesPage page);
}

