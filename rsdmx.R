library(tidyverse)
library(rsdmx)


#rsdmx est un package facilitant l'obtention de données via les API qui se conforment
#au standard SDMX.
#Sans prétendre pouvoir aller dans le détail technique du package, il me semble qu'en pratique
#le package permet de fournir une requête, et rsdmx se charge ensuite de formatter etc ce que renvoie
#l'API dans un format (plus ou moins) exploitable directement sur R.

# On va chercher à récupérer les comptes nationaux du UK (pour faire simple, les composantes via l'approche demande)

#L'enchaînement basique pour une requête de données correspond généralement au schema suivant :

### -> Typiquement directement sur le site ou portail en ligne. https://data-explorer.oecd.org/

#### A strictement parler, cette étape n'est pas nécessaire, et on peut se plonger directement
#### dans la liste complète des jeux de données que l'API fournit.
#### En pratique, je trouve ça plus simple de passer par le portail :
####  1) On se familiarise avec l'organisation des données, la hierarchisation des concepts...
####  2) En réalité avoir le portail ouvert sur un onglet, au moins pour les premières requêtes, peut être très utile.


# II. Identification du jeu de données nécessaire

# III. Identification de la structure (DSD) du jeu de données : nombre & ordre de dimensions.

# IV. Formulation de la "clé"("key") de la requête, permettant de filtrer le jeu de données
## selon les valeurs des dimensions.


# Via le portail (data-explorer pour l'OCDE) ------------------------------


# Avec son navigateur internet, on va sur data-explorer.oecd.org,
# et en naviguant on tombe sur le jeu de données :
## "Quarterly GDP and components - expenditure approach, national currency"
## On clique sur le bouton "developer API" et on récupère la requête.

oecd_na_url <- "https://sdmx.oecd.org/public/rest/data/OECD.SDD.NAD,DSD_NAMAIN1@DF_QNA_EXPENDITURE_NATIO_CURR,1.1/Q..AUT..........?startPeriod=2023-Q3&dimensionAtObservation=AllDimensions"
# Ici il s'agit de ce que donne la page par défaut : aucun filtre, hormis de garder uniquement les données autrichiennes.
## Bien évidemment, on peut filtrer sur le portail, et la requête sera adaptée en fonction.


## C'est une approche très simple, mais tous les portails (et leurs liens avec l'API pour R)
## ne seront pas aussi bien conçus ! Donc même si c'est très pratique, garder en tête qu'en 
## utilisant cette méthode on ne se familiarise pas avec la structure de l'API de l'institution...




# Via R ----------------------------------------------------------


##### Préambule: structure d'une requête API #### 

# Reprenons la requête récupérée sur le portail :

#"https://sdmx.oecd.org/public/rest/data/OECD.SDD.NAD,DSD_NAMAIN1@DF_QNA_EXPENDITURE_NATIO_CURR,1.1/Q..AUT..........?startPeriod=2023-Q3&dimensionAtObservation=AllDimensions"

# Ce qui nous intéresse, c'est de récupérer toute cette chaîne de caractères jusqu'au "?startPeriod"
# Schématiquement, l'url d'une requête SDMX peut se décomposer de la manière suivante :

## "https://sdmx.oecd.org/public/rest/ -> la base de l'URL de l'API; 
###  en quelque sorte le "noyau" de l'API, qui devrait a priori rester dans toutes les requêtes

## "data/" -> souvent les API séparent les données des "metadonnées" (pour nous, cela recoupe notamment les DSD = data structures et code lists).
###           on pourrait avoir "datastructure/" ou, comme dans le cas de l'OCDE, "dataflow/" si on cherche à obtenir non pas des données,
###           mais des metadonnées concernant la structure du jeu de données.

