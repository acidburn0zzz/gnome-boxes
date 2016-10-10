#
# Copyright (c) 2016 Pelagicore AB.
#
# Author: Zeeshan Ali <zeeshanak@gnome.org>
#

glib_min_version = '2.38.0'

deps = [ dependency('glib-2.0', version: '>= ' + glib_min_version),
         dependency('gio-2.0', version: '>= ' + glib_min_version),
         dependency('gobject-introspection-1.0', version: '>= 0.9.6'),
         dependency('gtk+-3.0', version: '>= 3.19.8'),
         dependency('gtk-vnc-2.0', version: '>= 0.4.4'),
         dependency('libvirt-gobject-1.0', version: '>= 0.2.3'),
         dependency('libvirt-gconfig-1.0', version: '>= 0.2.0'),
         dependency('libxml-2.0', version: '>= 2.7.8'),
         dependency('libusb-1.0', version: '>= 1.0.9'),
         dependency('spice-client-gtk-3.0', version: '>= 0.27'),
         dependency('gudev-1.0', version: '>= 165'),
         dependency('libosinfo-1.0', version: '>= 0.2.12'),
#         dependency('uuid', version: '>= 1.41.3'),
         dependency('libsoup-2.4', version: '>= 2.38'),
         dependency('libarchive', version: '>= 3.0.0'),
         dependency('tracker-sparql-1.0', version: '>= 0.13.1'),
         dependency('gmodule-2.0'),
         dependency('rest-0.7'),
         libgd_dep ]

include_dirs = include_directories(meson.source_root() + '/libgd')

source_datadir = meson.source_root() + '/data'
resources_file = source_datadir + '/gnome-boxes.gresource.xml'
gresources = gnome.compile_resources('gnome-boxes.gresource',
                                     resources_file,
                                     source_dir: source_datadir)

datadir = get_option('prefix') + '/' + get_option('datadir')

vala_args = ['--pkg=config',
             '--enable-experimental',
             '--target-glib=' + glib_min_version,
             # Should be covered by include_directories below & libgd_dep.
             # See https://github.com/mesonbuild/meson/issues/906
             '--vapidir=' + meson.current_source_dir(),
             '--vapidir=' + meson.build_root(),
             '--vapidir=' + meson.source_root() + '/vapi',
             '--vapidir=' + meson.source_root() + '/vapi/upstream',
             '--pkg=posix',
             '--pkg=linux',
             '--pkg=gd-1.0',
             '--pkg=gio-2.0-workaround' ]
c_args = ['-DDATADIR="' + datadir + '"',
          '-DGNOMELOCALEDIR="' + datadir + '/locale"',
          '-DCACHEDIR="/var/cache/"',
          '-DG_LOG_DOMAIN="Boxes"' ]

include_dirs = include_directories(meson.source_root(),
                                   meson.current_source_dir(),
                                   meson.build_root() + '/libgd',
                                   meson.source_root() + '/vapi',
                                   meson.source_root() + '/vapi/upstream')

common_sources = [ 'async-launcher.vala',
                   'box-config.vala',
                   'collection-source.vala',
                   'util.vala' ]

search_provider_sources = common_sources + [
                          'gnome-boxes-search-provider.vala' ]
executable('gnome-boxes-search-provider',
           search_provider_sources,
           dependencies: deps,
           install: true,
           install_dir: get_option('libexecdir'),
           c_args: c_args,
           vala_args: vala_args,
           include_directories: include_dirs)

boxes_sources = common_sources + [
                gresources,
                'actions-popover.vala',
                'app.vala',
                'app-window.vala',
                'archive-reader.vala',
                'archive-writer.vala',
                'auth-notification.vala',
                'collection-filter-switcher.vala',
                'collection-toolbar.vala',
                'collection.vala',
                'display-page.vala',
                'display-toolbar.vala',
                'display.vala',
                'downloader.vala',
                'editable-entry.vala',
                'empty-boxes.vala',
                'i-collection-view.vala',
                'icon-view.vala',
                'installed-media.vala',
                'installer-media.vala',
                'i-properties-provider.vala',
                'iso-extractor.vala',
                'keys-input-popover.vala',
                'libvirt-broker.vala',
                'libvirt-cloned-media.vala',
                'libvirt-machine-properties.vala',
                'libvirt-machine.vala',
                'libvirt-media.vala',
                'libvirt-system-importer.vala',
                'libvirt-vm-cloner.vala',
                'libvirt-vm-importer.vala',
                'list-view-row.vala',
                'list-view.vala',
                'machine-thumbnailer.vala',
                'machine.vala',
                'main.vala',
                'media-manager.vala',
                'notificationbar.vala',
                'notification.vala',
                'os-database.vala',
                'properties-page-widget.vala',
                'properties-toolbar.vala',
                'properties.vala',
                'properties-window.vala',
                'remote-machine.vala',
                'resource-graph.vala',
                'searchbar.vala',
                'selectionbar.vala',
                'selection-toolbar.vala',
                'snapshot-list-row.vala',
                'snapshots-property.vala',
                'spice-display.vala',
                'topbar.vala',
                'tracker-iso-query.vala',
                'troubleshoot-log.vala',
                'ui.vala',
                'unattended-file.vala',
                'unattended-installer.vala',
                'unattended-setup-box.vala',
                'util-app.vala',
                'vm-configurator.vala',
                'vm-creator.vala',
                'vm-importer.vala',
                'vnc-display.vala',
                'wizard-source.vala',
                'wizard-toolbar.vala',
                'wizard.vala',
                'wizard-window.vala' ]

enable_ovirt = get_option('enable-ovirt')
if enable_ovirt == 'yes'
    deps += dependency('govirt-1.0', version: '>= 0.2.0')
    ovirt = true
elif enable_ovirt == 'auto'
    ovirt_dep = dependency('govirt-1.0', required : false)
    ovirt = ovirt_dep.found()
    if ovirt
        deps += ovirt_dep
    endif
else
    ovirt = false
endif

if ovirt
    boxes_sources += ['ovirt-broker.vala', 'ovirt-machine.vala' ]
endif

executable('gnome-boxes',
           boxes_sources,
           dependencies: deps,
           install: true,
           c_args: c_args,
           vala_args: vala_args,
           include_directories: include_dirs)
