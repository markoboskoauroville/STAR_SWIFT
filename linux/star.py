#!/usr/bin/env python3
"""Star (Mantra) for Linux: the star menu of the VM, a launcher and nothing else.

Marko, 5.11.2026: "make a Star Menu. We're going to slowly transfer Star Menu applications here. The first one is
Macro Recorder." And: "Star control apps should be one more addition to our status monitor at the bottom ... It starts
with this: David Star through triangles ... I click, and it opens up from the bottom up."
So the star has no window of its own: the VM status bar (vm-chromium, statusbar/chromium-vm-statusbar.py) draws the
David star as its first item and pops up `build_menu()` from this file, upwards. The rows: rows.linux.json
(installed as ~/.config/star-rows.linux.json). A click on a row that runs brings its window; on one that does not,
starts it. The tick shows what runs.  `star.py --print-menu` prints the menu without a screen.
"""
import json
import math
import os
import subprocess
import sys

VERSION = 1
ROWS = os.path.expanduser('~/.config/star-rows.linux.json')
HERE = os.path.dirname(os.path.abspath(__file__))


def load_rows():
    for p in (ROWS, os.path.join(HERE, 'rows.linux.json')):
        if os.path.exists(p):
            with open(p) as f:
                return json.load(f)
    return {'folders': [], 'rows': []}


# the status bar runs as a system unit (User=ubuntu) without a session's environment: systemctl --user needs this
ENV = dict(os.environ, XDG_RUNTIME_DIR=os.environ.get('XDG_RUNTIME_DIR') or '/run/user/%d' % os.getuid())


def running(row):
    if row.get('kind') == 'service':
        r = subprocess.run(['systemctl', '--user', 'is-active', row['unit']], capture_output=True, text=True, env=ENV)
        return r.stdout.strip() == 'active'
    return False


def start(row):
    subprocess.run(['systemctl', '--user', 'start', row['unit']], env=ENV)


def stop(row):
    subprocess.run(['systemctl', '--user', 'stop', row['unit']], env=ENV)


def show(row):
    if row.get('show'):
        subprocess.Popen([os.path.expandvars(a) for a in row['show']], start_new_session=True, env=ENV)


def menu_lines():
    j = load_rows()
    rows = j['rows']
    out = ['STAR (Linux) v%d' % VERSION, 'RUNNING']
    on = [r for r in rows if running(r)]
    out += ['  [R] %s' % r['name'] for r in on] or ['  none running']
    for g in j.get('folders', []):
        out.append(g)
        for r in rows:
            if r.get('group') == g:
                out.append('  %s %s' % ('✓' if r in on else ' ', r['name']))
    return out


def build_menu():
    """The star's menu as a Gtk.Menu: RUNNING first, then the folders. The VM status bar
    (vm-chromium statusbar/chromium-vm-statusbar.py) imports this file and pops it up from its star."""
    import gi
    gi.require_version('Gtk', '3.0')
    from gi.repository import Gtk, GLib
    j = load_rows()
    rows = j['rows']
    on = [r for r in rows if running(r)]
    m = Gtk.Menu()
    head = Gtk.MenuItem(label='STAR (Linux) v%d' % VERSION)
    head.set_sensitive(False)
    m.append(head)
    m.append(Gtk.SeparatorMenuItem())
    lab = Gtk.MenuItem(label='RUNNING (%d)' % len(on) if on else 'RUNNING: none')
    lab.set_sensitive(False)
    m.append(lab)

    def item(r, n):
        it = Gtk.CheckMenuItem(label='%d  %s' % (n, r['name']))
        it.set_active(r in on)
        it.set_tooltip_text(r.get('about', ''))

        def pick(*_):
            if running(r):
                show(r)
            else:
                start(r)
                GLib.timeout_add(1500, lambda: (show(r), False)[1])
        it.connect('activate', pick)
        return it

    for i, r in enumerate(rows, 1):
        if r in on:
            m.append(item(r, i))
    for g in j.get('folders', []):
        members = [(i, r) for i, r in enumerate(rows, 1) if r.get('group') == g]
        if not members:
            continue
        m.append(Gtk.SeparatorMenuItem())
        if len(members) == 1:                     # a folder holding one app shows that app directly
            m.append(item(members[0][1], members[0][0]))
            continue
        sub = Gtk.Menu()
        for i, r in members:
            sub.append(item(r, i))
        f = Gtk.MenuItem(label=g)
        f.set_submenu(sub)
        m.append(f)
    if on:
        m.append(Gtk.SeparatorMenuItem())
    for r in on:
        q = Gtk.MenuItem(label='Quit %s' % r['name'])
        q.connect('activate', lambda _i, r=r: stop(r))
        m.append(q)
    m.show_all()
    return m


if __name__ == '__main__':
    if '--print-menu' in sys.argv:
        print('\n'.join(menu_lines()))
    else:
        print('%d-star_linux-v%d' % (VERSION, VERSION))
