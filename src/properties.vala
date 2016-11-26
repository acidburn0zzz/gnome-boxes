// This file is part of GNOME Boxes. License: LGPLv2+
using Gtk;

private enum Boxes.PropertiesPage {
    GENERAL,
    SYSTEM,
    DEVICES,
    SNAPSHOTS,

    LAST,
}

private class Boxes.Properties: Gtk.Notebook, Boxes.UI {
    public UIState previous_ui_state { get; protected set; }
    public UIState ui_state { get; protected set; }

    private AppWindow window;

    private ulong stats_id;
    private bool restore_fullscreen;

    construct {
        notify["ui-state"].connect (ui_state_changed);
    }

    private async void populate () {
        foreach (var page in get_children ())
            remove (page);

        var machine = window.current_item as Machine;

        if (machine == null)
            return;

        for (var i = 0; i < PropertiesPage.LAST; i++) {
            var page = yield machine.get_properties (i);
            if (page.empty)
                continue;

            var label = new Gtk.Label (page.name);
            insert_page (page, label, i);
            page.show_all ();

            ulong props_refresh_id = 0;
            props_refresh_id = page.refresh_properties.connect (() => {
                page.disconnect (props_refresh_id);
                var current_page = this.page;
                this.populate.begin ((object, result) => {
                    this.populate.end (result);
                    this.page = current_page;
                });
            });
        }

        page = PropertiesPage.GENERAL;
    }

    public void setup_ui (AppWindow window, PropertiesWindow dialog) {
        this.window = window;
        key_press_event.connect (on_key_pressed);

        show_all ();
    }

    private void ui_state_changed () {
        if (stats_id != 0) {
            window.current_item.disconnect (stats_id);
            stats_id = 0;
        }

        if (ui_state == UIState.PROPERTIES) {
            restore_fullscreen = (previous_ui_state == UIState.DISPLAY && window.fullscreened);
            window.fullscreened = false;

            populate.begin ();
        } else if (previous_ui_state == UIState.PROPERTIES) {
            var reboot_required = false;

            foreach (var child in get_children ()) {
                var page = child as PropertiesPageWidget;

                reboot_required |= page.flush_changes ();

                remove (child);
            }

            var machine = window.current_item as Machine;
            if (reboot_required && (machine.is_on || machine.state == Machine.MachineState.SAVED)) {
                var message = _("Changes require restart of “%s”.").printf (machine.name);
                window.notificationbar.display_for_action (message, _("_Restart"), () => {
                    machine.restart ();
                });
            }

            if (restore_fullscreen) {
                window.fullscreened = true;
                restore_fullscreen = false;
            }
        }
    }

    private bool on_key_pressed (Widget widget, Gdk.EventKey event) {
        var default_modifiers = Gtk.accelerator_get_default_mod_mask ();

        if (event.keyval == Gdk.Key.Left && // ALT + Left -> Prev page
            (event.state & default_modifiers) == Gdk.ModifierType.MOD1_MASK) {
            if (page > PropertiesPage.GENERAL)
                page = page - 1;
            return true;
        } else if (event.keyval == Gdk.Key.Right && // ALT + Right -> Next page
            (event.state & default_modifiers) == Gdk.ModifierType.MOD1_MASK) {
            if (page < PropertiesPage.LAST)
                page = page + 1;
            return true;
        }

        return false;
    }

}
