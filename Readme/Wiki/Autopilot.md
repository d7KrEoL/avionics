# Система автоматического пилотирования
[<-Оглавление](https://github.com/d7KrEoL/avionics/tree/main/Readme/Wiki/WIKI.md)

> [!NOTE]
> Данный раздел можно дополнить. Делитесь своими наблюдениями на [Discord сервере](https://discord.gg/QSKkNhZrTh) скрипта.


#### Автопилот в скрипте avionics предназначен для полёта к текущему поворотному пункту маршрута по прямолинейной траектории, на максимально доступной для этого скорости.

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

## Основная информация
|         Параметр       |             Характеристика             |
|------------------------|----------------------------------------|
| Поддержка самолётов    |                Есть                    |
| Поддержка вертолётов   |                Есть                    |
| Максимальная скорость  | Соответствует максимальной для типа ЛА |
| Огибание препятствий   |     Есть, в идеальных условиях         |
| Профиль набора         | (эшелон начала)_/````````````(ППМ) - набор за кратчайшее время, далее полёт на эшелоне, указанном в ППМ |
| Система предупреждения об опасном сближении |    Отсутствует    |
| Автопилот на перехват цели |           Отсутствует              |
| Система предупреждения об угрозе | Отброс ловушек, автопокидание - если включено в настройках |
| Система автоматического взлёта | Отсутствует (!не запускайте автопилот на земле!) |
| Система автоматической посадки | Отсутствует (отключайте автопилот заранее, при подлёте к точке входа в глиссаду |

Включение автопилота производится **только в режиме навигации**, командой ````/swapt````. Для отключения автопилота можно использовать команду ````/swapto````, либо нажать любую клавишу управления самолётом ( ````W```` ````A```` ````S```` ````D```` ````Q```` ````E```` и стрелки). 
