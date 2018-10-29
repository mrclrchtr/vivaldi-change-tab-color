# Vivaldi Simple UI
A more simple and comfortable UI layout for Vivaldi browser.

![Screenshot](https://raw.githubusercontent.com/gregodadone/vivaldi-simple-ui/master/Screenshot_20181029_080255.png "Vivaldi Simple UI")

### Elements order
1. Home Button
2. Back Button
3. Forward Button
4. Address Bar
5. Reload Button
6. Search Bar
7. Extensions Wrapper

### How to install
#### Automatically (Linux only)
If you are in Linux, you can clone this repo and run *vivaldiPatcher-Linux.sh*
```
./vivaldiPatcher-Linux.sh
```
#### Manually
Just go to *VIVALDI_INSTALLATION_FOLDER/resources/vivaldi/*, copy *custom.css* and *custom.js* into the folder. Make a backup of *browser.html* and then edit it.
* Inside the head element add
```
<link rel="stylesheet" href="custom.css" />
```
* Inside the body element add
```
<script src="custom.js"></script>
```
* Save the file and you are done!
