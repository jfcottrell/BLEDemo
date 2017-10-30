# BLEDemo

This demo uses both a Nordic nRF51 development board running a small mbed iBeacon app  
and an iOS app written in Swift. The iOS app uses both the BLE and Core Location iOS  
frameworks to communicate with the dev board.  

To flash the dev board:  

* Log on to os.mbed.com  
* New —> New Program…  
* **Platform**: Nordic nRF51-DK  
* **Template**: doesn’t really matter ([mbed OS 5] Blinky LED HelloWorld is fine)  
* **Program Name**: doesn’t matter  
* Erase _main.cpp_ in mbed compiler. Copy contents of _main.cpp_ in GitHub to main.cpp in mbed  
* Change uuid if desired  (Mac/Linux can use _uuidgen_ to generate new uuid)  
* Compile —> drag .hex file from browser’s Downloads directory to Nordic device  
* Press reset on Nordic device  
