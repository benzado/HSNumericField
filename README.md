# HSNumericField

This is a custom input control for iOS that enables the user to edit a number using a number pad.

### Why not use a UITextField with the number pad keyboard?

The number pad only allows you to enter whole numbers. There is an undocumented decimal pad, which includes a decimal point, but then you need to set up a text field delegate to make sure the user doesn't enter multiple decimal points. And even then, you can't enter negative numbers.

## To Do

On iPad, the number pad ought to be centered in the keyboard area. Also, there should be an option for it to appear in a popover view rather than as a keyboard.

The field should intercept keyboard input. Right now it updated the text field, but not the internal data store.
