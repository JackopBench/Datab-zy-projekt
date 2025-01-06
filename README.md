# Databázové technológie - semestrálny projekt

## 1. Úvod a popis zdrojových dát
Cieľom semestrálneho projektu je analyzovať dáta reprezentujúce predaj digitálnej hudby, ktoré zachytávajú informácie o skladbách, albumoch, interpretoch, zákazníkoch, zamestnancoch a faktúrach.
Projekt sa zameriava na sledovanie najpopulárnejšej pesničiek, interpretov a taktiež žánrov. Ťaktiež porovnáva cenové úrovne skladieb a ich predajnosť, pričom identifikuje trendy v preferenciách zákazníkov.

### Databáza Chinook pozostáva z nasledujúcich tabuliek:
* Artist - obsahuje mená interpretov
* Album - zaznamenáva informácie o albumoch a ich interpretoch
* Track - uchováva informácie o skladbách
* Genre - obsahuje rôzne hudobné žánre
* MediaType - zaznamenáva typ médií, v ktorých sú skladby uložené
* Playlist - uchováva zoznam skladieb
* PlaylistTrack - prepája skladby s playlistmi
* Customer - uchováva informácie o zákazníkoch
* Employee - obsahuje údaje o zamestnancoch
* Invoice - uchováva informácie o faktúrach vystavených zákazníkom
* InvoiceLine - obsahuje jednotlivé položky na faktúrach, teda zakúpené skladby


### ERD diagram pôvodných, zdrojových dát:

![Chinook_ERD (3)](https://github.com/user-attachments/assets/4cfcd804-1932-4987-982f-7472a1a30d80)

## 2. Multi-dimenzionálny model
Multidimenzionálny model sa používa na organizovanie a analýzu dát v dátových skladoch, pričom umožňuje zobraziť dáta z rôznych perspektív (dimenzií). Tento model je ideálny pre analýzu a reportovanie, 
pretože zjednodušuje analýzu dát, zrýchľuje dotazy a je flexibilný. Skladá sa z centrálnej tabuľky a jej dimenzií (dimenzionálne tabuľky).

Môj navrhnutý multi-dimenzionálny (hviezdicový) model sa skladá z centrálnej tabulky Fact_Sales a z nasledujúcih dimenzionálnych tabuliek:
* Dim_Artist - obsahuje mená interpretov
* Dim_Date - obsahuje informácie o dátume (rok, mesiac, deň, štvrťrok)
* Dim_Genre - obsahuje názvy žánrov
* Dim_Customer - obsahuje informácie o zákazníkoch
* Dim_Album - obsahuje názov albumu a informáciu o interpretovi, ktorému patrí
* Dim_Track - obsahuje všetky informácie o jednotlivých pesničkách

Štruktúra hviezdicového modelu je znázornená na diagrame nižšie:
![multidimenzionaly model (hviezdicovy)](https://github.com/user-attachments/assets/f092b5d3-718e-4f5d-a1e4-34e107f72e94)
