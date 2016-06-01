// This file is part of GNOME Boxes. License: LGPLv2+

private class DeferredChange {
    public signal void flushed ();

    public string id { get; private set; }
    public SourceFunc func;
    public uint interval { get; private set; } // In seconds

    private uint timeout_id;

    public DeferredChange (string id, owned SourceFunc func, uint interval = 0) {
        this.id = id;
        this.func = (owned) func;
        this.interval = interval;

        if (interval == 0)
            return;

        timeout_id = Timeout.add_seconds (interval, () => {
            flush ();

            return false;
        });
    }

    public void flush () {
        if (func == null)
            return;

        func ();
        func = null;

        unschedule ();

        flushed ();
    }

    public void unschedule () {
        if (timeout_id > 0)
            Source.remove (timeout_id);
        timeout_id = 0;
    }
}
