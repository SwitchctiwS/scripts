#!/bin/bash

### Uniform chmod ###

# Runs chmod on all files/directories and makes them 755 or 644

function recursiveChmod {
	for arg in "$@"
	do
		if [ -d "$arg" ]; then
			chmod -v 755 "$arg"
			recursiveChmod "$arg"/*

		elif [ -f "$arg" ]; then
			chmod -v 644 "$arg"

		fi
	done
}

echo "This will recursively change permissions of ALL $# files/directories given."
echo "Type 'yes' to continue..."

read isContinue

if [ "$isContinue" == "yes" ]; then
	recursiveChmod "$@"
fi

exit

