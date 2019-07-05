#!/bin/bash
sudo apt-get update && sudo apt-get install ntp -y
[ $? -eq 0 ] && sudo systemctl start ntp && sudo systemctl enable ntp
echo -e "$(sudo crontab -u root -l)\n*/5 * * * *  ntpq -p >> /dev/null" | sudo crontab -u root -
[ $? -eq 0 ] && exit 0
