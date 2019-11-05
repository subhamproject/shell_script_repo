#!/bin/bash

read -p "Please enter the path you wish to create file in? : " dir_name
read -p "Please enter the file size(only numeric eg:100) you wish to create in \"${dir_name}\" path? : " file_size
read -p "Please enter the file name you wish to create \"${dir_name}\" path? : " file_name
read -p "Please confirm if you wish to create file in (GB) or in (MB),Please choose one? : " file_type
file_type=$(echo ${file_type^^}|fold -w 1|head -1)
[ -z "${file_size}" ] && echo "You haven't provided file size you wish to create" && exit 1
[ -z "${dir_name}" ] && echo "You haven't provided dir name" && exit 1
[ -z "${file_name}" ] && echo "You haven't provided file name" && exit 1
[ -z "${file_type}" ] && echo "You haven't provided file type in MB or in GB" && exit 1
[ -f ${dir_name}/${file_name} ] && rm -rf ${dir_name}/${file_name}
[ -n "${file_size}" ] && fallocate -l ${file_size}${file_type} ${dir_name}/${file_name} || echo "Please provide all the inputs"

losetup -fP ${dir_name}/${file_name}
device_name=$(losetup -a|grep ${dir_name}/${file_name} |awk -F':' '{print $1}'|head -1)

read -p "Would you like to create traditional FS or LVM,If Traditional then type (FS) if Logical volume then type (LVM)? : " answers
case $answers in
        FS|fs)
                mkfs.ext4 ${device_name} && mkdir -p $(echo ${device_name}|sed 's|/dev/||g')
                mount ${device_name} $(echo ${device_name}|sed 's|/dev/||g')
                ;;
        LVM|lvm)
                pvcreate ${device_name} && mkdir -p $(echo ${device_name}|sed 's|/dev/||g')
                vgcreate vg-$(echo ${device_name}|sed 's|/dev/||g') ${device_name}
                #lvcreate -L ${file_size}${file_type} -n lv-$(echo ${device_name}|sed 's|/dev/||g') vg-$(echo ${device_name}|sed 's|/dev/||g')
                lvcreate -L 50M -n lv-$(echo ${device_name}|sed 's|/dev/||g') vg-$(echo ${device_name}|sed 's|/dev/||g')
                mkfs.ext4 /dev/vg-$(echo ${device_name}|sed 's|/dev/||g')/lv-$(echo ${device_name}|sed 's|/dev/||g')
                mount /dev/vg-$(echo ${device_name}|sed 's|/dev/||g')/lv-$(echo ${device_name}|sed 's|/dev/||g') $(echo ${device_name}|sed 's|/dev/||g')
                ;;
esac
