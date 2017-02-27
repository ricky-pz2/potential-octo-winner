#/usr/bin/env bash

# Purpose of Script: This script is designed to receive an input name of file or directory and convert the file or directory contents from
#                    windows to linux format.
# Author's Name: Maria G. Hinojosa
# Affiliation: TAMIU
# Date Created: 02/25/17
# Date modified: 
# Usage notes: You need parallel and tree to run this script.


# You need parallel to run this, iconv is already a standard in ubuntu
# You need tree to run this
# sudo apt-get install parallel tree
export file_or_dir=$1

# Parallel works like a for loop, but it uses all your pc cores
# the head -n-2 removes the last two lines

if [[ -d $file_or_dir ]]; then
    parallel "echo {} && file -b {}" ::: `tree -fi $file_or_dir | head -n-2` > file_list.tmp;
else
    echo $file_or_dir > file_list.tmp && file -b $file_or_dir >> file_list.tmp;
fi

# We need to siplify the output for iconv

# -i replaces the file, the regexp reads
# "from the first space and any character thereafter to the end of the line, replace it with nothing"
sed -i 's/ .*$//g' file_list.tmp

# We need to creat a file handle to our file so we can read two lines at the time
exec 5< file_list.tmp

# Do loop to execute convertion; notice how I am using <&5 from the above file handle
# Save every odd line to var file_to_convert and all even to variable from
while read file_to_convert <&5 ; do
      read from <&5

      # The bottom commented command is used to check if the manipulations where sucessfull
      # echo $file_to_convert $from;

      # utf-8 is used, but if you want to support legacy use ASCII instead
      iconv -f $from -t utf-8 < $file_to_convert > $file_to_convert.converted.txt;
done

rm file_list.tmp;

