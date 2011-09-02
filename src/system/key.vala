/* 
Copyright (c) 2011 by Simon Schneegans

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>. 
*/

namespace GnomePie {

/////////////////////////////////////////////////////////////////////////    
/// A class which represents a key stroke. It can be used to "press" 
/// the associated keys.
/////////////////////////////////////////////////////////////////////////

public class Key : GLib.Object {

    /////////////////////////////////////////////////////////////////////
    /// Some static members, which are often used by this class.
    /////////////////////////////////////////////////////////////////////    

    private static X.Display display;

    private static int shift_code;
    private static int ctrl_code;
    private static int alt_code;
    private static int super_code;

    /////////////////////////////////////////////////////////////////////
    /// A human readable form of the Key's accelerator.
    /////////////////////////////////////////////////////////////////////

    public string label {get; private set;}
    
    
    /////////////////////////////////////////////////////////////////////
    /// The accelerator of the Key.
    /////////////////////////////////////////////////////////////////////
    
    public string accelerator {get; private set;}
    
    
    /////////////////////////////////////////////////////////////////////
    /// Keycode and modifiers of this stroke.
    /////////////////////////////////////////////////////////////////////
    
    private int key_code;
    private Gdk.ModifierType modifiers;
    
    
    /////////////////////////////////////////////////////////////////////
    /// C'tor, initializes all members.
    /////////////////////////////////////////////////////////////////////
    
    public Key(string stroke) {
        this.accelerator = stroke;
        
        uint keysym;
        Gtk.accelerator_parse(stroke, out keysym, out this.modifiers);
        this.key_code = display.keysym_to_keycode(keysym);
        this.label = Gtk.accelerator_get_label(keysym, this.modifiers);
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Initializes static members.
    /////////////////////////////////////////////////////////////////////
    
    static construct {
        display = new X.Display();
    
        shift_code = display.keysym_to_keycode(Gdk.keyval_from_name("Shift_L"));
        ctrl_code =  display.keysym_to_keycode(Gdk.keyval_from_name("Control_L"));
        alt_code =   display.keysym_to_keycode(Gdk.keyval_from_name("Alt_L"));
        super_code = display.keysym_to_keycode(Gdk.keyval_from_name("Super_L"));
    }

    /////////////////////////////////////////////////////////////////////
    /// Simulates the pressing of the Key .
    /////////////////////////////////////////////////////////////////////

    public void press() {

        Gdk.ModifierType current_modifiers = get_modifiers();

        press_modifiers(current_modifiers, false);
        press_modifiers(this.modifiers, true);
        
        display.flush();

        X.Test.fake_key_event(this.display, this.key_code, true, 0);
        X.Test.fake_key_event(this.display, this.key_code, false, 0);

        press_modifiers(this.modifiers, false);
        press_modifiers(current_modifiers, true);

        display.flush();
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Helper method returning currently hold down modifier keys.
    /////////////////////////////////////////////////////////////////////
    
    private Gdk.ModifierType get_modifiers() {
        Gdk.ModifierType modifiers;
        Gdk.Display.get_default().get_pointer(null, null, null, out modifiers);
        return modifiers;
    }
    
    /////////////////////////////////////////////////////////////////////
    /// Helper method which 'presses' the desired modifier keys.
    /////////////////////////////////////////////////////////////////////
    
    private void press_modifiers(Gdk.ModifierType modifiers, bool down) {
        if ((modifiers & Gdk.ModifierType.CONTROL_MASK) > 0)
            X.Test.fake_key_event(this.display, this.ctrl_code, down, 0);

        if ((modifiers & Gdk.ModifierType.SHIFT_MASK) > 0)
            X.Test.fake_key_event(this.display, this.shift_code, down, 0);
            
        if ((modifiers & Gdk.ModifierType.MOD1_MASK) > 0)
            X.Test.fake_key_event(this.display, this.alt_code, down, 0);

        if ((modifiers & Gdk.ModifierType.SUPER_MASK) > 0)
            X.Test.fake_key_event(this.display, this.super_code, down, 0);
    }
}

}
