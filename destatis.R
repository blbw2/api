library(tidyverse)
library(jsonlite)
library(restatis)

# Username: DE022888-20230717
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

## Au sein de l'objet search_results créé par notre recherche, c'est surtout ce qui est contenu dans "Cubes"
## qui va nous intéresser. On y retrouve en effet un tableau listant les codes et les noms
## des jeux de données dont le nom contient le terme fourni à gen_find().


## Mon appréciation perso : si tu es familière des noms de variables, concepts etc en allemand,
## et en particulier sur la nomenclature de Destatis, vu que les recherches sont sensibles à la formulation exacte.

## Ma 2e appréciation perso : le plus simple est de chercher les séries sur https://www-genesis.destatis.de/datenbank/online
## en exploitant l'arborescence etc et le fait que tout soit en anglais.
### Une fois qu'on est sur la page de la bonne série, on peut passer sur la version allemande du site (petit bouton "DE" en haut à droite)
### pour retrouver le nom allemand de la série, et en tirer des mots à utiliser avec gen_find() pour retrouver le code.
### Sur le site de Destatis-Gensis, un code sera affiché en haut de la page;
#### il est très proche de, mais pas identique, au code qui sera utilisé pour récupérer la série
#### avec gen_cube().
#### Par ex: le PIB et ses composantes (approches demande) sont 81000-0019 sur le site,
#### alors que le code pour l'API et gen_cube() est 81000BV019. (8100BJ019 = la même série mais en annuel)


## On récupère le jeu de données via la fonction gen_cube() 

pib_search <- gen_find("Importe von Waren",
                       detailed = FALSE,
                       ordering = TRUE,
                       category = "all",
                       database = "genesis")

data_retrieved  <- gen_cube("81000-0020")
# Un dernier commentaire sur la structure des data.frame que donne gen_cube :
## Destatis est pas très sympa et laisse tout en format "wide" (une colonne = une variable)

data_retrieved_clean <- gen_cube("81000BV020") |> 
  mutate(periode = paste(JAHR, str_extract_all(QUARTG, "\\d"),sep ="."), # Ici on crée une variable "periode", construite en collant les valeurs de JAHR et le premier chiffre de QUARTG (= le trimestre) ; ce dernier est extrait par la fonction str_extract_all
         periode = lubridate::yq(periode)) |> # ensuite on reprend la variable periode, qui sera au format par ex "2004.1", et on le convertit en variable date avec lubridate (yq = conversion d'un variable au format annee.trimestre en variable Date) 
  filter(WERT05 == "X13JDKSB") |>  # on ne retient que les lignes correspondant à des variables CVS-CJO. NB: on fait explicitement référence à la méthode de désaisonnalisation, donc changer si jamais une série a une méthode de désaisonnalisation différente...
  relocate(periode) # purement cosmétique mais je préfère avoir la colonne de date tout à gauche.

