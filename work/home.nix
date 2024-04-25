{ config, pkgs, ... }:

{
  imports = [ ../shared/home.nix ];

  xsession.windowManager.bspwm.monitors = {
    eDP-1 = [
      "I"
      "II"
      "III"
      "IV"
      "V"
    ];
  };

 programs.autorandr = {
   enable = true;
   hooks.postswitch.move_desktops = ''
     move_desktops() {
       source=$1
       target=$2
       bspc monitor $source --add-desktops temp
       for desktop in $(bspc query --monitor $source --desktops); do bspc desktop $desktop --to-monitor $target; done
       bspc monitor $source --remove
       bspc desktop Desktop --remove
     }

     if [ $AUTORANDR_CURRENT_PROFILE == "mobile" ]; then
       move_desktops DP-1-2 eDP-1
     elif [ $AUTORANDR_CURRENT_PROFILE == "docked" ]; then
       move_desktops eDP-1 DP-1-2
     fi
   '';
   profiles.docked = {
     fingerprint = {
       "e-DP1" = "00ffffffffffff004d101515000000000d1f0104a52215780ede50a3544c99260f505400000001010101010101010101010101010101283c80a070b023403020360050d210000018203080a070b023403020360050d210000018000000fe00445737584e804c513135364e31000000000002410332001200000a010a202000d2";
       "DP-1-2" = "00ffffffffffff0010ac2cd1564858300e200104b5502178fb19f5aa4d43aa24105054a54b00714f8140818081c081009500b300d1c0e77c70a0d0a0295030203a001d4e3100001a000000ff00445830595336330a2020202020000000fc0044454c4c205333343232445747000000fd003090e6e651010a202020202020027a020332f149020403901112131f3f2309070783010000e200d5e305c000e60605016c6c2c6d1a00000203309000076c2c6c2c5a8780a070384d40302035001d4e3100001a4ed470a0d0a0465030203a001d4e3100001a09ec00a0a0a06750302035001d4e3100001a6fc200a0a0a05550302035001d4e3100001a00000000002b701279000003013c663801066f0d9f002f801f009f05660002000900520101066f0d9f002f801f009f05540002000900555e0004ff099f002f801f009f05280002000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004e90";
     };
     config = {
       "eDP-1".enable = false;
       "DP-1-2" = {
         enable = true;
         primary = true;
         mode = "3440x1440";
         rate = "143.97";
       };
     };
   };
   profiles.mobile = {
     fingerprint = {
       "e-DP1" = "00ffffffffffff004d101515000000000d1f0104a52215780ede50a3544c99260f505400000001010101010101010101010101010101283c80a070b023403020360050d210000018203080a070b023403020360050d210000018000000fe00445737584e804c513135364e31000000000002410332001200000a010a202000d2";
     };
     config = {
       "eDP-1" = {
         enable = true;
         primary = true;
         mode = "1920x1200";
         rate = "59.95";
       };
     };
   };
 };

  home.packages = with pkgs; [
    pavucontrol
  ];
}

