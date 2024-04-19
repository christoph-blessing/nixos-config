#!/usr/bin/env nu
(
    ykman oath accounts list |
    rofi -dmenu -i -p Account -no-custom |
    if $in == "" { return } else { $in } |
    str trim |
    ykman oath accounts code -s $in
) | xclip -selection clipboard
