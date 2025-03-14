## Half-Life and Adrenaline training mod
 
 ![Half-Life aim training mod by teylo](https://repository-images.githubusercontent.com/526348219/fd14e64b-f785-4642-bdab-d4c3d55f0436)
______________________________________________________________

## Video
[![Watch the video](https://i.imgur.com/SQgojdb.jpg)](https://youtu.be/nYgqZ-DnQ9s)

## Installation (only for Windows)
1. Download the latest release from the [releases page](https://github.com/andreiseverin/teylo-aim-training-mod/releases)
2. Extract the contents of the archive to your server's `valve` or `ag` folder depending on your mod and build. For the 25th build, you should download the `modname-hl25-version.zip` archive. Replace the contets of the valve or ag folder with the contents of the archive as show in the video.
3. Launch the server and enjoy the plugin.

⚠️Linux players need to install it manually as in a server : `metamod` + `amxmodx`

## Usage
1. For Half-Life, type `/train` in the chat to activate the plugin or wait for the menu to show up on the first spawn.
2. For AG and AG Mini, you need to change the gamemode to `train`. Normally, it should already start in the training mode. If not, type `train` in the console.
3. Use the menu to select the training mode you want to use.

## Features
- Classic training mode with bots
- Spawn training mode with bots
- Challange mode with top 15 players
- Wallhack system
- Damage system
- Blue fade kill system
- Weaponbox system
- Freeze bots system
- Boost bots HP system

## Server installation
1. Download the latest release from the [releases page](https://github.com/andreiseverin/teylo-aim-training-mod/releases)
2. Copy the resources files to your server's `ag` or `valve` folder depending on your mod and build.
3. For Half-Life AG mini, you have to :
- Go to `valve\addons\amxmodx\configs`
- Open and edit `plugins.ini` as following: 
```
; teylo aim training mod settings

;hl_train.amxx 		; Use for Half-Life
;ag_train.amxx 		; Use for Adrenaline Gamer
hl_train_agmini.amxx	; Use for Half-Life AG Mini or AG Mod X
```
4. For AG, you have to :
- Go to `valve\addons\amxmodx\configs`
- Open and edit `plugins.ini` as following:
```
; teylo aim training mod settings
;hl_train.amxx 		; Use for Half-Life
ag_train.amxx 		; Use for Adrenaline Gamer
;hl_train_agmini.amxx	; Use for Half-Life AG Mini or AG Mod X
```
5. For Half-Life, you have to :
- Go to `valve\addons\amxmodx\configs`
- Open and edit `plugins.ini` as following:
```
; teylo aim training mod settings
hl_train.amxx 		; Use for Half-Life
;ag_train.amxx 		; Use for Adrenaline Gamer
;hl_train_agmini.amxx	; Use for Half-Life AG Mini or AG Mod X
```
6. Restart the server and enjoy the plugin.

## Credits
- [teylo](https://github.com/andreiseverin) - Plugin creator and map creator : `test_ro` and `test_ro2`
- [Noel Flantier](https://steamcommunity.com/profiles/76561197962050946/) for creating the map : `teylo_training_facility`
- [Fire](https://steamcommunity.com/id/therealfire/) for plugin testing and creating the maps : `fire_training_facility`,`fire_reflex_training` and `fire_horizontal`
- [DutchNeo](https://steamcommunity.com/id/dutchneoone/) for creating the map : `aimtrainingcenter`
- [Dr.Know](https://steamcommunity.com/id/DocKnow/) for creating the map : `ptk_aimtracking2`
- [zorba(Kemal)](https://steamcommunity.com/profiles/76561198067779539/) for constant support and help
- [SexAndOutrage](https://steamcommunity.com/profiles/76561198970820303/) for plugin testing
- [ScriptedSnark](https://steamcommunity.com/id/scriptedsnark/) for his MTBot plugin
