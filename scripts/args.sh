#!/bin/bash
#
# Arguments Processing Example.

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--name) name="$2"; shift ;;
        -e|--environment) environment="$2"; shift ;;
        -p|--project) project="$2"; shift ;;
        -d|--debug) debug=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "Environment   : $environment"
echo "Project       : $project"
echo "Name          : $name"
echo "Debug         : $debug"
