# Установка скрипта и системные требования

[<-Оглавление](https://github.com/d7KrEoL/avionics/blob/main/Readme/Wiki/WIKI.md)

## Системные требования

>[!NOTE]
>Вы можете помочь улучшить этот раздел, прислав параметры вашего ПК и видео полётов с подключенным скриптом на [сервер Discord](https://discord.gg/QSKkNhZrTh) 

### Рекомендуемые системные требования:
- Intel Core i5 750 @ 2.66 GHz / AMD Phenom II X4 955 @ 3.20 GHz
- 4GB RAM
- ATI Radeon HD 6950 / NVIDIA GeForce GTX570 с 2GB VRAM 
- HDD Drive

## Требования к игре
- Установлен moonloader версии 0.26 и выше;
- Установлен клиент samp;
- Установлен sampfuncs, соответствующей вашей версии samp.

## Установка

1. Создать резервную копию важных файлов в папке с игрой
2. Установить SAMP. Оптимальная версия: 0.3.7-**_R3_**
3. Установить [SAMPFUNCS](https://www.blast.hk/threads/65247/), соответствующей вашей версии клиента samp
4. Установить [moonloader](https://www.blast.hk/threads/13305/) актуальной версии. Обязательно поставьте галочки на пунктах `ASI Loader`, `Скрипты` и `Модули`, как на этом скриншоте:

   <img width="485" height="375" alt="изображение" src="https://github.com/user-attachments/assets/5287f079-8e33-4f82-a8f6-93861ce69565" />
5. На этом этапе рекомендуется запустить самп, для проверки что всё установлено верно. Игра не должна вылетать, в файле moonloader/moonloader.log должен сохраниться лог без ошибок.

 ````
 MoonLoader v.027.0-preview3 loaded.
 Developers: FYP, hnnssy, EvgeN 1137

 Copyright (c) 2016, BlastHack Team
 http://blast.hk/moonloader/

[HH:MM:SS] (debug)	Module handle: 0x77bf0000
[HH:MM:SS] (info)	Working directory: DISK:\GTA\SA\FOLDER\moonloader
[HH:MM:SS] (debug)	FP Control: 0x0009001F
[HH:MM:SS] (debug)	Windows: 10.0.19043 2
[HH:MM:SS] (debug)	Game: GTA SA 1.0 US 'HoodLum'
[HH:MM:SS] (system)	Installing pre-game hooks...
[HH:MM:SS] (system)	Hooks installed.
[HH:MM:SS] (debug)	Opcode handler table: 0x77e3e9b8
[HH:MM:SS] (debug)	LUA_PATH = DISK:\GTA\SA\FOLDER\moonloader\libstd\?.lua;DISK:\GTA\SA\FOLDER\moonloader\libstd\?\init.lua;DISK:\GTA\SA\FOLDER\moonloader\lib\?.lua;DISK:\GTA\SA\FOLDER\moonloader\lib\?.luac;DISK:\GTA\SA\FOLDER\moonloader\lib\?\init.lua;DISK:\GTA\SA\FOLDER\moonloader\lib\?\init.luac
[HH:MM:SS] (debug)	LUA_CPATH = DISK:\GTA\SA\FOLDER\moonloader\libstd\?.dll;DISK:\GTA\SA\FOLDER\moonloader\lib\?.dll
[HH:MM:SS] (system)	Loading script "DISK:\GTA\SA\FOLDER\moonloader\AutoReboot.lua"...	(id:1)
[HH:MM:SS] (system)	ML-AutoReboot: Loaded successfully.
[HH:MM:SS] (system)	Loading script "DISK:\GTA\SA\FOLDER\moonloader\check-moonloader-updates.lua"...	(id:2)
[HH:MM:SS] (system)	Check MoonLoader Updates: Loaded successfully.
[HH:MM:SS] (system)	Loading script "DISK:\GTA\SA\FOLDER\moonloader\reload_all.lua"...	(id:3)
[HH:MM:SS] (system)	ML-ReloadAll: Loaded successfully.
````
7. Скопировать с заменой папку moonloader из релизного архива в папку с игрой

## Полезные ссылки
1. sampfuncs
   - [Для версии 0.3.7-R3 можно скачать тут](https://www.blast.hk/threads/65247/)*
   - [Для версии 0.3-DL можно скачать тут](https://www.blast.hk/threads/138813/)
2. imgui (лежит в релизном архиве, скачать можно так же [отсюда](https://www.blast.hk/threads/19292/))
