# [VirPiL](https://discord.gg/QSKkNhZrTh) - [Avionics](https://github.com/d7KrEoL/avionics/releases/download/MINOR/SW_Avionics.zip)
  Авионика для Grand Theft Auto San Andreas (SAMP)
## Общая информация
![alt text](https://github.com/d7KrEoL/avionics/blob/main/Readme/0.%20%D0%9E%D0%B1%D1%89%D0%B8%D0%B9%20%D0%B2%D0%B8%D0%B4%20-%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9.png)

Скрипт является попыткой реализации авионики, которая была бы приближена к реальной в игре Grand Theft Auto San Andreas, насколько это возможно, с учётом игровых условностей и целесообразности реализации некоторых систем. Изначально разрабатывался для сервера SAMP WARS, но может быть полезен для игры на других серверах.

>[!NOTE]
>На текущий момент скрипт находится на стадии открытого Beta-тестирования. Информация на данной странице может не отражать всех актуальных возможностей и особенностей работы скрипта, если изменения в документацию ещё не успели внести.

Данный скрипт позволяет выводить на экран информацию об основных параметрах полёта, вспомогательную информацию для самолётов и вертолётов, в нём реализованы:
- система ППМ (поворотных пунктов маршрута), позволяющаяя строить план полёта, облегчать навигацию;
- система посадки на любой из трёх международных аэродромов San Andreas. Выход на точку входа в глиссаду, контроль соблюдения профиля снижения, директорные маркера для выхода на осевую ВПП в сложных метеоусловиях;
- система автопилота (самолётная и вертолётная), в том числе для полётов с подцепленным на магнит транспортом;
- бортовая система наведения и целеуказания с возможностью приближения, фиксации на точке, получения координат точки, поворота камеры на ППМ, создания ППМ из точки фиксации, визуальным и инфракрасным каналами обзора;
- система предупреждения об угрозе, с определением направления угрозы, индикацией угрозы на ИЛС, мини-карте, выводом основной необходимой информации, возможностью автоматического отброса ЛТЦ (для сервера SAMP WARS) и автоматического покидания самолёта при низком запасе прочности;
- речевой информатор (РИТА/BETTY);
- бортовая радиолокационная система с режимами воздух-воздух, воздух-земля, которая может подсвечивать воздушные или наземные цели, находящиеся в зоне видимости. Не видит сквозь стены и объекты, поэтому не является читом и может использоваться на большинстве серверов;
- даталинк, позволяющий видеть цели, находящиеся вне зоны видимости РЛС, если их подсвечивает другой радар (реализовано через маркеры других игроков, samp сервер самостоятельно контроллирует какие маркеры какому игроку передавать);
- бортовой прицельный комплекс, отображающий необходимую для точного прицеливания информацию, имеет возможность захвата одной воздушной цели с использованием нашлемного целеуказателя, с реализованной механикой потери контакта, если он скрылся за препятствием. Бортовой комплекс выводит важную информацию о цели, которая может быть использована как в воздушном бою, так и для перехвата цели, либо для удержания в строю при поётах в составе группы;
- совместимость со скриптом целеуказания SW.AAC, предназначенным для передачи координат целей группе;
- система повреждений с возможностью выхода из строя части оборудования при повреждении самолёта;
- крюк/магнит для транспортировки пустых автомобилей по воздуху;
- быстрое переключение сетки в режим День/Ночь;
- поддержка редактора планов полёта [AvionicsEditor](https://github.com/d7KrEoL/AvionicsEditor/);
- меню настроек скрипта.





# [Скачать актуальную версию](https://github.com/d7KrEoL/avionics/releases/download/0.1.5/ViRPiL_Avionics_v0.1.5-beta.3101.zip)






# [Документация по использованию скрипта (WIKI)](https://github.com/d7KrEoL/avionics/blob/main/Readme/Wiki/WIKI.md)






## Установка

1. Установить на гта ````moonloader```` и ````sampfuncs````
2. Скопировать с заменой папку ````moonloader```` из релизного архива в папку с игрой

## Зависимости
1. moonloader v026 и выше
   - [Можно скачать тут](https://www.blast.hk/threads/13305/)
3. sampfuncs
   - [Для версии 0.3.7-R3 можно скачать тут](https://www.blast.hk/threads/65247/)*
   - [Для версии 0.3-DL можно скачать тут](https://www.blast.hk/threads/138813/)
>[!NOTE]
>*Обратите внимение, версия именно [0.3.7-R3](https://getfiles.do.am/load/0-0-0-52-20), а не 0.3.7-R5, которая на данный момент является последней. Скачать нужную версию samp можно [здесь](https://getfiles.do.am/load/0-0-0-52-20).
4. imgui (лежит в релизном архиве, скачать можно так же [отсюда](https://www.blast.hk/threads/19292/))

## Системные требования, версии клиента
>[!NOTE]
>Вы можете помочь улучшить этот раздел, прислав параметры вашего ПК и видео полётов с подключенным скриптом на [сервер Discord](https://discord.gg/QSKkNhZrTh) 

Скрипт протестирован на версиях самп ````0.3.7-R3```` и ````0.3DL````. 

Рекомендуемые системные требования:

- Intel Core i5 750 @ 2.66 GHz / AMD Phenom II X4 955 @ 3.20 GHz
- 4GB RAM
- ATI Radeon HD 6950 / NVIDIA GeForce GTX570 с 2GB VRAM 
- HDD Drive

>[!NOTE]
>Информация в данном разделе не полная, системные требования могут быть ниже рекомендуемых. Если вы хотите улучшить этот раздел документации, пришлите параметры вашего ПК и видео полётов с подключенным скриптом на [сервер Discord](https://discord.gg/QSKkNhZrTh)

## Команды:
- ````/swavionics```` - Открыть меню скрипта
- ````/avionix```` - Дублирующая команда, аналогично с ````/swavionics````
- ````/swav```` - Дублирующая команда, аналогично с ````/swavionics````
- ````/setppm [номер поворотного пункта маршрута]```` - Установить текущий ППМ (из добавленных в базу, добавляются автоматически через систему целеуказания, ````/bcomp````, либо ````/addppm````)
- ````/setwpt```` - Дублирующая команда, аналогично с ````/setppm````
- ````/swcam```` - Переход в контейнер целеуказания (камеру)
- ````/swmag```` - (Для вертолётов) Достать/убрать магнит
- ````/addwpt```` [````X````] [````Y````] [````Z````] - Добавить поворотный пункт маршрута по координатам
- ````/addppm```` - Дублирующая команда, аналогично ````/addwpt````
- ````/clearwpt```` - Удалить все ППМ
- ````/clearppm```` - Дублирующая команда, аналогично ````/clearwpt````
- ````/autopilot```` - Включить автопилот (самолёт будет автоматически лететь между ППМ, если невозможно достигнуть ППМ, то кружиться вокруг текущего)
- ````/swapt```` - Дублирующая команда, аналогично ````/autopilot````
- ````/swapto```` - Отключить автопилот (можно отключить просто перехватив управление самолётом, не вводя команду)
- ````/wptcam```` - Зафиксировать камеру на текущем ППМ (камера повернёт на координаты маршрутной точки)
- ````/ppmcam```` - Дублирует ````/wptcam````
- ````/tarcam```` - Дублирует ````/wptcam````
- ````/tarwpt```` - Автоматически добавить ппм из текущей зафиксированной точки (куда смотрит камера в режиме Fixed)
- ````/tarppm```` - Дублирует ````/tarwpt````
- ````/vehwpt```` - Добавить ППМ из текущего местоположения самолёта
- ````/vehppm```` - Дублирует ````/vehwpt````
- ````/swamode```` - [````Номер режима````] - Установить режим работы (````0```` - Навигация, ````1```` - БВБ ````2```` - ЗМЛ ````3```` - ДВБ)
- ````/swam```` - Дублирует ````/swamode````
- ````/swazoom```` [````Скорость````] - Установить скорость приближения камеры ````/swcam```` на колесо мыши (по умолчанию ````100````)
- ````/swaz```` - Дублирует ````/swzoom````
- Клавиши управления: "````[````" и "````]````" можно использовать для переключения между предыдущим и следующим ППМ соответственно (горячие клавиши можно изменить в меню ````/swavionics````)
- Клавишу "````Backspace````" можно использовать для сброса захвата цели (горячие клавиши можно изменить в меню ````/swavionics````)
- Клавиши управления: "````1````" и "````3````" можно использовать для последовательного переключения режима работы авионики вперёд и назад 
