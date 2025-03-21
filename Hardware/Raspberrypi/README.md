# Config for raspberry-pi 4

## Dowload libcamera & kms++
```shell
sudo apt install -y libcamera0 libcamera-apps libcamera-dev
```

## Camera imx477 config
```shell
vim /boot/firmware/config.txt
# Find the line: camera_auto_detect=1, update it to:
camera_auto_detect=0
# Find the line: [all], add the following item under it:
dtoverlay=imx477
# Save and reboot.
```

##  Configure environnement python
```shell
sudo apt-get install libcap-dev
pip install -r requirements.txt
export LD_LIBRARY_PATH=/usr/lib/arm-linux-gnueabihf:$LD_LIBRARY_PATH
export PYTHONPATH=/usr/lib/python3/dist-packages:$PYTHONPATH
```
## Lancer server flask
```shell
python3 serverFlask.py
```
