#!/bin/bash

sudo grub2-mkconfig -o /boot/grub2/grub.cfg >/dev/null 2>&1
echo "List of available kernels:"
sudo grep -P "submenu|^menuentry" /boot/grub2/grub.cfg | cut -d "'" -f2

echo -e "\n\nNow choose new default kernel using:\ngrub2-set-default \"<submenu title><menu entry title>\""
