#!/bin/bash
# 
# Script to generate content files to test Opennop-SoloWAN
#

CONTENTDIR=$1

if [[ $# -lt 1 || $# -gt 2 ]]; then 
    echo "illegal number of parameters"
    echo "Usage: gen_content.sh <content_directory> [<filesize>]"
    exit 1
fi

if [ ! -d $1 ]; then
    echo "Directory '$1' does not exist. Create it before executing this script."
    exit 1
fi

if [ -z $2 ]; then
    file_size=20
else
    file_size=$2
fi

echo file_size=$file_size


# Generate random files
for i in {1..10}; do
    filename=$CONTENTDIR/random$i-${file_size}M.out
    echo -e "--\n-- Creating $filename file\n--"
    dd if=/dev/urandom of=$CONTENTDIR/random$i-${file_size}M.out bs=${file_size}M count=1
    chmod +r $filename
done

#
# Create highly redundant files 
#
# Variables; 2000000 = 2MB
max_size=$(($file_size * 1024 * 1024))
echo max_size=$max_size

string1="abcdefghijklmnopqrstuvwxyz 123456890n"
string2="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vestibulum, nisi in pretium lacinia, orci nisl vestibulum risus, ut venenatis magna mauris eu mi. Sed a orci vitae lacus commodo dapibus porta nec est. Sed at luctus tellus. Mauris elementum lacus vitae dictum dictum. Vestibulum in velit feugiat, venenatis lorem viverra, mattis ipsum. Fusce elementum fermentum porttitor. Cras tristique sem in massa pulvinar, volutpat viverra urna accumsan. Aliquam ultrices lectus dui, et consequat lacus tempus ut. "

for i in {1..2}; do

    filename=$CONTENTDIR/redundant$i-${file_size}M.txt
    echo -e "--\n-- Creating $filename file\n--"
    tmpfilename=$( mktemp )
 
    mystr=string$i
    echo -e ${!mystr} > $filename
 
    # Initialize the variable
    size=$(stat -c %s $filename)
 
    # Start the loop, increasing the size of the file 2x until reaching max_size
    while [ $size -lt $max_size ]; do
        cat $filename > $tmpfilename
        cat $tmpfilename >> $filename
        size=$(stat -c %s $filename)
    done
 
    # Chop off any excess
    head -c $max_size $filename > $tmpfilename
    mv $tmpfilename $filename
    chmod +r $filename

done
