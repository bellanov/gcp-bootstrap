#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--name) name="$2"; shift ;;
        -t|--target) target="$2"; shift ;;
        -u|--uglify) uglify=1 ;;
        -s|--stuff) stuff=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "Where to deploy: $target"
echo "Name: $name"
echo "Should uglify  : $uglify"
echo "Should stuff  : $stuff"