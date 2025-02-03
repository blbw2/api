library(tidyverse)
library(jsonlite)
library(restatis)

# Username: DEZUGR5871
# Password: OfceDestat23


# Package restatis --------------------------------------------------------

## NB : il faut créer un compte genesis pour utiliser l'API.

## Une fois que c'est fait, la fonction suivante permet de stocker ses identifiants.
restatis::gen_auth_save(database = "genesis")

## On peut utiliser les fonctions de restatis pour chercher un jeu de données.
## On va créer une list avec les résultats de la recherche pour un terme dans les données Destatis.
## C'est une manière d'arriver à trouver le code identifiant un jeu de données qu'on pourra ensuite récupérer.
## La fonction gen_find() permet de faire cela.
search_results <- gen_find(term = "Produktivität",
                           detailed = FALSE,
                           ordering = TRUE,
                           category = "all",
                           database = "genesis")

## Destatis est organisé en "Tables" et en "Cubes".
## Les "Tables" regroupent des séries (et son eux-mêmes groupés de manière thématique, par ex Compta anat)
## Les "Cubes" correspondent à des séries.

## Au sein de l'objet search_results créé par notre recherche,
## c'est surtout ce qui est contenu dans "Cubes"
## qui va nous intéresser. On y retrouve en effet un tableau listant les codes et les noms
## des jeux de données dont le nom contient le terme fourni à gen_find().


## Mon appréciation perso : si tu es familière des noms de variables, concepts etc en allemand,
## et en particulier sur la nomenclature de Destatis, vu que les recherches sont sensibles à la formulation exacte.
### --> Recherches directes sur l'API via gen_find().

## Sinon, on peut chercher les séries sur https://www-genesis.destatis.de/datenbank/online
## en exploitant l'arborescence etc et le fait que tout soit en anglais.
### Une fois qu'on est sur la page de la bonne série, on peut passer sur la version allemande du site (petit bouton "DE" en haut à droite)
### pour retrouver le nom allemand de la série, et en tirer des mots à utiliser avec gen_find() pour retrouver le code.


#### ATTENTION : les codes affichés sur le site de Destatis-Gensis (en haut de page) sont souvent similaires
#### ne sont pas forcément identiques aux codes utilisés pour récupérer la série
#### avec gen_cube().
#### Par ex: le PIB et ses composantes (approche demande) sont 81000-0019 sur le site,
#### alors que le code pour l'API et gen_cube() est 81000BV019. (8100BJ019 = la même série mais en annuel)
#### Par ailleurs sur le site on trouve une table pour les composantes du PIB y.c. Exports+imports..
#### ... qui n'existe pas sur l'API.




pib_search <- gen_find("importe",
                       detailed = FALSE,
                       ordering = TRUE,
                       category = "all",
                       database = "genesis") 


import_cubes <- pib_search[["Cubes"]] |> 
  filter(grepl("8100", Code))
#NB : on ne trouve que des Cubes à fréquence annuelle (code BV)

# On ressaye la recherche, cette fois-ci en incluant un autre terme qui devrait
# permettre de cible les CN en particulier.
pib_search2 <- gen_find("importe UND Volkswirtschaftliche",
                       detailed = FALSE,
                       ordering = TRUE,
                       category = "all",
                       database = "genesis") 
## On récupère le jeu de données via la fonction gen_cube() 

data_retrieved  <- gen_cube("81000BV010")
data_retrieved_clean <- gen_cube("81000BV010") |> 
  mutate(periode = paste(JAHR, str_extract_all(QUARTG, "\\d"),sep ="."), # Ici on crée une variable "periode", construite en collant les valeurs de JAHR et le premier chiffre de QUARTG (= le trimestre) ; ce dernier est extrait par la fonction str_extract_all
         periode = lubridate::yq(periode)) |> # ensuite on reprend la variable periode, qui sera au format par ex "2004.1", et on le convertit en variable date avec lubridate (yq = conversion d'un variable au format annee.trimestre en variable Date) 
  filter(WERT05 == "X13JDKSB") |>  # on ne retient que les lignes correspondant à des variables CVS-CJO. NB: on fait explicitement référence à la méthode de désaisonnalisation, donc changer si jamais une série a une méthode de désaisonnalisation différente...
  relocate(periode) # purement cosmétique mais je préfère avoir la colonne de date tout à gauche.


### les noms de colonnes ne sont pas très lisibles : pour s'assurer d'être sur les bonnes séries
### on peut comparer avec ce qu'on trouve sur le site de Destatis.

data_retrieved_clean_last <- data_retrieved_clean |> 
  filter(periode == max(periode))

# Un dernier commentaire sur la structure des data.frame que donne gen_cube :
## Destatis est pas très sympa et laisse tout en format "wide" (une colonne = une variable)

data_retrieved_clean_last <- data_retrieved_clean |> 
  filter(periode >as.Date("2023-12-01"))


## En fait ici on a les observations empilées verticalement par période, et par concept
## (valeur, index de volumes chaînés, volumes chaînés)
## Les sous-ensembles sont empilés côte à côte :EXP_001_WERT = exports biens & services ;
### EXP_002_WERT = exports biens ; EXP_003_WERT = exp services etc.
### VGR = Aussenbeitrag (=solde résiduel d'exports - imports)




### A priori on ne peut que faire des requêtes pour 1 Cube à la fois.
### On pourrait éventuellement faire un lapply ou une boucle mais à voir si
### les formattages des Cubes se prêtent à ce genre d'itération..

data_retrieved_clean <- gen_cube("81000BV010") |> 
  mutate(periode = paste(JAHR, str_extract_all(QUARTG, "\\d"),sep ="."), # Ici on crée une variable "periode", construite en collant les valeurs de JAHR et le premier chiffre de QUARTG (= le trimestre) ; ce dernier est extrait par la fonction str_extract_all
         periode = lubridate::yq(periode)) |> # ensuite on reprend la variable periode, qui sera au format par ex "2004.1", et on le convertit en variable date avec lubridate (yq = conversion d'un variable au format annee.trimestre en variable Date) 
  filter(WERT05 == "X13JDKSB") |>  # on ne retient que les lignes correspondant à des variables CVS-CJO. NB: on fait explicitement référence à la méthode de désaisonnalisation, donc changer si jamais une série a une méthode de désaisonnalisation différente...
  relocate(periode) # purement cosmétique mais je préfère avoir la colonne de date tout à gauche.


## On peut préfiltrer les requêtes à l'aide des arguments
## ci-dessous remplacer les [n] par 1,2,3... (se référer à ?gen_cube : il semble qu'on peut aussi juste vectoriser)
## classifyingvariable[n] -> la variable à filtrer (=colonne dans le output de gen_cube de base)
## classifyingkey[n] -> la modalité à retenir

## Ici on va garder uniquement les volumes chaînés en base 2020
test <- gen_cube("81000BV010",classifyingvariable1= "VGRPB5", classifyingkey1="VGRPVK")


valvol <- gen_search_vars("VGRPB5",
                          database = "genesis")

## Une méthode possible pour alléger les premières requêtes de chaque cube
## I.e. quand on n'est pas encore sûr de quelles classifyingvariables il y a,
## et quelles valeurs renseigner pour leurs modalités (classifyingkey) :

## On fait une première requête mais en se limitant à 1 année pour réduire le nombre d'observations

comext_first <- gen_cube("81000BV010",
                         startyear = 2023,
                         endyear = 2023)

# Ici on n'a que 28 obs, ce qui est quand même plus lisible (la requête reste un peu lente mais bon...)