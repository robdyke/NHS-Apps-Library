#! /bin/bash

PATTERN=$1


function pull_package(){

    adb pull "$(adb shell pm path $1 | awk -F':' 'NR==1{print $2}')" && mv base.apk $1.apk

}


for i in $(adb shell pm list packages |grep $PATTERN | awk -F':' '{print $2}'); do

        while true; do
        # echo -e "APP: $i"
        read -p "Do you wish to fetch $i ?" yn
        case $yn in
            [Yy]* ) pull_package $i ; break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes or no.";;
        esac
        done

done
