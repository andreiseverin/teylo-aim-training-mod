# Half-Life and Adrenaline training mod
 
 ![Half-Life aim training mod by teylo](https://repository-images.githubusercontent.com/526348219/fd14e64b-f785-4642-bdab-d4c3d55f0436)
______________________________________________________________

The mod is currently set-up for Half-Life.

1. If you want to use it for Half-Life AG mini, you have to modify the following:
- Go to teylo aim training mod\addons\amxmodx\configs
- Open and edit plugins.ini as following:

; teylo aim training mod settings

;hl_train.amxx 		; Use for Half-Life
;ag_train.amxx 		; Use for Adrenaline Gamer
hl_train_agmini.amxx	; Use for Half-Life AG Mini or AG Mod X

- After all the modifications, copy all the folders into your valve folder


2. If you want to use it for Adrenaline Gamer, you have to modify the following:

- Go to teylo aim training mod\addons\amxmodx\configs
- Open and edit plugins.ini as following:

; teylo aim training mod settings

;hl_train.amxx 		; Use for Half-Life
ag_train.amxx 		; Use for Adrenaline Gamer
;hl_train_agmini.amxx	; Use for Half-Life AG Mini or AG Mod X

- In the main folder rename liblist.gam to liblist_hl.gam 
- Then rename liblist_ag.gam into liblist.gam
-After all the modifications, copy all the folders into your ag folder

