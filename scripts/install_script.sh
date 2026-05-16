#!/bin/bash
# Clone Flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
# Update Path
export PATH="$PATH:`pwd`/flutter/bin"
# Prep Flutter
flutter doctor
flutter config --enable-web
flutter pub get
