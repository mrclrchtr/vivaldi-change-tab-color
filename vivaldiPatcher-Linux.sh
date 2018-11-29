#!/bin/bash
###############################################################
# Author: Grego Dadone
# License: GPL V3
###############################################################
# Script to automatically patch Vivaldi browser UI in Linux
# Last Tested on Vivaldi 2.1.1337.51 on 2018-11-28
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
	exit 0
}

function checkRoot() {
    if [ $UID -ne 0 ]; then
        sudo $0 $parameter # Runs itself as root
        exit 0
    fi
}

function checkVivaldiInstalled() {
    vivaldiInstallations=$(find /opt -name vivaldi-bin)
    vivaldiInstallationsCount=$(echo $vivaldiInstallations | wc -w)
    if [ $vivaldiInstallationsCount -eq 0 ]; then
        echo "Could not find any Vivaldi installation"
        exit 1
    fi
}

function selectVivaldiInstallation() {
    vivaldiInstallationsFolders=($(dirname $vivaldiInstallations))
    if [ $vivaldiInstallationsCount -gt 1 ]; then
        option=0
        while [ $option -le 0 ] || [ $option -gt $vivaldiInstallationsCount ]; do 
            echo "Pick Vivaldi installation to patch"
            i=1
            for vivaldiInstallationsFolder in ${vivaldiInstallationsFolders[@]}; do
                echo "$((i++))) $vivaldiInstallationsFolder"
            done
            echo "$i) Cancel"
            read option
            # This block transforms input into an invalid option to avoid breaking the script if we enter a letter or a symbol
            if [[ $(echo $option | egrep '\b[0-9]{1,2}\b') = '' ]]; then
                option=0
            fi
            # If we choose to cancel we get in here
            if [ $option -eq $i ]; then
                exit 0
            fi
        done
        targetDir=${vivaldiInstallationsFolders[--option]} # the -- operator is to pick correct array index
    else
        targetDir=${vivaldiInstallationsFolders[0]}
    fi
}

function isTryingToUnpatch() {
	[[ $parameter == "-u" ]] || [[ $parameter == "--unpatch" ]]
}

function isVivaldiPatched() {
	[[ $(grep "custom.css" $targetDir/resources/vivaldi/browser.html) ]]
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

function backUpBrowserHtml() {
	cp $targetDir/resources/vivaldi/browser.html $targetDir/resources/vivaldi/browser-$(date +%Y-%m-%dT%H-%M-%S).html
}

function patchVivaldi() {
    # Copy mod files
    cp custom.css $targetDir/resources/vivaldi/style/
    cp custom.js $targetDir/resources/vivaldi/

    # Patch browser.html
    sed -i -e 's/<\/head>/  <link rel="stylesheet" href="style\/custom.css" \/>\n  <\/head>/' "$targetDir/resources/vivaldi/browser.html"
    sed -i -e 's/<\/body>/  <script src="custom.js"><\/script>\n  <\/body>/' "$targetDir/resources/vivaldi/browser.html"
}

function unpatchVivaldi() {
	# Remove patch lines from browser.html
	sed -i -e '/<link rel="stylesheet" href="style\/custom.css" \/>/d' "$targetDir/resources/vivaldi/browser.html"
	sed -i -e '/<script src="custom.js"><\/script>/d' "$targetDir/resources/vivaldi/browser.html"

	# Delete customization files if they exists
	if [ -f $targetDir/resources/vivaldi/style/custom.css ]; then
		rm $targetDir/resources/vivaldi/style/custom.css
	fi
	if [ -f $targetDir/resources/vivaldi/custom.js ]; then
		rm $targetDir/resources/vivaldi/custom.js
	fi
}


# Main Program
if isUserAskingForHelp; then
	displayHelpText
fi

checkRoot
checkVivaldiInstalled
selectVivaldiInstallation
if isTryingToUnpatch; then
	if isVivaldiPatched; then
		backUpBrowserHtml
		unpatchVivaldi
		echo "Vivaldi unpatched successfully"
	else
		echo "Vivaldi is not patched"
	fi
else
	if isVivaldiPatched; then
		echo "Vivaldi is already patched!"
	else
		checkModFilesPresent
		backUpBrowserHtml
		patchVivaldi
	    echo "Vivaldi patched successfully!"
	fi
fi
