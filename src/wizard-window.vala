// This file is part of GNOME Boxes. License: LGPLv2+
using Gtk;

private enum Boxes.WizardWindowPage {
    MAIN,
    CUSTOMIZATION,
    FILE_CHOOSER,
}

[GtkTemplate (ui = "/org/gnome/Boxes/ui/wizard-window.ui")]
private class Boxes.WizardWindow : Gtk.Window, Boxes.UI {
    public const string[] page_names = { "main", "customization", "file_chooser" };

    public delegate void FileChosenFunc (string uri);

    public UIState previous_ui_state { get; protected set; }
    public UIState ui_state { get; protected set; }

    private WizardWindowPage _page;
    public WizardWindowPage page {
        get { return _page; }
        set {
            if (_page == WizardWindowPage.CUSTOMIZATION && value != WizardWindowPage.CUSTOMIZATION &&
                props_page_widget != null && !props_page_widget.empty) {
                props_page_widget.flush_changes ();
                props_page_widget  = null;

                wizard.review.begin ();
            }

            _page = value;

            view.visible_child_name = page_names[value];
            topbar.page = value;
        }
    }

    [GtkChild]
    public Gtk.Stack view;
    [GtkChild]
    public Wizard wizard;
    [GtkChild]
    public Gtk.Grid customization_grid;
    [GtkChild]
    public Gtk.FileChooserWidget file_chooser;
    [GtkChild]
    public WizardToolbar topbar;
    [GtkChild]
    public Notificationbar notificationbar;

    private PropertiesPageWidget? props_page_widget;

    public WizardWindow (AppWindow app_window) {
        wizard.setup_ui (app_window, this);
        topbar.setup_ui (this);

        // FIXME: Can we do this from UI file somehow? Would be nice, if so
        file_chooser.filter = new Gtk.FileFilter ();
        file_chooser.filter.add_mime_type ("application/x-cd-image");
        foreach (var extension in InstalledMedia.supported_extensions)
            file_chooser.filter.add_pattern ("*" + extension);

        set_transient_for (app_window);

        notify["ui-state"].connect (ui_state_changed);
    }

    public async void show_customization_page (LibvirtMachine machine) {
        foreach (var child in customization_grid.get_children ())
            customization_grid.remove (child);

        var props_page_widget = new PropertiesPageWidget (PropertiesPage.SYSTEM);
        customization_grid.add (props_page_widget);
        yield machine.properties.add_resources_properties (props_page_widget);
        customization_grid.show_all ();

        page = WizardWindowPage.CUSTOMIZATION;
    }

    public void show_file_chooser (owned FileChosenFunc file_chosen_func) {
        ulong activated_id = 0;
        activated_id = file_chooser.file_activated.connect (() => {
            var uri = file_chooser.get_uri ();
            file_chosen_func (uri);
            file_chooser.disconnect (activated_id);

            page = WizardWindowPage.MAIN;
        });
        page = WizardWindowPage.FILE_CHOOSER;
    }

    private void ui_state_changed () {
        wizard.set_state (ui_state);

        this.visible = (ui_state == UIState.WIZARD);
    }

    [GtkCallback]
    private bool on_key_pressed (Widget widget, Gdk.EventKey event) {
        var default_modifiers = Gtk.accelerator_get_default_mod_mask ();
        var direction = get_direction ();

        if (((direction == Gtk.TextDirection.LTR && // LTR
              event.keyval == Gdk.Key.Left) ||      // ALT + Left -> back
             (direction == Gtk.TextDirection.RTL && // RTL
              event.keyval == Gdk.Key.Right)) &&    // ALT + Right -> back
            (event.state & default_modifiers) == Gdk.ModifierType.MOD1_MASK) {
            topbar.click_back_button ();
            return true;
        } else if (((direction == Gtk.TextDirection.LTR && // LTR
                     event.keyval == Gdk.Key.Right) ||     // ALT + Right -> forward
                    (direction == Gtk.TextDirection.RTL && // RTL
                     event.keyval == Gdk.Key.Left)) &&     // ALT + Left -> forward
                   (event.state & default_modifiers) == Gdk.ModifierType.MOD1_MASK) {
            topbar.click_forward_button ();
            return true;
        } else if (event.keyval == Gdk.Key.Escape) { // ESC -> cancel
            if (page == WizardWindowPage.MAIN)
                topbar.cancel_btn.clicked ();
            else
                page = WizardWindowPage.MAIN;

        }

        return false;
    }

    [GtkCallback]
    private bool on_delete_event () {
        wizard.cancel ();

        return true;
    }
}
