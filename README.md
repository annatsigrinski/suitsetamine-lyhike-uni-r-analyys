# Suitsetamise ja lühikese une seose analüüs R-is

See projekt valmis Tartu Ülikooli õppetöö raames kvalitatiivsete andmete analüüsi aines. Projekti eesmärk oli uurida, kas suitsetamine on seotud lühikese unega.

## Eesmärk

Analüüsi eesmärk oli hinnata, kas suitsetajatel on suurem tõenäosus magada vähem kui 7 tundi ööpäevas ning kas see seos muutub pärast soo ja vanuserühma arvesse võtmist.

## Kasutatud tööriistad ja meetodid

- R
- dplyr
- stringr
- ggplot2
- sagedustabelid
- Fisheri täpne test
- šansside suhe
- Cochran--Mantel--Haenszeli test
- logistiline regressioon

## Analüüsi põhietapid

- andmete puhastamine ja tunnuste ümberkodeerimine
- une kestuse teisendamine arvuliseks tunnuseks
- lühikese une binaarse tunnuse loomine
- sagedustabelite koostamine
- šansside suhte hindamine
- soo ja vanuserühma võimaliku segava mõju kontrollimine
- logistilise regressioonimudeli koostamine
- tulemuste visualiseerimine

## Failid

- `analyys.R` – R-kood
- `projekt.pdf` – kirjalik projektiraport
- `dataset.csv` - projektis kasutatud andmestik

## Märkus andmestiku kohta

Repositoorium sisaldab projektis kasutatud andmestikku `dataset.csv`. Andmestik pärineb avalikust allikast, mida on viidatud projektiraportis.

Projekt valmis Tartu Ülikooli õppetöö raames ning eesmärk on näidata andmete puhastamise, tunnuste ümberkodeerimise ja statistilise analüüsi töövoogu R-is.
