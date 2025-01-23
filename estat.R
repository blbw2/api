library(eurostat)
library(tidyverse)
library(rsdmx)

# on charge le répertoire de toutes les données eurostat accessibles via l'API

estat_toc <- get_eurostat_toc()


# on peut d'abord chercher parmi les "folder", grands ensembles de données :
## (Attention : les recherches sont sensibles aux majuscules)

estat_search_folder <- search_eurostat("national account", type = "folder")


# Plus utile : on va chercher directement un jeu de données

estat_search_na <- search_eurostat("GDP")

estat_search_na <- search_eurostat("nama" ,column = "code")

estat_gdpq <- get_eurostat(id = "namq_10_gdp") # le code est identique à celui indiqué sur le portail

## avec estat_gdpq on a récupèré un jeu de données complet (>7m de lignes)
## en pratique on va chercher à filtrer les données disponibles et en récupérer un sous-ensemble.
## pour cela, il faut spécifier les valeurs des différentes "dimensions" (temps, pays, unité, etc)



# Filtrer un jeu de données (selon ses dimensions) ------------------------


## Comment peut-on connaître...
## 1) le nombre de dimensions, et leurs noms ? 
### Ex : une observation de PIB aura a priori comme dimensions : date; pays ; composante ; corrections saisonnières ; valeur/volume..

### Réponse : 

#### soit on reste dans le package eurostat, et dans ce cas les noms de colonnes d'un data_frame obtenu via get_eurostat() correspondent aux dimensions
names(estat_gdpq) # NB: sauf le nom de la dernière colonne !

#### soit on utilise rsdmx pour retrouver la Data Structure Definition (DSD) du jeu de données.
ESTAT_structure_NAMAgdp<-data.frame(readSDMX('https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/datastructure/ESTAT/NAMQ_10_GDP')@datastructures[[1]]@Components)

## remarque sur la commande :
# la commande a l'air imposante, mais en réalité il suffit de reprendre l'URL entre guillemets
# -> remplacer ce qui est après "ESTAT/" par l'identifiant de votre jeu de données (en majuscules!)
# -> ex: remplacer NAMQ_10_GDP par NAMA_10_GDP pour avoir le PIB des comptes annuels
# -> Si vous passez par rsdmx : l'ordre des dimensions importe (fréquence.pays marche, pays.fréquence non) !
# -> La DSD liste les dimensions dans l'ordre dans lequel elles doivent apparaître dans la requête.

View(ESTAT_structure_NAMAgdp)

# On a 5 dimensions ("values" n'en est pas une, c'est juste le nom de la colonne pour les valeurs) :
# freq ; unit ; s_adj; na_item ; geo ;
# noter que la dimension temporelle ("TIME_PERIOD") est traitée à part.

#### soit on va sur le portail eurostat, sur la page du jeu de données, on affiche le menu pour filter le jeu de données ; les identifiants des dimensions seront affichés au format [id]
# -> Souvent l'option la plus simple (à mon avis, en particulier si vous dépendez de eurostat et pas de rsdmx).

## Comment peut-on connaître...
## 2) les valeurs que peuvent prendre ces dimensions (et les codes qui s'y réfèrent) ?
### Pour ça on peut soit a) se référer au portail via navigateur
###                      b) récupérer la liste complète des codes de chaque dimension
### En pratique, il est beaucoup plus simple de faire a) : les portails n'affichent que les données disponibles,
###               donc les codes qui sont réellement utilisés par le jeu de données.
###               -> on aura par ex 20 codes différents plutôt que des centaines...


gdpq_filter <- list(geo = "DE",  # attention aux codes-pays selon les institutions.... (Eurostat prend une abréviation en 2 lettres du nom du pays, parfois dans sa langue d'origine (EL = Grece) mais pas toujours (HU = Hongrie, qui n'a pas trop de rapport avec Magyarország )
                    s_adj = "SCA", #cvs-cjo (="seasonally and calendar adjusted")
                    na_item = "B1GQ", # PIB
                    unit = c("CLV_MEUR20", "CP_MEUR"), # volumes chaînés (base 2020), valeur (millions euros)
                    sinceTimePeriod = "2019-Q4",
                    untilTimePeriod = "2024-Q4")

estat_gdpq_DE <- get_eurostat(id = "namq_10_gdp",
                              filter = gdpq_filter)



# Requêtes API sans package eurostat --------------------------------------


# Pour les explications sur la structure d'une requête etc : c.f. le code ocde.R


#URL type pour une data query :
# https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/**ID DU DATASET**/**KEY**

# URL type pour une DSD :
# objet <- data.frame(readSDMX('https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/datastructure/ESTAT/**INSERER ICI l'ID DU JEU DE DONNEES**)@datastructures[[1]]@Components)

# URL type pour une codelist (honnêtement souvent plus facile à faire sur le portail..)
objet <-  data.frame(readSDMX("https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/codelist/ESTAT/DIMENSION"))