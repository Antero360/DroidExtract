# DroidExtract

(Oct 2024) ADVISORY: I, the creator, do not condone nor enable the malicious use of my code from here on in. All the code contained here, is STRICTLY for educational purposes. I will not be held liable for anyone that downloads this code, makes edits, and uses it for malicious intents.. That is your own doing.

DroidExtract is intended to help automate the process of mobile app penetration testing. It's main functionality is to extract the Android Package Kit (.apk), decompile it, and extract the installed directories and files from an android device for vulnerability assessment and static analysis.

## Requirements
* Python3
  - Python is needed in order to safely convert the Android Backup (.ab) file to a tarbal (.tar) file
  - Install Python3 using your distro's package manager.
* Android Debug Bridge
  - ADB is needed in order to pull the files from the device.
  - This script was intended to run on a UNIX/Linux distro suitable for Windows Subsystem for Linux (WSL). If you already have ADB installed on your Windows machine and would like to use it, create a symbolic link to the executable adb.exe by running the following command:
    - sudo ln -s /mnt/c/path/to/adb.exe /usr/bin/adb
  - If you would instead like to install ADB on WSL, install it using your distro's package manager
* ApkTool
  - ApkTool is needed in order to decompile the Android Package Kit (APK) file.
  - Install ApkTool on your WSL distro by running the following commands:
    - export apktool_version=2.3.1
    - sudo -E sh -c 'wget https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_$apktool_version.jar -O /usr/local/bin/apktool.jar'
    - sudo chmod +r /usr/local/bin/apktool.jar
    - sudo sh -c 'wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool'
    - sudo chmod +x /usr/local/bin/apktool

## Using DroidExtract
IMPORTANT!
Before running this script, please ensure the following:
- Developer Options is enabled on your device
- USB Debugging is enabled on your device
- Your device is connected via USB
- Target app is running and focused
- Ensure that /path/to/extract/to/appName exists


Parameters:
* -h Help menu
* -e Start extraction process. Must provide destination path

Use:
* Extractor.sh -h
* Extractor.sh -e /path/to/extract/to/appName

NOTE: At the point the script is ready to start the data extraction, your device will prompt you to backup your data for the target app, go ahead and hit on "Backup my data". 
