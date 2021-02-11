#!/usr/bin/env python3
"""
Main SkyCam capture script.
It captures and compress single or multiple images
and adds them to a daily tarfile.
"""
import bz2
import io
import os
import socket
import time
import shutil

import paramiko
import pysftp
from picamera import PiCamera


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


def sftp_upload(hostname, file_list):
    # Read host information
    host_info = sftp_read_config(hostname)
    host_addr = host_info["hostname"]
    host_user = host_info["user"]
    host_dir = host_info["directory"]
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
            with sftp.cd(host_dir):
                for f in file_list:
                    print(f"Uploading {f}...")
                    sftp.put(f)
        return 0
    except:
        return 1


def capture_images(
    output_basename,
    image_format="jpeg",
    ev_list=[0.05, 0.10, 0.50],
    width=2492,
    height=1944,
    iso=100,
    quality=100,
    bayer=False,
    meter_mode="average",
):
    """
    Main capture routine, passes most arguments to picamera
    capture options. This routine let's the camera automatically
    define exposure parameters and then lock them to obtain
    a series of images at different relative exposure values
    given by the ev_list argument.
    Returns a list of the captured images paths.
    """
    # Initialize camera
    with PiCamera(resolution=(width, height), framerate=5,) as camera:
        # Configure meter_mode and iso
        camera.meter_mode = meter_mode
        camera.iso = iso
        # Wait for the automatic gain control to settle
        time.sleep(2)
        while camera.exposure_speed == 0:
            time.sleep(0.5)
        # Now stop automatic exposure and white balance, and fix gains
        camera.exposure_mode = "off"
        exposure_speeds = [int(camera.exposure_speed * e) for e in ev_list]
        awb_gains = camera.awb_gains
        camera.awb_mode = "off"
        camera.awb_gains = awb_gains
        # Create a list of streams to capture the images.
        # To reduce the time between captures, each image is compressed
        # and written to disk after all have been captured.
        stream_list = [io.BytesIO() for i in range(len(ev_list))]
        for i, exposure_speed in enumerate(exposure_speeds):
            camera.shutter_speed = exposure_speed
            camera.capture(
                stream_list[i],
                format=image_format,
                quality=quality,
                bayer=bayer,
            )
    # Compress and write images (to ramdisk ideally).
    output_file_list = []
    for i, ev in enumerate(ev_list):
        output_file_list.append(
            "{}_{}.{}.bz2".format(
                output_basename,
                str(ev_list[i]).replace(".", "p"),
                image_format,
            )
        )
        stream_list[i].seek(0)
        with open(output_file_list[i], "wb") as f:
            f.write(
                # stream_list[i].read()
                bz2.compress(stream_list[i].read())
            )

    return output_file_list


if __name__ == "__main__":
    # Define output file options
    dir_tmp = "/dev/shm/"
    dir_out = "/home/control/data/"
    # Get information from system to name output files
    hostname = socket.gethostname()
    gmt = time.gmtime()
    timestamp = time.strftime("%Y%m%dT%H%M%S", gmt)
    date = time.strftime("%Y%m%d", gmt)
    basename = hostname + "_" + timestamp

    # Run capture routine
    files_out = capture_images(dir_tmp + basename)

    # Copy to FTP, if it fails move it to local storage
    r = sftp_upload("ftp_host", files_out)
    if r == 0:
        # If transfer succedes delete files from ramdisk
        for f in files_out:
            os.remove(f)
    else:
        # If it fails, move them to local storage for later upload
        for f in files_out:
            _ = shutil.move(f, dir_out)