## "OECD.SDD.NAD,DSD_NAMAIN1@DF_QNA_EXPENDITURE_NATIO_CURR,1.1" : un identifiant du jeu de données.
## -> Le format varie selon les institutions.
## -> Ici on a OECD.SDD.NAD (agency productrice des données),
## puis DSD_NAMAIN1@DF_QNA_EXPENDITURE_NATIO_CURR, qui  semble renvoyer à une architecture, i.e. National Accounts (DSD_NAMAIN1) -> Qtrly Nat Accounts,GDP Expenditure Approach, in National Currency (@DF_QNA_EXPENDITURE_NATIO_CURR)
## -> Le "1.1" correspond à la version du dataflow. Elle peut, selon l'instit, apparaître derrière un "/" plutôt qu'un ",". En pratique ça ne nous concerne (quasiment) jamais, à part nous embêter parce qu'il faut la préciser selon la syntaxe précise de l'institution.

## Q..AUT.......... = la "key". Dans le format SDMX:
###   - elle apparaît toujours à la fin de la requête
###   - Elle commence (si série temporelle) par la fréquence : mensuelle, trim, annuelle... (M/Q/A...)
###   - Après chaque dimension, un "." marque la séparation avec la dimension suivante. Ne rien mettre avant le "." = accepter toutes les valeurs de cette dimension
###   - La key est très sensible : il faut qu'il y ait exactement le bon nombre de dimensions (cf DSD) ; dans le bon ordre ; avec des valeurs acceptées (c.f. codelist, ou ce que le portail vous donne comme choix).

## Après la key vient le filtrage en fonction du temps : "startPeriod=2023-Q3&dimensionAtObservation=AllDimensions" 
##  -> cette partie est optionnelle.

#### I. Exploration des données & identification du jeu de données ####


#On commence par chercher parmi les datasets :

#La construction d'une requête auprès d'une API dans 99% des cas partira d'une même URL de base.
#Celle-ci sera indiquée par l'institution, dans une rubrique "API" sur sa page.
#Ne pas hésiter à googler pour la trouver (ou encore mieux, tomber sur un post de blog etc offrant une introduction à l'API!)

endpoint = "https://sdmx.oecd.org/public/rest/"

oecd_datasets_raw <- (readSDMX("https://sdmx.oecd.org/public/rest/dataflow/all")@dataflows)

dataset_holder <- list()
for (i in 1:length(oecd_datasets_raw)){
  dataset_holder[["ids"]][[i]] = (oecd_datasets_raw[[i]]@id)
  dataset_holder[["label"]][[i]] = (oecd_datasets_raw[[i]]@Name[["en"]]) ## possibiltié de changer "en" pour "fr"
  dataset_holder[["agencyID"]][[i]] = (oecd_datasets_raw[[i]]@agencyID)
  dataset_holder[["version"]][[i]] = (oecd_datasets_raw[[i]]@version)
  
  
}


## Ces 2 lignes sont nécessaires car il y a une ligne "NULL" qui disparaît au moment du unlist()
test_label <- data.frame(label = unlist(dataset_holder$label))
dataset_holder$label[which(!dataset_holder$label %in% test_label$label)] <-NA

oecd_datasets <- data.frame(ids = unlist(dataset_holder$ids),
                           label = unlist(dataset_holder$label),
                           agencyID = unlist(dataset_holder$agency),
                           version = unlist(dataset_holder$version))

rm(oecd_datasets_raw,dataset_holder)

## On filtre en cherchant ce qui correspondrait au PIB.
oecd_datasets_filtered <- oecd_datasets |> filter(grepl("GDP", label))

## Ici récupérer la liste des datasets a été assez fastidieux, il semblerait que le formattage de l'OCDE
## ne soit pas très adapté à R. D'expérience, c'est généralement plus simple.

## On retient les éléments suivants pour notre query :
resource = "data/"
agencyID <- "OECD.SDD.NAD,"
dataflowID <- "DSD_NAMAIN1@DF_QNA_EXPENDITURE_NATIO_CURR,"
version <- "1.1/"

