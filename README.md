# [VirPiL](https://discord.gg/QSKkNhZrTh) - [Avionics](https://github.com/d7KrEoL/avionics/releases/download/MINOR/SW_Avionics.zip)  
Avionics for Grand Theft Auto San Andreas (SAMP)  

## General Information  
![alt text](https://github.com/d7KrEoL/avionics/blob/main/Readme/0.%20%D0%9E%D0%B1%D1%89%D0%B8%D0%B9%20%D0%B2%D0%B8%D0%B4%20-%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9.png)

The script is an attempt to implement avionics that are as close to real-world systems as possible in the game Grand Theft Auto San Andreas, considering the game's limitations and the feasibility of implementing certain systems. It was initially developed for the SAMP WARS server but can be useful for playing on other servers.

>[!NOTE]  
>Currently, the script is in open Beta testing. The information on this page may not reflect all current features and functionalities of the script if changes have not yet been updated in the documentation.

This script allows displaying basic flight parameters, auxiliary information for airplanes and helicopters, and includes:  
- A waypoint system (PPM) for flight planning and navigation assistance.  
- A landing system for any of the three international airports in San Andreas. Includes entry to glide slope, descent profile compliance, and director markers for runway centerline alignment in challenging weather conditions.  
- An autopilot system (for both airplanes and helicopters), including for flights with a vehicle attached by magnet.  
- An onboard guidance and targeting system with zooming, point fixation, coordinates retrieval, camera turning to waypoints, and the ability to create waypoints from fixation points, using visual and infrared views.  
- A threat warning system with direction determination, threat indication on ILS, mini-map, displaying the necessary information, the ability for automatic jettisoning of flares (for SAMP WARS) and automatic ejection from the aircraft when structural integrity is low.  
- A voice informant (RITA/BETTY).  
- An onboard radar system with air-to-air and air-to-ground modes, capable of highlighting air or ground targets in the radar's line of sight. It does not see through walls and objects, so it is not a cheat and can be used on most servers.  
- A datalink to view targets outside the radar's line of sight if another radar illuminates them (implemented via markers from other players; the SAMP server controls which markers to transmit to which player).  
- An onboard targeting complex displaying the necessary information for accurate targeting, capable of locking a single air target using a helmet-mounted cueing system, with the ability to lose contact when the target is blocked by obstacles. The system provides important target information that can be used in air combat, interception, or maintaining formation when flying in a group.  
- A ballistic trajectory calculator for FAB and Mk bombs (relevant for SAMP WARS bomb implementation).  
- Compatibility with the SW.AAC targeting script for sharing target coordinates with a group.  
- A damage system that allows part of the equipment to fail when the aircraft is damaged.  
- A hook/magnet for transporting empty vehicles by air.  
- Quick switching between day and night grid modes.  
- Support for the [AvionicsEditor](https://github.com/d7KrEoL/AvionicsEditor/) flight plan editor and the online editor [sampmap.ru](http://sampmap.ru).  
- Script settings menu.

---

# [Download the latest version](https://github.com/d7KrEoL/avionics/releases/latest/download/autoupdate.zip)

---

# [Script Usage Documentation (WIKI)](https://github.com/d7KrEoL/avionics/wiki)

---

## Installation

1. Install `moonloader` and `sampfuncs` for GTA.  
2. Replace the ````moonloader```` folder from the release archive into the game directory.

## Dependencies  
1. moonloader v026 and above  
   - [Download here](https://www.blast.hk/threads/13305/)  
2. sampfuncs  
   - [Download here](https://www.blast.hk/threads/17/)  
3. To use sampfuncs, the [CLEO4](https://cleo.li/download.html) library is required.  
4. imgui (included in the release archive, can also be downloaded [here](https://www.blast.hk/threads/19292/))

## System Requirements, Client Versions  
>[!NOTE]  
>You can help improve this section by sending your PC specifications and video footage of flights with the script enabled to the [Discord server](https://discord.gg/QSKkNhZrTh).

The script has been tested on SAMP versions `0.3.7-R3`, `0.3.7-R5-1`, `0.3DL`.

Recommended system requirements:  
- Intel Core i5 750 @ 2.66 GHz / AMD Phenom II X4 955 @ 3.20 GHz  
- 4GB RAM  
- ATI Radeon HD 6950 / NVIDIA GeForce GTX570 with 2GB VRAM  
- HDD Drive  

>[!NOTE]  
>The information in this section is incomplete; system requirements may be lower than the recommended ones. If you'd like to improve this section, please send your PC specifications and flight video footage with the script enabled to the [Discord server](https://discord.gg/QSKkNhZrTh).

## Commands:
- ````/swavionics```` - Open the script menu  
- ````/avionix```` - Duplicate command, same as ````/swavionics````  
- ````/swav```` - Duplicate command, same as ````/swavionics````  
- ````/setppm [waypoint number]```` - Set the current PPM (from those added to the database, automatically added via the targeting system, ````/bcomp````, or ````/addppm````)  
- ````/setwpt```` - Duplicate command, same as ````/setppm````  
- ````/swcam```` - Switch to the targeting container (camera)  
- ````/swmag```` - (For helicopters) Deploy/retire the magnet  
- ````/addwpt```` [````X````] [````Y````] [````Z````] - Add a waypoint at the given coordinates  
- ````/addppm```` - Duplicate command, same as ````/addwpt````  
- ````/clearwpt```` - Delete all waypoints  
- ````/clearppm```` - Duplicate command, same as ````/clearwpt````  
- ````/autopilot```` - Enable autopilot (the plane will automatically fly between waypoints; if a waypoint is unreachable, it will circle the current point)  
- ````/swapt```` - Duplicate command, same as ````/autopilot````  
- ````/swapto```` - Disable autopilot (can be disabled simply by taking manual control of the aircraft)  
- ````/wptcam```` - Fix the camera on the current waypoint (camera will turn to the coordinates of the waypoint)  
- ````/ppmcam```` - Duplicate of ````/wptcam````  
- ````/tarcam```` - Duplicate of ````/wptcam````  
- ````/tarwpt```` - Automatically add a waypoint from the current fixed point (where the camera is pointing in Fixed mode)  
- ````/tarppm```` - Duplicate of ````/tarwpt````  
- ````/vehwpt```` - Add a waypoint from the current location of the aircraft  
- ````/vehppm```` - Duplicate of ````/vehwpt````  
- ````/swamode```` - [````Mode number````] - Set the operational mode (````0```` - Navigation, ````1```` - BVR, ````2```` - GRD, ````3```` - LRF)  
- ````/swam```` - Duplicate of ````/swamode````  
- ````/swazoom```` [````Speed````] - Set the zoom speed for the camera ````/swcam```` on the mouse wheel (default ````100````)  
- ````/swaz```` - Duplicate of ````/swzoom````  
- ````/safp```` - Load a flight plan from a file (place in folder \nresource/avionics/flightplan)  
- ````/ldfp```` - Duplicate of ````/safp````  
- ````/savefp```` - Save the flight plan to a file (it will be stored in the folder \nresource/avionics/flightplan)  
- ````/svfp```` - Duplicate of ````/savefp````  
- Control keys: "````[````" and "````]````" can be used to switch between the previous and next waypoint, respectively (hotkeys can be changed in the ````/swavionics```` menu).  
- The "````Backspace````" key can be used to reset target lock (hotkeys can be changed in the ````/swavionics```` menu).  
- Control keys: "````1````" and "````3````" can be used to cycle through the avionics operation modes forward and backward.
