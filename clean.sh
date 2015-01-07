#!/bin/bash

echo "Cleaning . . ."
make clean

echo "removing Packages"
find . -name 'Packages' -exec rm -rf {} \;

echo "removing .theos"
find . -name '.theos' -exec rm -rf {} \;

echo "All clean."
