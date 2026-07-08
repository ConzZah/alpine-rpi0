# ALPINE LINUX FOR RASPBERRY PI ZERO by ConzZah

![Alpine-Logo](https://github.com/user-attachments/assets/c4e559a2-916e-4260-a663-f49fc03d3ff9)
![Raspberry-Pi-Logo](https://github.com/user-attachments/assets/2fa70502-21da-45c2-9db3-b45a7e0e4944)

**This custom image provides Alpine Linux for Raspberry Pi Zero**

### VERSION: v0.1

## what you get:

- a somewhat minimal system with essential packages pre-installed
- bash as main shell
- automatic resizing of your sdcard and generation of ssh keys on firstboot

## NOTES

**please be aware that:**

- this is in **BETA**
- i do this **because i have fun with it, i ain't getting paid bro.** if something breaks, let me know, and i'll see if i find time.


### firstboot:
**on first booting the system, it automatically generates new ssh keys and also reboots once to finish resizing your sd-card.**

**don't be alarmed, this is expected.**


### COMPATIBILITY:

**- RASPBERRY PI ZERO 2: armv7l or aarch64**

**- RASPBERRY PI ZERO 1: armhf only**


### DEFAULT KEYMAP & TIMEZONE: German

### DEFAULT SYSTEM LANGUAGE: English

### DEFAULT PASSWORD: 123
**( ^ PLS CHANGE AFTER LOGIN ^ )**


## FLASHING: use gnome-disks or dd

**MIN SDCARD SIZE: 4GB / 16GB > RECOMMENDED**

### gnome disks:
- plug in your sdcard, but don't mount it
- open gnome-disks & choose "Restore Disk Image"
- navigate to the image
- flash image to sdcard

### dd:
- plug in your sdcard, but don't mount it
- use fdisk -l to find out what drive letter it has
- then, fill in the blanks:

**xz -dkc /path/to/img.xz | sudo dd of=/dev/mmcblkX bs=512**

**================================================**

## building your own:

if you for some reason don't trust the image or want to make your own version, feel free to do so using the setup scripts.

### HOW TO:
- download bootstrap.sh and put it on a usb drive
- get the alpine stock image and flash it to your sdcard
- boot the stock image and mount your usb drive
- make sure you have a LAN cable plugged in
- execute bootstap.sh

this will then automagically:
- install the base system for u
- pull in setup.sh and put it in the root crontab
- reboot
- execute setup.sh, which will put everything else in place 

should you want to package your image, you can do so with mkalpimg.sh

If you find a bug, or have a suggestion, don't hesitate to let me know.

**THANKS TO EVERYONE WRITING SOFTWARE ON/WITH/FOR ALPINE LINUX !!**


**Cheers, ConzZah**
