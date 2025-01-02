# Databázy-projekt

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