# Noter l'ajout des séparateurs (les "," ; "/" en fin d'élément).
# Pour le coup le seul moyen de savoir quoi/où mettre, c'est d'avoir vu une requête ou sa structure
# auparavant (soit l'institution le fournit dans ses rubriques "API", soit comme l'OCDE son portail
### inclut directement un outil pour construire ses requêtes --> on reprend le format donné)


# Identification de la structure (DSD) ------------------------------------

## On a l'identifiant du jeu de données : reste maintenant à récupérer sa structure (DSD)
## -> En particulier : quelles dimensions, dans quel ordre.
oecd_gdpq_structure <- data.frame(readSDMX("https://sdmx.oecd.org/public/rest/dataflow/OECD.SDD.NAD/DSD_NAMAIN1@DF_QNA_EXPENDITURE_NATIO_CURR/1.1?references=all")@datastructures@datastructures[[1]]@Components)

View(oecd_gdpq_structure)


# Remarque: les séries temporelles peuvent être regroupées, explicitement ou implictement dans l'architecture du fournisseur,
#           de telle manière à ce qu'elles comportent des dimensions qui ne sont en réalité pas utilisées.
## Ex : ici on voit qu'il y a les dimensions pour le secteur de référence et sa contrepartie
##      -> ce qui aurait du sens pour des transferts entre agents.
##      -> pour les composantes du PIB, la dimension "secteur de contrepartie" n'est pas pertinente.
##      -> souvent on peut se contenter d'un "wildcard" (ne rien mettre dans la clé à l'endroit de la dimension).
##      -> si on vérifie sur data-explorer, on verra que le menu déroulant n'affiche même pas cette dimension.


# Identification des codes ------------------------------------------------

#Encore une fois, ici le plus simple...
#### SI le site web de l'institution permet d'afficher la requête qui sous-tend la sélection de données
# ... est de passer par le portail sur le site, et de voir directement quelles modalités des dimensions 
# sont pertinentes, et lesquelles parmi celles-ci on souhaite retenir (et donc noter leurs codes)

# Sinon, en restant sur R :
CL_oecd_transaction <- data.frame(readSDMX("https://sdmx.oecd.org/public/rest/codelist/OECD.SDD.NAD/CL_TRANSACTION"))
# ici on testerait plusieurs manières de rechercher le PIB:
  # soit avec le mnémonique utilisé dans la compta nat (B1GQ), au sein de la colonne "id".
  # soit en cherchant dans la colonne "label.en": "GDP", ou bien "gross domestic product" (attention aux majuscules !)

CL_oecd_transaction |> filter(grepl("gross domestic product", label.en, ignore.case=TRUE))


## et ainsi de suite, on obtient tous les codes de notre clé...
# Pour les dimensions qui ne paraissent pas pertinentes, le plus simple est généralement de laisser un wildcard
# plutôt que d'essayer de retrouver la bonne modalité correspondant à "NA" etc
#   -> souvent il y en a plusieurs et on n'est pas sûr de laquelle choisir.


# Rappel : Notre requête doit avoir la structure suivante :
# "https://sdmx.oecd.org/public/rest/data/OECD.SDD.NAD,DSD_NAMAIN1@DF_QNA_EXPENDITURE_NATIO_CURR,1.1/Q..AUT..........

key <- "Q..GBR.S13+S1M..P7+P6+P51G+P3+B1GQ.....V+L.."
time_filter <- "?startPeriod=2023-Q3"
# Formulation de la requête -----------------------------------------------


# on recolle les morceaux:

request <- paste0(endpoint, resource, agencyID,dataflowID, version,key)
request
ukgdp <- data.frame(readSDMX(request))


test <- data.frame(readSDMX("https://sdmx.oecd.org/public/rest/data/OECD.SDD.NAD,DSD_NAMAIN1@DF_QNA_EXPENDITURE_NATIO_CURR/Q..GBR...P7.....L.."))
