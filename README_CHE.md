# [VirPiL](https://discord.gg/QSKkNhZrTh) - [Avionics](https://github.com/d7KrEoL/avionics/releases/download/MINOR/SW_Avionics.zip)
  Avionika pro Grand Theft Auto San Andreas (SAMP)
  
  [🇬🇧English](README.md) ☁️ [🇷🇺Ruština](README_RUS.md) ☁️ [🇵🇱Polština](README_POL.md)
## Obecné informace
![alt text](https://github.com/d7KrEoL/avionics/blob/main/Readme/0.%20%D0%9E%D0%B1%D1%89%D0%B8%D0%B9%20%D0%B2%D0%B8%D0%B4%20-%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9.png)

Tento skript je pokusem o implementaci avioniky, která by byla co nejblíže skutečné v Grand Theft Auto San Andreas, jak je to možné, s ohledem na herní podmínky a realizovatelnost některých systémů. Původně byl vyvinut pro server SAMP WARS, ale může být užitečný i na jiných serverech.

>[!NOTE]
>Aktuálně se skript nachází v otevřené fázi beta testování. Informace na této stránce nemusí odrážet všechny aktuální možnosti a funkce skriptu, pokud změny v dokumentaci ještě nebyly provedeny.

Tento skript umožňuje zobrazit na obrazovce informace o hlavních parametrech letu, pomocné informace pro letadla a vrtulníky. Implementováno je:
- systém PPM (bodů obratu trasy), který umožňuje vytvářet plán letu a usnadňuje navigaci;
- systém přistání na některém ze tří mezinárodních letišť v San Andreas. Výstup na bod vstupu do glisády, kontrola dodržování profilu sestupu, směrnice pro výstup na osovou RWY v složitých meteorologických podmínkách;
- autopilotní systém (letadlový i vrtulníkový), včetně pro lety s magnetickým uchopením transportu;
- palubní naváděcí a cílovací systém s možností přiblížení, zaměření bodu, získání souřadnic bodu, otočení kamery na PPM, vytváření PPM z bodu zaměření, vizuálními a infračervenými kanály;
- systém varování před hrozbou, s určením směru hrozby, indikací hrozby na ILS, mini-mapě, zobrazením nezbytných informací, možností automatického odhození LTC (pro server SAMP WARS) a automatickým opuštěním letadla při nízké odolnosti;
- hlasový informátor (RITA/BETTY);
- radarový systém s režimy vzduch-vzduch, vzduch-země, který může osvětlit vzdušné nebo pozemní cíle v zóně viditelnosti. Nevidí skrz stěny a objekty, proto to není cheat a může být použito na většině serverů;
- datalink umožňující vidět cíle, které jsou mimo zónu viditelnosti radaru, pokud je osvětlí jiný radar (realizováno přes značky jiných hráčů, server SAMP kontroluje, které značky předá kterému hráči);
- palubní zaměřovací systém, který zobrazuje potřebné informace pro přesné zaměření, má možnost zachycení jednoho vzdušného cíle pomocí náhlavního zaměřovače, s implementovanou mechanikou ztráty kontaktu, pokud se cíl schová za překážku. Palubní systém zobrazuje důležité informace o cíli, které mohou být použity jak v leteckém boji, tak pro zachycení cíle nebo pro udržení formace při letu ve skupině;
- balistický výpočet trajektorie bomb FAB a Mk (aktuální pro SAMP WARS implementace těchto bomb);
- kompatibilita se skriptem navádění cílů SW.AAC, určeným pro předávání souřadnic cílů do skupiny;
- systém poškození s možností výpadku části vybavení při poškození letadla;
- hák/magnet pro přepravu prázdných vozidel vzduchem;
- rychlé přepínání mřížky mezi režimem Den/Noc;
- podpora editoru plánů letů [AvionicsEditor](https://github.com/d7KrEoL/AvionicsEditor/) a online editoru [sampmap.ru](http://sampmap.ru);
- menu nastavení skriptu.

# [Stáhněte aktuální verzi](https://github.com/d7KrEoL/avionics/releases/latest/download/autoupdate.zip)

# [Dokumentace k používání skriptu (WIKI)](https://github.com/d7KrEoL/avionics/wiki)

## Instalace

1. Nainstalujte do GTA `moonloader` a `sampfuncs`
2. Zkopírujte složku ````moonloader```` z archivovaného vydání do složky s hrou

## Závislosti
1. moonloader `v.027.0-preview3` a vyšší
   - [Stáhněte zde](https://www.blast.hk/threads/13305/page-2#post-386466)
3. sampfuncs
   - [Stáhněte zde](https://www.blast.hk/threads/17/)
4. Pro správnou funkci sampfuncs je potřeba knihovna [CLEO4](https://cleo.li/download.html)
5. imgui (součástí archivovaného vydání, lze stáhnout také [zde](https://www.blast.hk/threads/19292/))

## Systémové požadavky, verze klienta
>[!NOTE]
>Pomozte vylepšit tuto sekci, pošlete parametry vašeho PC a video letů s nainstalovaným skriptem na [Discord server](https://discord.gg/QSKkNhZrTh) 

Skript byl testován na verzích SAMP `0.3.7-R3`, `0.3.7-R5-1`, `0.3DL`. 

Doporučené systémové požadavky:

- Intel Core i5 750 @ 2.66 GHz / AMD Phenom II X4 955 @ 3.20 GHz
- 4 GB RAM
- ATI Radeon HD 6950 / NVIDIA GeForce GTX570 s 2 GB VRAM 
- HDD

>[!NOTE]
>Informace v této sekci nejsou úplné, systémové požadavky mohou být nižší než doporučené. Pokud chcete vylepšit tuto sekci dokumentace, pošlete parametry vašeho PC a video letů s nainstalovaným skriptem na [Discord server](https://discord.gg/QSKkNhZrTh)

## Příkazy:
- ````/swavionics```` - Otevřít menu skriptu
- ````/avionix```` - Duplicitní příkaz, stejně jako ````/swavionics````
- ````/swav```` - Duplicitní příkaz, stejně jako ````/swavionics````
- ````/setppm [číslo bodu obratu trasy]```` - Nastavit aktuální PPM (z přidaných do databáze, automaticky přidáno přes systém navádění cíle, ````/bcomp````, nebo ````/addppm````)
- ````/setwpt```` - Duplicitní příkaz, stejně jako ````/setppm````
- ````/swcam```` - Přechod do kontejneru navádění cíle (kamery)
- ````/swmag```` - (Pro vrtulníky) Vytáhnout/skryt magnet
- ````/addwpt```` [````X````] [````Y````] [````Z````] - Přidat bod obratu trasy podle souřadnic
- ````/addppm```` - Duplicitní příkaz, stejně jako ````/addwpt````
- ````/clearwpt```` - Odstranit všechny PPM
- ````/clearppm```` - Duplicitní příkaz, stejně jako ````/clearwpt````
- ````/autopilot```` - Zapnout autopilota (letadlo bude automaticky letět mezi PPM, pokud není možné dosáhnout PPM, bude kroužit kolem aktuálního)
- ````/swapt```` - Duplicitní příkaz, stejně jako ````/autopilot````
- ````/swapto```` - Vypnout autopilota (lze vypnout jednoduše převzetím řízení letadla, bez nutnosti zadávat příkaz)
- ````/wptcam```` - Uzamknout kameru na aktuálním PPM (kamera se otočí na souřadnice bodu trasy)
- ````/ppmcam```` - Dubluje ````/wptcam````
- ````/tarcam```` - Dubluje ````/wptcam````
- ````/tarwpt```` - Automaticky přidat PPM z aktuální zaměřené bodu (kam kamera směřuje v režimu Fixed)
- ````/tarppm```` - Dubluje ````/tarwpt````
- ````/vehwpt```` - Přidat PPM z aktuální pozice letadla
- ````/vehppm```` - Dubluje ````/vehwpt````
- ````/swamode```` - [````Číslo režimu````] - Nastavit režim práce (````0```` - Navigace, ````1```` - BVB ````2```` - ZML ````3```` - DVB)
- ````/swam```` - Dubluje ````/swamode````
- ````/swazoom```` [````Rychlost````] - Nastavit rychlost přiblížení kamery ````/swcam```` na kole myši (výchozí hodnotou je ````100````)
- ````/swaz```` - Dubluje ````/swzoom````
- ````/safp```` - Načíst plán letu ze souboru (uložit do složky\nresource/avionics/flightplan)
- ````/ldfp```` - Dubluje ````/safp````
- ````/savefp```` - Uložit plán letu do souboru (bude uložen do složky\nresource/avionics/flightplan)
- ````/svfp```` - Dubluje ````/savefp````
- Ovládací klávesy: "````[````" a "````]````" lze použít pro přepínání mezi předchozím a následujícím PPM, klávesy lze změnit v menu ````/swavionics````)
- Klávesu "````Backspace````" lze použít pro resetování zachycení cíle (klávesy lze změnit v menu ````/swavionics````)
- Ovládací klávesy: "````1````" a "````3````" lze použít pro sekvenční přepínání režimu práce avioniky vpřed a vzad
