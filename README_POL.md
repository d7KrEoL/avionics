# [VirPiL](https://discord.gg/QSKkNhZrTh) - [Avionics](https://github.com/d7KrEoL/avionics/releases/download/MINOR/SW_Avionics.zip)
  Awionika dla Grand Theft Auto San Andreas (SAMP)
  
  [🇬🇧English](README.md) ☁️ [🇷🇺Русский язык](README_RUS.md) ☁️ [🇨🇿Čeština](README_CHE.md)
## Informacje ogólne
![alt text](https://github.com/d7KrEoL/avionics/blob/main/Readme/0.%20%D0%9E%D0%B1%D1%89%D0%B8%D0%B9%20%D0%B2%D0%B8%D0%B4%20-%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%B9.png)

Skrypt jest próbą implementacji awioniki, która byłaby zbliżona do rzeczywistej w grze Grand Theft Auto San Andreas, tak jak to możliwe, biorąc pod uwagę warunki gry i celowość implementacji niektórych systemów. Początkowo rozwijany był dla serwera SAMP WARS, ale może być również użyteczny na innych serwerach.

>[!NOTE]
>Obecnie skrypt znajduje się w fazie otwartych testów beta. Informacje na tej stronie mogą nie odzwierciedlać wszystkich aktualnych możliwości i cech działania skryptu, jeśli zmiany w dokumentacji nie zostały jeszcze wprowadzone.

Skrypt umożliwia wyświetlanie na ekranie informacji o podstawowych parametrach lotu, pomocniczych danych dla samolotów i helikopterów. Zawiera:
- system PPM (punktów obrotu trasy), umożliwiający budowanie planu lotu i ułatwiający nawigację;
- system lądowania na jednym z trzech międzynarodowych lotnisk San Andreas. Wejście na punkt wejścia do ślizgacza, kontrola przestrzegania profilu zniżania, wskaźniki do wyjścia na oś pasu startowego w trudnych warunkach meteorologicznych;
- system autopilota (dla samolotów i helikopterów), w tym dla lotów z transportem zawieszonym na magnesie;
- system nawigacji i wskazywania celu z możliwością powiększenia, śledzenia punktu, uzyskiwania współrzędnych punktu, obrotu kamery na PPM, tworzenia PPM z punktu ściszenia, wizualnych i podczerwonych kanałów widoku;
- system ostrzegania przed zagrożeniem, z określeniem kierunku zagrożenia, wskazywaniem zagrożenia na ILS, mini-mapce, wyświetlaniem niezbędnych informacji, możliwością automatycznego odrzutu LTC (dla serwera SAMP WARS) i automatycznego opuszczenia samolotu przy niskiej wytrzymałości;
- system głosowy (RITA/BETTY);
- system radarowy z trybami powietrze-powietrze, powietrze-ziemia, który może podświetlać cele powietrzne lub naziemne znajdujące się w zasięgu widoczności. Nie widzi przez ściany i obiekty, dlatego nie jest oszustwem i może być używane na większości serwerów;
- datalink umożliwiający widzenie celów poza zasięgiem radarów, jeśli są one oświetlane przez inny radar (realizowane przez znaczniki innych graczy, serwer SAMP samodzielnie kontroluje, które znaczniki są przekazywane do którego gracza);
- system celowniczy wyświetlający niezbędne informacje do precyzyjnego celowania, z możliwością przechwycenia jednego celu powietrznego przy użyciu wskaźnika celowania na hełmie, z mechaniką utraty kontaktu, jeśli cel ukryje się za przeszkodą. System wyświetla istotne informacje o celu, które mogą być wykorzystane zarówno w walce powietrznej, jak i do przechwycenia celu lub utrzymania formacji w trakcie lotów w grupie;
- obliczacz balistyczny trajektorii bomb FAB i Mk (aktualne dla realizacji tych bomb na SAMP WARS);
- kompatybilność ze skryptem wskazywania celu SW.AAC, przeznaczonym do przekazywania współrzędnych celów do grupy;
- system uszkodzeń z możliwością awarii części sprzętu po uszkodzeniu samolotu;
- hak/magnes do transportowania pustych pojazdów w powietrzu;
- szybkie przełączanie siatki w tryb Dzień/Noc;
- obsługa edytora planów lotu [AvionicsEditor](https://github.com/d7KrEoL/AvionicsEditor/) i edytora online [sampmap.ru](http://sampmap.ru);
- menu ustawień skryptu.

# [Pobierz aktualną wersję](https://github.com/d7KrEoL/avionics/releases/latest/download/autoupdate.zip)

# [Dokumentacja użytkowania skryptu (WIKI)](https://github.com/d7KrEoL/avionics/wiki)

## Instalacja

1. Zainstaluj na GTA `moonloader` i `sampfuncs`
2. Skopiuj folder ````moonloader```` z archiwum wydania do folderu z grą

## Zależności
1. moonloader `v.027.0-preview3` i wyższe
   - [Pobierz tutaj](https://www.blast.hk/threads/13305/page-2#post-386466)
3. sampfuncs
   - [Pobierz tutaj](https://www.blast.hk/threads/17/)
4. Do działania sampfuncs wymagana jest biblioteka [CLEO4](https://cleo.li/download.html)
5. imgui (zawarte w archiwum wydania, można pobrać również [tutaj](https://www.blast.hk/threads/19292/))

## Wymagania systemowe, wersje klienta
>[!NOTE]
>Możesz pomóc poprawić tę sekcję, przesyłając parametry swojego PC i nagrania z lotów z włączonym skryptem na [serwer Discord](https://discord.gg/QSKkNhZrTh) 

Skrypt został przetestowany na wersjach SAMP `0.3.7-R3`, `0.3.7-R5-1`, `0.3DL`. 

Zalecane wymagania systemowe:

- Intel Core i5 750 @ 2.66 GHz / AMD Phenom II X4 955 @ 3.20 GHz
- 4 GB RAM
- ATI Radeon HD 6950 / NVIDIA GeForce GTX570 z 2 GB VRAM 
- Dysk HDD

>[!NOTE]
>Informacje w tej sekcji są niepełne, wymagania systemowe mogą być niższe niż zalecane. Jeśli chcesz poprawić tę sekcję dokumentacji, wyślij parametry swojego PC i nagrania z lotów z włączonym skryptem na [serwer Discord](https://discord.gg/QSKkNhZrTh)

## Komendy:
- ````/swavionics```` - Otwórz menu skryptu
- ````/avionix```` - Podwójna komenda, działa tak samo jak ````/swavionics````
- ````/swav```` - Podwójna komenda, działa tak samo jak ````/swavionics````
- ````/setppm [numer punktu obrotu trasy]```` - Ustaw obecny PPM (z dodanych do bazy, dodawane automatycznie przez system wskazywania celu, ````/bcomp````, lub ````/addppm````)
- ````/setwpt```` - Podwójna komenda, działa tak samo jak ````/setppm````
- ````/swcam```` - Przejście do kontenera wskazywania celu (kamery)
- ````/swmag```` - (Dla helikopterów) Wydobądź/ukryj magnes
- ````/addwpt```` [````X````] [````Y````] [````Z````] - Dodaj punkt obrotu trasy według współrzędnych
- ````/addppm```` - Podwójna komenda, działa tak samo jak ````/addwpt````
- ````/clearwpt```` - Usuń wszystkie PPM
- ````/clearppm```` - Podwójna komenda, działa tak samo jak ````/clearwpt````
- ````/autopilot```` - Włącz autopilota (samolot będzie automatycznie leciał między PPM, jeśli nie da się osiągnąć PPM, będzie krążył wokół obecnego)
- ````/swapt```` - Podwójna komenda, działa tak samo jak ````/autopilot````
- ````/swapto```` - Wyłącz autopilota (można wyłączyć po prostu przejmując kontrolę nad samolotem, bez potrzeby wpisywania komendy)
- ````/wptcam```` - Zablokuj kamerę na obecnym PPM (kamera obróci się na współrzędne punktu trasy)
- ````/ppmcam```` - Dubluje ````/wptcam````
- ````/tarcam```` - Dubluje ````/wptcam````
- ````/tarwpt```` - Automatycznie dodaj PPM z obecnie zablokowanego punktu (gdzie patrzy kamera w trybie Fixed)
- ````/tarppm```` - Dubluje ````/tarwpt````
- ````/vehwpt```` - Dodaj PPM z obecnej lokalizacji samolotu
- ````/vehppm```` - Dubluje ````/vehwpt````
- ````/swamode```` - [````Numer trybu````] - Ustaw tryb pracy (````0```` - Nawigacja, ````1```` - BVB ````2```` - ZML ````3```` - DVB)
- ````/swam```` - Dubluje ````/swamode````
- ````/swazoom```` [````Prędkość````] - Ustaw prędkość przybliżenia kamery ````/swcam```` za pomocą kółka myszy (domyślnie ````100````)
- ````/swaz```` - Dubluje ````/swzoom````
- ````/safp```` - Załaduj plan lotu z pliku (umieść w folderze\nresource/avionics/flightplan)
- ````/ldfp```` - Dubluje ````/safp````
- ````/savefp```` - Zapisz plan lotu do pliku (będzie leżał w folderze\nresource/avionics/flightplan)
- ````/svfp```` - Dubluje ````/savefp````
- Klawisze sterujące: "````[````" i "````]````" można używać do przełączania między poprzednim a następnym PPM odpowiednio (klawisze skrótu można zmienić w menu ````/swavionics````)
- Klawisz "````Backspace````" można użyć do resetowania przechwycenia celu (klawisze skrótu można zmienić w menu ````/swavionics````)
- Klawisze sterujące: "````1````" i "````3````" można używać do sekwencyjnego przełączania trybu pracy awioniki w przód i w tył
