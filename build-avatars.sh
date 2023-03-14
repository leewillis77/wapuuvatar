#!/bin/bash

for i in src/*; do
  echo "Processing $i"
  name=$(echo "$i" | sed -e s/.png// | sed -e 's/src\///')
  echo "... dist/$name-256.png"
  convert -resize 256x256 -gravity center -background none -extent 256x256 "$i" dist/"$name"-256.png
  echo "... dist/$name-128.png"
  convert -resize 128x128 -gravity center -background none -extent 128x128 "$i" dist/"$name"-128.png
  echo "... dist/$name-64.png"
  convert -resize 64x64 -gravity center -background none -extent 64x64 "$i" dist/"$name"-64.png
done

for i in dist/*.png; do
  echo "Optimizing $i"
  pngquant --speed=1 --force 256 --output "$i" "$i"
  zopflipng -y --lossy_8bit --lossy_transparent "$i" "$i"
done
