#!/bin/bash

usemsg(){
	echo 'IMPORTANT!'
	echo 'Before running this script, please ensure the following:'
	echo '1. Developer Options is enabled on your device'
	echo '2. USB Debugging is enabled on your device'
	echo '3. Your device is connected via USB'
	echo '4. Target app is running and focused'
	echo '5. Ensure that /path/to/extract/to/appName exists'
	echo
	echo
	echo 'Parameters:'
	echo '-h Help menu'
	echo '-e Start extraction process. Must provide destination path'
	echo
	echo 'Use:'
	echo 'Extractor.sh -h'
	echo 'Extractor.sh -e /path/to/extract/to/appName'
}
 
apkExtraction(){
	echo 'Initiating APK extractions from device...'
	deviceApkPaths=$(adb shell pm path "$1" | sed -E 's/package://')
	while IFS= read -r line; do
		trimmedLine=$(echo "$line" | xargs | sed 's/\r$//')
		if [ "$trimmedLine" == '' ]
		then
			continue
		fi
		IFS='/' read -r -a pathSections <<< "$trimmedLine"
		apkName="${pathSections[-1]}"
		adb pull "$trimmedLine"
		mv "$apkName" "$2"
		echo "Complete."
	done <<< "$deviceApkPaths"
	echo 'Extraction complete.'
	echo 'Initiating APK decompilation...'
	localApkPaths=$(find "$2" -maxdepth 1 -name '*.apk')
	echo "$localApkPaths"
	while IFS= read -r line; do
		echo "local path: $line"
		apktool d "$line"
	done <<< "$localApkPaths"
	echo 'Decompilation complete.'
	echo "Decompiled files can be found in directory:"
        echo "$2"
}

dataExtraction(){
	abFile="$2/$1.ab"
	tarFile="$2/$1.tar"
	echo 'Creating backup of app data...'
	echo "fileName: $1"
	echo "path: $2"
	adb backup -f "$abFile" "$1"
	echo 'Backup complete.'
	echo 'Initiating data extraction...'
	dd if="$abFile" bs=1 skip=24 | python3 -c "import zlib,sys;sys.stdout.buffer.write(zlib.decompress(sys.stdin.buffer.read()))" > "$tarFile"
	tar -xf "$tarFile" -C "$2"
	rm "$abFile" -f
	rm "$tarFile" -f
	echo 'Extraction complete.'
	echo "Data files can be found in directory:"
	echo "$2"
}

initiateExtraction(){
	deviceId=$(adb devices | sed '1d' | grep -v '^[[:space:]]*$' | awk '{print $1}')
	if [ "$deviceId" == '' ]
	then
        	usemsg
        	exit 1
	fi

	deviceModel=$(adb -s "$deviceId" shell getprop ro.product.model)
	appPackage=$(adb shell dumpsys window windows | grep -E 'mCurrentFocus' | awk '{print $3}' | sed 's/\/.*//')
	if [ "$appPackage" == '' ]
	then
        	echo 'App not found.'
        	exit 1
	fi

	if [ ! -d "$1" ]
	then
        	mkdir "$1"
	fi

	echo "Target device: $deviceModel"
	echo "Targeting package: $appPackage"

	decompiledDirectory="$1/decompiled"
	if [ ! -d "$decompiledDirectory" ]
	then
        	mkdir "$decompiledDirectory"
	fi
	apkExtraction "$appPackage" "$decompiledDirectory"

	dataExtractionDirectory="$1/data"
	if [ ! -d "$dataExtractionDirectory" ]
	then
        	mkdir "$dataExtractionDirectory"
	fi
	dataExtraction "$appPackage" "$dataExtractionDirectory"
}


while getopts ":e:h" OPTION
do
	case "$OPTION" in
		h)
			usemsg
			exit 0
		;;
		e)
			initiateExtraction $2
			exit 0
		;;
		*)
			usemsg
			exit 1
		;;
	esac
done
