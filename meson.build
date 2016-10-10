#
# Copyright (c) 2016 Pelagicore AB.
#
# Author: Zeeshan Ali <zeeshanak@gnome.org>
#
project('gnome-boxes', 'vala', 'c', version: '3.23.1')

cc = meson.get_compiler('c')
conf = configuration_data()

#check_headers = [
#    ['HAVE_DLFCN_H', 'dlfcn.h'],
#    ['HAVE_INTTYPES_H', 'inttypes.h'],
#    ['HAVE_MEMORY_H', 'memory.h'],
#    ['HAVE_STDINT_H', 'stdint.h'],
#    ['HAVE_STDLIB_H', 'stdlib.h'],
#    ['HAVE_STRINGS_H', 'strings.h'],
#    ['HAVE_STRING_H', 'string.h'],
#    ['HAVE_SYS_STAT_H', 'sys/stat.h'],
#    ['HAVE_SYS_TYPES_H', 'sys/types.h'],
#    ['HAVE_UNISTD_H', 'unistd.h'],
#]
#
#foreach h : check_headers
#    if cc.has_header(h.get(1))
#        conf.set(h.get(0), 1)
#    endif
#endforeach

boxes_version = meson.project_version()
conf.set('VERSION', '"' + boxes_version + '"')
conf.set('PACKAGE_VERSION', '"' + boxes_version + '"')
conf.set('PACKAGE_NAME', '"gnome-boxes"')
conf.set('GETTEXT_PACKAGE', '"gnome-boxes"')
conf.set('PACKAGE_TARNAME', '"gnome-boxes"')
conf.set('PACKAGE_STRING', '"gnome-boxes ' + boxes_version + '"')
conf.set('PACKAGE_URL', '"https://wiki.gnome.org/Apps/Boxes"')
conf.set('PACKAGE_BUGREPORT', '"https://bugzilla.gnome.org/enter_bug.cgi?product=gnome-boxes"')

if get_option('strict-cc')
    add_global_arguments('-Wall -Werror', language: 'c')
endif

if get_option('debug')
    add_global_arguments('-O0 -ggdb3', language: 'c')
    add_global_arguments('-g', language: 'vala')
endif

configure_file(output : 'config.h', configuration : conf)

libgd_gtk_hacks = true
libgd_main_view = true
libgd_main_icon_view = true
libgd_notification = true
libgd_static = true
libgd_vapi = true
subdir('libgd')

#subdir('data')
#subdir('help')
subdir('src')
#subdir('po')
#subdir('vapi')

# MOVE TO data subdir
#data/org.gnome.Boxes.desktop.in
