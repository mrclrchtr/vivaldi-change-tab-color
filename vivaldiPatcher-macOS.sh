#!/bin/bash
###############################################################
# Author: Grego Dadone
# License: GPL V3
###############################################################
# Script to automatically patch Vivaldi browser UI in macOS
# Last Tested on Vivaldi 2.1.1337.51 on 2018-12-07
###############################################################

parameter=$1

function isUserAskingForHelp() {
	[[ $parameter == '-h' ]] || [[ $parameter == '--help' ]]
}

function displayHelpText() {
	echo -e "Usage:"
	echo -e "  $0 [OPTION]\n"
	echo -e "Options:"
	echo -e "  [none]		Patch Vivaldi"
	echo -e "  -u, --unpatch		Unpatch Vivaldi"
	echo -e "  -c, --clean		Clean backups files"
	exit 0
}

function checkVivaldiInstalled() {
	if ! [ -d /Applications/Vivaldi.app ]; then
        echo "Could not find any Vivaldi installation"
        exit 1
	fi
}

function selectVivaldiInstallation() {
	targetDir=$(dirname "$(find /Applications/Vivaldi.app -name browser.html)")
}

function isTryingToCleanBackups() {
	[[ $parameter == '-c' ]] || [[ $parameter == '--clean' ]]
}

function cleanBackups() {
	if [ "$(ls "$targetDir/browser-"* 2> /dev/null)" ]; then
		rm "$targetDir/browser-"*
		echo "Backups cleaned successfully"
	else
		echo "No backups found. Already cleaned or never patched?"
		exit 1
	fi
	exit 0
}
function isTryingToUnpatch() {
	[[ $parameter == "-u" ]] || [[ $parameter == "--unpatch" ]]
}

function isVivaldiPatched() {
	[[ $(grep "custom.css" "$targetDir/browser.html") ]]
}

function backUpBrowserHtml() {
	cp "$targetDir/browser.html" "$targetDir/browser-$(date +%Y-%m-%dT%H-%M-%S).html"
}

function unpatchVivaldi() {
	# Restore patch lines in browser.html
    sed -i '' -e 's/  <link rel="stylesheet" href="style\/custom.css" \/><\/head>/<\/head>/' "$targetDir/browser.html"
	sed -i '' -e 's/  <script src="custom.js"><\/script>\<\/body>/<\/body>/' "$targetDir/browser.html"

	# Delete customization files if they exists
	if [ -f "$targetDir/style/custom.css" ]; then
		rm "$targetDir/style/custom.css"
	fi
	if [ -f "$targetDir/custom.js" ]; then
		rm "$targetDir/custom.js"
	fi
}

function checkModFilesPresent() {
    if ! [ -f custom.css ]; then
        echo "Could not find file 'custom.css'"
        exit 1
    fi
    if ! [ -f custom.js ]; then
        echo "Could not find file 'custom.js'"
        exit 1
    fi
}

function patchVivaldi() {
    # Copy mod files
    cp custom.css "$targetDir/style/"
    cp custom.js "$targetDir"

    # Patch browser.html
    sed -i '' -e 's/<\/head>/  <link rel="stylesheet" href="style\/custom.css" \/><\/head>/' "$targetDir/browser.html"
    sed -i '' -e 's/<\/body>/  <script src="custom.js"><\/script><\/body>/' "$targetDir/browser.html"
}


# Main Program
if isUserAskingForHelp; then
	displayHelpText
fi

checkVivaldiInstalled
selectVivaldiInstallation

if isTryingToCleanBackups; then
	cleanBackups
fi

if isTryingToUnpatch; then
	if isVivaldiPatched; then
		backUpBrowserHtml
		unpatchVivaldi
		echo "Vivaldi unpatched successfully"
	else
		echo "Vivaldi is not patched"
		exit 1
	fi
else
	if isVivaldiPatched; then
		echo "Vivaldi is already patched!"
		exit 1
	else
		checkModFilesPresent
		backUpBrowserHtml
		patchVivaldi
	    echo "Vivaldi patched successfully!"
	fi
fi
