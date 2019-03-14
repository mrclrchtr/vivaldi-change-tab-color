#!/bin/bash
###############################################################
# Author: Marcel Richter
###############################################################
# Script to automatically install patch hook
###############################################################

cd "$(dirname "$0")"

hookDir="/usr/share/libalpm/hooks"
hookFile="vivaldi-patch.hook"
installDir="/opt/vivaldi-patch"
parameter=$1

function isUserAskingForHelp() {
	[[ $parameter == '-h' ]] || [[ $parameter == '--help' ]]
}

function displayHelpText() {
	echo -e "Usage:"
	echo -e "  $0 [OPTION]\n"
	echo -e "Options:"
	echo -e "  [none]        Install in default directory (/opt/vivaldi-patch)"
	echo -e "  [DIRECTORY]   Install in DIRECTORY"
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

function isDirectorySelected() {
  [[ $1 ]]
}

function existDirectory() {
  [[ -d $1 ]]
}

function install() {
  echo "Create directory" $1
  mkdir -p $1
  echo "Copy vivaldiPatcher-Linux.sh to" $1/vivaldiPatcher-Linux.sh
  \cp ./vivaldiPatcher-Linux.sh $1/vivaldiPatcher-Linux.sh
  echo "Copy custom.css to" $1/custom.css
  \cp ./custom.css $1/custom.css
  echo "Copy custom.js to" $1/custom.js
  \cp ./custom.js $1/custom.js
  echo "Copy vivaldi-patch.hook template to" $hookDir/$hookFile
  \cp ./vivaldi-patch.hook $hookDir/$hookFile
  echo "Replace PLACEHOLDER in /etc/pacman.d/hooks/vivaldi-patch.hook with" $1/vivaldiPatcher-Linux.sh
  sed -i "s~PLACEHOLDER~$1/vivaldiPatcher-Linux.sh~g" $hookDir/$hookFile
}

# Main Program
if isUserAskingForHelp; then
	displayHelpText
fi

checkRoot
checkVivaldiInstalled

if isDirectorySelected $parameter; then
  if existDirectory $parameter; then
    echo "Selected directory still exist!"
    exit 1
  else
    installDir=$parameter
  fi
fi

echo "Install Patch to" $installDir

install $installDir
