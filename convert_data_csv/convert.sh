#!/bin/bash

# title page and envirionment setup
printf "\n ########### AUTOMATIC LOG CONVERTER ###########\n\n"
DIR="$(cd "$(dirname "$0")" && pwd)"
sd_dir="$DIR/logs_sd"
raw_dir="$DIR/logs_raw"

# cleanup option for old folder
while true; do
    read -p "Do you wish to clean the old logs? --> " yn
    case $yn in
        [Yy]* ) rm "$raw_dir/"*; printf "Old logs cleaned up\n"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

printf "\n"

while true; do
    read -p "Do you wish to extract the sd logs? --> " yn
    case $yn in
        [Yy]* ) printf "\nThese are the available logs:\n";
                for entry in "$sd_dir"/*;
                do
                  find $entry -printf "%f\n"
                done;
                read -p "Write here the 4 numbers of the log you need --> " logfile;
                read -p "What is the name of the paparazzi folder? --> " foldername;
                printf "\n";
                export PAPARAZZI_HOME="$HOME/$foldername";
                cd "$HOME/$foldername/sw/logalizer" || exit;
                ./sd2log "$sd_dir/fr_$logfile.LOG" "$raw_dir";
                cd "$DIR"
                break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

printf "\n"

while true; do
    read -p "Do you wish to extract a certain message? --> " yn
    case $yn in
        [Yy]* ) read -p "What message do you want to extract from ? --> " messagename;
                python3 "$DIR/main.py" "$messagename";
                break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

printf "\nDone!"