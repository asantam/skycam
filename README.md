# SkyCam development repository
This repository holds the code necessary to set up and operate a Raspberry-Pi based camera system for automatized capture of cloud imagery.
Currently, the setup requires an existing Raspbian installation with python3 (and python3-picamera) installed.

The current scripts are:
- [scripts/capture_local.py](scripts/capture_local.py): Main capture script.
- [scripts/skycam_startup.sh](scripts/skycam_startup.sh): Code to run at boot and setup different things.
- [scripts/update_scripts.sh](scripts/update_scripts.sh): Code for local update of scripts.

The [scripts/aux](scripts/aux) directory holds the current [crontabs](scripts/aux/crontab) and [network](scripts/aux/network) configuration scripts.

Data processing scripts will be shared on a different repository (TBD).

