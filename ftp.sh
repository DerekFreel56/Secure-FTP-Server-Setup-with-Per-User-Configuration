#!/bin/bash

# Script to automate secure FTP server setup using vsftpd
# This script will:
# 1. Install vsftpd
# 2. Create specified users and set up their directories
# 3. Configure per-user FTP settings
# 4. Restrict multimedia file uploads
# 5. Restart the vsftpd service to apply changes

# Define users
USERS=("raj" "neel" "ashu" "deep")

# Install vsftpd (for CentOS)
sudo yum install -y vsftpd
sudo systemctl enable vsftpd --now

# Create users and set passwords
for user in "${USERS[@]}"; do
    sudo useradd -m -s /bin/bash "$user"
    echo "$user:Password123" | sudo chpasswd  # Change password as needed
    sudo mkdir -p /opt/$user/ftp/update
    sudo chown -R $user:$user /opt/$user/ftp
    sudo chmod 750 /opt/$user/ftp/update
    echo "$user" | sudo tee -a /etc/vsftpd/user_list

    # Create per-user config
    echo -e "local_root=/opt/$user/ftp/update\nwrite_enable=YES\nanon_upload_enable=NO\nanon_mkdir_write_enable=NO\ndeny_file={*.mp3,*.mp4,*.avi,*.mkv,*.flv,*.mov,*.wav}" | sudo tee /etc/vsftpd/user_conf/$user

done

# Configure vsftpd.conf
echo -e "userlist_enable=YES\nuserlist_file=/etc/vsftpd/user_list\nuserlist_deny=NO\nuser_config_dir=/etc/vsftpd/user_conf\ndeny_file={*.mp3,*.mp4,*.avi,*.mkv,*.flv,*.mov,*.wav}" | sudo tee -a /etc/vsftpd.conf

# Restart vsftpd service
sudo systemctl restart vsftpd

echo "FTP server setup is complete."
