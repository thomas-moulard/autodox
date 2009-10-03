#! /bin/sh
# Copyright (C) 2009 by Thomas Moulard, AIST, CNRS, INRIA.
# This file is part of the roboptim.
#
# roboptim is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Additional permission under section 7 of the GNU General Public
# License, version 3 ("GPLv3"):
#
# If you convey this file as part of a work that contains a
# configuration script generated by Autoconf, you may do so under
# terms of your choice.
#
# roboptim is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with roboptim.  If not, see <http://www.gnu.org/licenses/>.

##########
# README #
##########

# This shell script extracts dependencies of a Doxygen manual.
# Its input is a Doxygen configuration file (i.e. a Doxyfile file)
# and displays a list of input files used by Doxygen separated by
# a whitespace character.
# It is designed to produce a GNU make compatible dependency list.


# die(MSG)
# --------
# Print an error message and exit.
die ()
{
    echo >&2 "fatal: $1"
    exit 2
}

# getDoxygenValue(KEY, FILE)
# --------------------
# Get a value from a Doxygen configuration file (usually
# named Doxyfile). The argument is the key to retrieve
# and the name of the configuration file.
# The key value is returned by the function.
getDoxygenValue ()
{
    sed ':a; /\\$/N; s/\\\n//; ta' "$2" | grep "^$1[ =]" | cut -d'=' -f2
}


# Check arguments.
if ! test $# -eq 1; then
    die "$0 expects exactly one argument"
fi
if ! test -f "$1"; then
    die "``$1'' is not a regular file or does not exist"
fi

# Retrieve Doxygen configuration.
INPUT=`getDoxygenValue INPUT "$1"`
EXCLUDE=`getDoxygenValue EXCLUDE "$1"`
FILE_PATTERNS=`getDoxygenValue FILE_PATTERNS "$1"`

# Initialize variables.
DEPENDENCIES=

# Iterate on inputs.
for input in $INPUT; do
    # If input is a directory...
    if test -d "$input"; then
	# Build iteratively a shell command using ``find'' to
	# search for the files matching the FILE_PATTERNS pattern.
	CMD=
	for ext in $FILE_PATTERNS; do
	    CMD="$CMD -or -name '$ext'"
	done

	# Remove unwanted ``-or'' at the beginning of the command.
	CMD=`echo "$CMD" | sed 's/-or//'`
	# Build the final command.
	CMD="find $input $CMD"
	# Execute command and remove excluded files.
	DEPS=`echo $CMD | sh | grep -v "$EXCLUDE" | xargs`
	# Add results to list.
	DEPENDENCIES="$DEPENDENCIES $DEPS"

    # If input is a regular file...
    elif test -f "$input"; then
	# Add to the list.
	DEPENDENCIES="$DEPENDENCIES $INPUT"

    # Otherwise fail...
    else
	die "``$input'' is neither a directory nor a regular file."
    fi
done

# Display result.
echo "$DEPENDENCIES"
