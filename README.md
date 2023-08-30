# [VirPiL](https://discord.gg/QSKkNhZrTh) - [Avionics](https://github.com/d7KrEoL/avionics/releases/download/MINOR/SW_Avionics.zip)
  Авионика для Grand Theft Auto San Andreas (SAMP)
## Общая информация
![alt text](https://github.com/d7KrEoL/avionics/blob/main/Readme/0.%20%D0%9E%D0%B1%D1%89%D0%B8%D0%B9%20%D0%B2%D0%B8%D0%B4.png?raw=true)

Скрипт является попыткой реализации авионики, которая была бы приближена к реальной в игре Grand Theft Auto San Andreas, насколько это возможно, с учётом игровых условностей и целесообразности реализации некоторых систем. Изначально разрабатывался для сервера SAMP WARS, но может быть полезен для игры на других серверах.

>[!NOTE]
>На текущий момент скрипт находится на стадии открытого Beta-тестирования. Код скрипта будет выложен в открытый доступ после завершения разработки, спустя некоторое время.

Данный скрипт позволяет выводить на экран информацию об основных параметрах полёта, вспомогательную информацию для самолётов и вертолётов, в нём реализованы:
- система ППМ (поворотных пунктов маршрута), позволяющаяя строить план полёта, облегчать навигацию; 
- система автопилота (самолётная и вертолётная), в том числе для полётов с подцепленным на магнит транспортом;
- бортовая система наведения и целеуказания с возможностью приближения, фиксации на точке, получения координат точки, поворота камеры на ППМ, создания ППМ из точки фиксации, визуальным и инфракрасным каналами обзора;
- система предупреждения об угрозе, с определением направления угрозы, индикацией угрозы на ИЛС, мини-карте, выводом основной необходимой информации, возможностью автоматического отброса ЛТЦ (для сервера SAMP WARS) и автоматического покидания самолёта при низком запасе прочности;
- речевой информатор (РИТА/BETTY);
- бортовая радиолокационная система с режимами воздух-воздух, воздух-земля, которая может подсвечивать воздушные или наземные цели, находящиеся в зоне видимости. Не видит сквозь стены и объекты, поэтому не является читом и может использоваться на большинстве серверов;
- бортовой прицельный комплекс, отображающий необходимую для точного прицеливания информацию, имеет возможность захвата одной воздушной цели с использованием нашлемного целеуказателя, с реализованной механикой потери контакта, если он скрылся за препятствием. Бортовой комплекс выводит важную информацию о цели, которая может быть использована как в воздушном бою, так и для перехвата цели, либо для удержания в строю при поётах в составе группы;
- совместимость со скриптом целеуказания SW.AAC, предназначенным для передачи координат целей группе;
- система повреждений с возможностью выхода из строя части оборудования при повреждении самолёта;
- крюк/магнит для транспортировки пустых автомобилей по воздуху;
- возможность кастомизации цветовой схемы, быстрое переключение сетки в режим День/Ночь;
- диалоговое меню настроек скрипта

# [Скачать](https://github.com/d7KrEoL/avionics/releases/download/MINOR/SW_Avionics.zip)  

## Установка

1. Установить на гта moonloader и sampfuncs
2. Скопировать с заменой папку moonloader из релизного архива в папку с игрой

## Зависимости
1. moonloader v026 и выше
   - [Можно скачать тут](https://www.blast.hk/threads/13305/)
3. sampfuncs
   - [Для версии 0.3.7-R3 можно скачать тут](https://www.blast.hk/threads/65247/)
   - [Для версии 0.3-DL можно скачать тут](https://www.blast.hk/threads/138813/)
4. socket
   - Лежит в релизном архиве, для установки нужно просто [следовать инструкции](README.md##Установка)
![SW_Avionics](https://github.com/d7KrEoL/avionics/assets/74565655/5b267a8c-40de-4ca7-af5c-d2077b8ebebd)

## Системные требования, версии клиента
>[!NOTE]
>Вы можете помочь улучшить этот раздел, прислав параметры вашего ПК и видео полётов с подключенным скриптом на [сервер Discord](https://discord.gg/QSKkNhZrTh) 

Скрипт протестирован на версиях самп 0.3.7-R3 и 0.3DL. 
Достаточной информации о системных требованиях на данный момент не собрано, параметры системы для гарантированно быстрой работы игры:

- AMD Ryzen 5 3600
- 12GB RAM
- RTX 3060 TI
- HDD Drive

Параметры системы, при которых скрипт не должен мешать быстрой работе игры:

- Intel Core i5 750 @ 2.66 GHz / AMD Phenom II X4 955 @ 3.20 GHz
- 4GB RAM
- ATI Radeon HD 6950 / NVIDIA GeForce GTX570 с 2GB VRAM 
- HDD Drive

>[!NOTE]
>Информация в данном разделе не полная, системные требования могут быть как ниже, так и выше минимальных. Вы можете помочь улучшить этот раздел, прислав параметры вашего ПК и видео полётов с подключенным скриптом на [сервер Discord](https://discord.gg/QSKkNhZrTh)

## Возможные проблемы
- При переходе в камеру Loading/не работает зум
  -- Возможное временное решение. Зайдите в папку "Инструация по установке и картинки" релизного архива, далее найдите папку "Не работает зум, вылетает в Loading", замените скрипт в игре тем что лежит в данной папке. После установки, зум будет работать медленнее чем должен.

## Команды:
- /swavionics - Открыть меню скрипта
- /setppm [номер поворотного пункта маршрута] - Установить текущий ППМ (из добавленных в базу, добавляются автоматически через систему целеуказания, /bcomp, либо /addppm)
- /setwpt - Дублирующая команда, аналогично с /setppm
- /swcam - Переход в контейнер целеуказания (камеру)
- /swmag - (Для вертолётов) Достать/убрать магнит
- /addwpt [X] [Y] [Z] - Добавить поворотный пункт маршрута по координатам
- /addppm - Дублирующая команда, аналогично /addwpt
- /autopilot - Включить автопилот (самолёт будет автоматически лететь между ППМ, если невозможно достигнуть ППМ, то кружиться вокруг текущего)
- /swapt - Дублирующая команда, аналогично /autopilot
- /swapto - Отключить автопилот (можно отключить просто перехватив управление самолётом, не вводя команду)
- /wptcam - Зафиксировать камеру на текущем ППМ (камера повернёт на координаты маршрутной точки)
- /ppmcam - Дублирует /wptcam
- /tarcam - Дублирует /wptcam
- /tarwpt - Автоматически добавить ппм из текущей зафиксированной точки (куда смотрит камера в режиме Fixed)
- /tarppm - Дублирует /tarwpt
- /vehwpt - Добавить ППМ из текущего местоположения самолёта
- /vehppm - Дублирует /vehwpt
- Клавиши управления: "[" и "]", можно использовать для переключения между предыдущим и следующим ППМ соответственно
- Клавишу "Backspace" можно использовать для сброса захвата цели

## Меню /swavionics:
Все настройки сбрасываются при перезаходе в игру.
1. Режим (День/Ночь) - меняет цвет сетки на более яркий днём и более тусклый ночью;
2. Изменить цвет сетки - задать цвет сетки вручную (возможны вылеты);

> [!WARNING]
> Возможны вылеты из игры при задании собственного цвета сетки. Если вам нужно изменить яркость, используйте стандартные режимы день/ночь 

3. Состояние скрипта (Вкл/Выкл) - возможность отключения скрипта. Включается так же через меню;
4. Автокатапультирование (Вкл/Выкл) - персонаж автоматически катапультируется из самолёта при большом уровне повреждений (парашют не выдаётся, нужно крафтить заранее);
5. Радар (Выкл/Воздух-Воздух/Воздух-Земля) - Отображать воздушную, либо наземную технику в зоне видимости (не видит сквозь стены, некоторый мелкий транспорт так же не отображает);
6. HUD (Вкл/Выкл) - Возможность отключения сетки по тангажу и крену. Индикация основных параметров сохраняется;
7. Автосброс ЛТЦ (Вкл/Выкл) - Автоматический отброс ловушек на сервере SAMP WARS, при обнаружении угрозы (возможны ложные срабатывания).


## Расшифровка надписей на ИЛС - Режим пилотирования
![alt text](https://raw.githubusercontent.com/d7KrEoL/avionics/main/Readme/1.%20%D0%98%D0%BD%D0%B4%D0%B8%D0%BA%D0%B0%D1%86%D0%B8%D1%8F%20-%20%D1%80%D0%B5%D0%B6%D0%B8%D0%BC%20%D0%BF%D0%B8%D0%BB%D0%BE%D1%82%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8F.png)

## Речевой информатор
|              РИТА           |                      BETTY                    |                                                  Расшифровка                                     |
| ----------------------------|-----------------------------------------------|--------------------------------------------------------------------------------------------------|
|         Высота опасная      |                     Altitude                  |                                       Полёт ниже 20 метров, оповещение                           |
|        Управляй вручную     |                        -                      |                                     Оповещение об отключении автопилота                          |
|        Переведи в набор     |                     Pull Up                   |                         Большая скорость снижения, предупреждение об опасности                   |
|        Увеличь обороты      |                        -                      |                                    Сваливание, предупреждение об опасности                       |
|     Ракета (направление)    |                        -                      |                          Предупреждение о пуске, необходимо принять контрмеры                    |
|  Отказ систем, смотри экран |                    Warning/-.-.               | Высокий уровень повреждений, необходим ремонт, возможен выход из строя некоторых систем самолёта |
|        Катапультируйся      | Engine fire left, engine fire right, APU fire |                       Критический уровень повреждений, рекомендуется покинуть борт               |


## Расшифровка надписей - камера контейнера целеуказания
### Визуальный режим
![alt text](https://github.com/d7KrEoL/avionics/blob/1fe9f2973ce6b7dfaadeb9f3fbc30cad482b9537/Readme/2.%20%D0%98%D0%BD%D0%B4%D0%B8%D0%BA%D0%B0%D1%86%D0%B8%D1%8F%20-%20%D1%80%D0%B5%D0%B6%D0%B8%D0%BC%20%D0%BA%D0%B0%D0%BC%D0%B5%D1%80%D1%8B.png)
### Инфракрасный режим
![alt text](https://github.com/d7KrEoL/avionics/blob/1fe9f2973ce6b7dfaadeb9f3fbc30cad482b9537/Readme/3.%20%D0%98%D0%BD%D0%B4%D0%B8%D0%BA%D0%B0%D1%86%D0%B8%D1%8F%20-%20%D0%B8%D0%BD%D1%84%D1%80%D0%B0%D0%BA%D1%80%D0%B0%D1%81%D0%BD%D1%8B%D0%B9%20%D1%80%D0%B5%D0%B6%D0%B8%D0%BC%20%D0%BA%D0%B0%D0%BC%D0%B5%D1%80%D1%8B.png)

## Принцип работы и ТТХ контейнера целеуказания /swcam:
### Тактико-технические характеристики
- Предельные углы вращения горизонтального круга: -90/+90 град;
- Предельные углы вращения вертикального круга: -90/0 град;
- Максимальное увеличение камеры: 60 ед;
- Возможность работы камеры в визуальном и инфракрасном каналах;
- Возможность фиксации цели визуально, либо по заданным координатам (ППМ).
### Принцип работы
1. Первоначально самолёт находится в режиме пилотирования (стандартная камера, стандартная индикация на ИЛС);
2. Для перехода в режим обзора и обратно необходимо ввести команду /swcam в чат;
3. При переходе из режима пилотирования в режим обзора камера переместится в нижнюю часть самолёта, индикация изменится;
4. Для вращения камеры по всем осям можно использовать мышь, для приближения - колесо мыши;
5. Переключения между визуальным и инфракрасным каналами камеры производится правой клавишей мыши (ПКМ);
6. Фиксация камеры на точке поверхности, куда на данный момент смотрит прицел производится левой клавишей мыши (ЛКМ);
7. Фиксация на координатах текущего ППМ производится командой /ppmcam;
8. Сохранение зафиксированной вручную точки как ППМ производится командой /tarppm;
9. Снятие фиксации может производится повторным нажатием ЛКМ;
10. Для принудительного снятия фиксации с точки, когда не работает основной способ, можно использовать среднюю клавишу мыши (нажать на колесо).

![IR Mode LowestSize](https://github.com/d7KrEoL/avionics/assets/74565655/83547e6b-1ba8-4a4e-8812-2b4fecab5497)


## Принцип работы и ТТХ автопилота:
- Летит к ППМ по наиболее короткой траектории, если нет необходимости огибать препятствия;
- При обнаружении препятствий пытается самостоятельно их облететь;
- Круизный эшелон берётся по высоте ППМ. Если же ППМ находится близко к уровню земли, то автопилот будет вести самолёт на минимально безопасной высоте, с учётом препятствий;
- Полёт производится на максимальных оборотах двигателя, использование форсажа задаёт пилот вручную (включив, либо отключив его);
- При достижении ППМ автоматически переходит к следующей точке маршрута по порядку, если точки закончились, то летит к 1й;
- Если достигнуть ППМ невозможно из-за препятствий, либо по другим причинам, самолёт будет кружить над текущим ППМ, пока пилот вручную его не сменит (на клавиши [ или ]);
- Для штатного отключения автопилота можно использовать команду /swapto;
- Для экстренного отключения автопилота достаточно вмешаться в управление.

>[!WARNING] 
>!Автопилот не является совершенной системой, возможны ошибки в работе при некоторых условиях, пилоту необходимо контроллировать обстановку в воздухе независимо от режима полёта!

## Принцип работы системы предупреждения об угрозе:
- Обнаруживает ракеты в зоне видимости;
- Определяет направление угрозы (откуда летит);
- Отмечает на экране угрозу маркой цели красного цвета (на самой угрозе и на 180 градусов от неё, если ракета летит сзади);
- Отмечает угрозу на мини-карте (радаре) маркой "!М!";
- Отправляет звуковое оповещение об угрозе;
- Периодически отбрасывает ЛТЦ, если включен автосброс ложных тепловых целей (на сервере SAMP WARS).

![MissilesLow](https://github.com/d7KrEoL/avionics/assets/74565655/286866c5-81f7-437f-98d9-6dd6a2d4868f)

## Режимы авионики

### Навигация
Основной режим. Используется для выполнения полётов, на данный момент используется комбинированно с режимом ближнего воздушного боя (БВБ)

### Дальний воздушный бой (ДВБ) - SAMP WARS
На данный момент не реализован

### Ближний воздушный бой (БВБ)
Предназначен для ведения воздушного боя в условиях визуальной видимости противника. В текущей версии скрипта автоматически комбинируется с режимом навигации

В данном режиме подключается нашлемная система целеуказания, позволяющая бортовому комплексу летательного аппарата (ЛА) захватить воздушную цель, находящуюся ближе всего к центру зоны видимости (центру экрана). Для сброса захвата с текущей цели необходимо нажать клавишу Backspace.
После взятия цели в захват, бортовой комплекс будет отслеживать параметры целевого ЛА и выводить их пилоту.
Захват цели сбросится, если была нажата горячая клавиша сброса захвата (Backspace), если цель скрылась за препятствием, мешающим радару ЛА увидеть данную цель, либо если ЛА противника улетел из зоны отрисовки транспортных средств.
После сброса захвата цель может быть заново взята в захват, при возврате в зону видимости.

#### Отображение информации о цели производится (рис. 4-6):
- На ИЛС, возле основных параметров полёта (над скоростью, над и под курсом, над высотой полёта в системе ISA)
- На блоке информации о цели
- Непосредственно возле цели на экране
- В точках, соответствующих конечной вектора скорости и вектора продольной оси
- На мини-карте (радаре), в виде текстовых индикаторов (Название ЛА [Высота], -[v]- для вектора скорости, -[w]- для вектора продольной оси)
![VFR01](https://github.com/d7KrEoL/avionics/blob/ffbd5a962e53a9403fccf94452e98aed58ea1867/Readme/4.%20%D0%91%D0%92%D0%91%20-%20%D0%BE%D0%B1%D1%89%D0%B0%D1%8F%20%D0%B8%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D1%8F.png)

![VFR02](https://github.com/d7KrEoL/avionics/blob/ffbd5a962e53a9403fccf94452e98aed58ea1867/Readme/5.%20%D0%91%D0%92%D0%91%20-%20%D0%BF%D0%BE%D0%B4%D1%80%D0%BE%D0%B1%D0%BD%D0%B0%D1%8F%20%D0%B8%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D1%8F.png)

![VFR03](https://github.com/d7KrEoL/avionics/blob/ffbd5a962e53a9403fccf94452e98aed58ea1867/Readme/6.%20%D0%91%D0%92%D0%91%20-%20%D0%A0%D0%B0%D0%B4%D0%B0%D1%80%20(%D0%BC%D0%B8%D0%BD%D0%B8-%D0%BA%D0%B0%D1%80%D1%82%D0%B0).png)

#### Для захвата цели необходимо
1. Перейти в режим БВБ (в версии 0.1.2 данный режим активен по умолчанию);
2. Навести камеру таким образом чтобы интересующий летательный аппарат был как можно ближе к центру экрана;
3. Проконтроллировать успешный захват нужной цели. Если в захват взята не та цель (при плохой видимости это можно отследить по радару), навести камеру таким образом чтобы нужный ЛА был ближе всех к центру экрана и сбросить захват с текущей цели клавишей Backspace
4. Для захвата новой цели можно повторить процедуру, описанную в п. 3
![avionics_targetingLow](https://github.com/d7KrEoL/avionics/assets/74565655/95c82189-fa05-4cc5-acfd-04d5aca97a28)


### Перехват целей
1. Начав разворот в сторону цели, повернуть камеру туда где предположительно должен находиться ЛА, чтобы бортовая система наведения захватила перехватываемое ВС;
2. По мини-карте, либо визуально, взять курс на вектор скорости -[v]-, либо осевой вектор -[w]- перехватываемого ЛА;
3. По возможности держать скорость и высоту большую, чем у ЛА, если цель скоростная, и высоту ниже - в противном случае;
4. При подходе к цели учитывать недопустимость перелёта цели, поэтому заранее привести высотно-скоростные параметры к необходимым для выполнения поставленного задания значениям.

![Avionics_InterceptLow](https://github.com/d7KrEoL/avionics/assets/74565655/b9039ada-8be0-499e-99a4-50fe71c79856)


