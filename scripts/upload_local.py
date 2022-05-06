#!/usr/bin/env python3
"""
Upload local files that could not be transferred at capture time.
"""
import os
import time
from glob import glob

import paramiko
import pysftp


def sftp_callback(current, total):
    """
    Callback function for pysftp.Connection().put() to limit bandwidth use.
    Not very precise but simple.
    """
    SFTP_BUFFSIZE = 32768  # SFTP default buffer size (32 Kb)
    bandwidth_limit = 20480  # Bandwidth limit in bytes
    time.sleep(SFTP_BUFFSIZE / bandwidth_limit)


def sftp_read_config(hostname):
    """
    Read host information from ssh config file
    """
    ssh_config = paramiko.SSHConfig()
    user_config_file = os.path.expanduser("~/.ssh/sftp_config")
    if os.path.exists(user_config_file):
        with open(user_config_file) as f:
            ssh_config.parse(f)
    return ssh_config.lookup(hostname)


def sftp_upload(hostname, file_list, sub_dir=""):
    # Read host information
    host_info = sftp_read_config(hostname)
    host_addr = host_info["hostname"]
    host_user = host_info["user"]
    host_dir = host_info["directory"]
    full_dir = host_dir + "/" + sub_dir
    print(f"Uploading to {hostname}: {host_addr}")
    if "identityfile" in host_info.keys():
        host_key = host_info["identityfile"][0]
        host_config = {"username": host_user, "private_key": host_key}
    else:
        host_pass = host_info["password"]
        host_config = {"username": host_user, "password": host_pass}

    # Connect to host and upload file
    try:
        with pysftp.Connection(host_addr, **host_config) as sftp:
            try:
                # Try to access full directory
                sftp.chdir(full_dir)
            except FileNotFoundError:
                # Directory doesnt exist, we must create it
                sftp.chdir(host_dir)
                for d in sub_dir.split("/"):
                    try:
                        sftp.mkdir(d)
                    except OSError:
                        # Catch error if directory already exists
                        pass
                    try:
                        sftp.chdir(d)
                    except FileNotFoundError:
                        print(f"ERR:{hostname} can't create subdir {sub_dir}")
                        return 1
            for f in file_list:
                print(f"Uploading {f}...")
                sftp.put(f)
        return 0
    except:
        return 1


if __name__ == "__main__":
    # Define input directory
    dir_in = "/home/control/data/"
    files_in = glob(f"{dir_in}*.bz2")
    # Copy to FTP, if it fails move it to local storage
    # Upload missing files to appropiate location
    for f in files_in:
        f_date = f.split("_")[-2]
        f_date = time.strptime(f_date, "%Y%m%dT%H%M%S")
        sub_dir = time.strftime("%Y/%m/%d", f_date)
        r = sftp_upload("ftp_host", [f], sub_dir=sub_dir)
        if r == 0:
            # If transfer succedes delete files from ramdisk
            print("Upload Ok. Removing local files...")
            os.remove(f)
