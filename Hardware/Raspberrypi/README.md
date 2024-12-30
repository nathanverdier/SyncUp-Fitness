# Config for raspberry-pi 4

## Dowload libcamera & kms++
```shell
sudo apt install -y libcamera0 libcamera-apps libcamera-dev
sudo apt install -y python3-kms++
sudo apt install python3-libcamera
```

## Camera imx477 config
```shell
# Find the line: camera_auto_detect=1, update it to:
camera_auto_detect=0
# Find the line: [all], add the following item under it:
dtoverlay=imx477
# Save and reboot.
```

##  Configure ienvironnement python
```shell
ln -s /usr/lib/python3/dist-packages/libcamera $VIRTUAL_ENV/lib/python3.11/site-packages/
ln -s /usr/lib/python3/dist-packages/pykms $VIRTUAL_ENV/lib/python3.11/site-packages/
pip install -r requirements.txt
```
