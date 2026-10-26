#!/bin/sh
echo "Compiling..."
~/theos/bin/logos.pl Tweak.x > Tweak.m
clang -dynamiclib -fobjc-arc Tweak.m -o PubgOverlay.dylib
echo "Done!"
