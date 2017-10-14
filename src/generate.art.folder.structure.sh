#!/bin/bash
# Create folder structure for ngs reads
#-------------------------------------------------------------------------------
for item in $(find $LUSTRE/data/ngsphy.data -maxdepth 1 -mindepth 1 -type d); do
    echo $item
    foldername=($(basename $item | tr "_" " "))
    echo ${foldername[1]}
    folder="$item/scripts/${foldername[1]}.sh"
    echo $folder
    while read -r line
    do
        myline=($(echo "$line"))
        echo ${myline[20]}
        numelems="${#myline[@]}"
        myitem="${myline[$numelems-1]}"
        newFolder=("$(dirname $myitem)")
        echo $newFolder
        mkdir -p $newFolder
    done < "$folder"
done
