#!/bin/bash

for i in src/*; do
  echo "Processing $i"
  name=$(echo "$i" | sed -e s/.png// | sed -e 's/src\///')
  echo "... dist/$name-256.png"
  convert -resize 256 "$i" dist/"$name"-256.png
  echo "... dist/$name-64.png"
  convert -resize 64 "$i" dist/"$name"-64.png
done

for i in dist/*.png; do
  echo "Optimizing $i"
  #optipng -i1 -strip all -fix -o7 -force -out "$i" "$i"
  optipng -force -out "$i" "$i"
done
