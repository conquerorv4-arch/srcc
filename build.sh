#!/bin/sh
echo "Compiling..."
/root/theos/bin/logos.pl Tweak.x > Tweak.m
clang -dynamiclib -fobjc-arc Tweak.m -o PubgOverlay.dylib -isysroot /root/theos/sdks/iPhoneOS16.5.sdk -framework Foundation -framework UIKit
echo "Done!"
