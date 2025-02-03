library(tidyverse)
library(insee)


#### Les datasets sont des regroupements de séries ; il y en a ~ 200
#### On récupère la liste des datasets.
insee_datasets <- get_dataset_list()


#### Les idbank correspondent aux séries individuelles. Pour chaque dataset, on
### récupère la liste des idbanks qu'il contient.
idbank_list = get_idbank_list('CNT-2020-PIB-EQB-RF')


## Filtrer la liste d'idbanks rend le data.frame plus lisibles ; on peut aussi déjà
## se concentrer sur les séries pertinentes (ici cvs-cjo).
idbank_list_conso <- idbank_list |> 
  filter(grepl("consommation", OPERATION_label_fr, ignore.case = TRUE),
         CORRECTION == "CVS-CJO") |> 
  select(idbank, OPERATION_label_fr,SECT_INST_label_fr, VALORISATION_label_fr, CORRECTION_label_fr)


## On peut sinon commencer par une recherche
dataset_enq_confiance <-  search_insee("conjoncture|enquête")


#### Toute cette étape de recherche des idbanks peut également se faire directement sur le site
### de l'insee (l'idbank est le numéro à la fin de l'URL d'une série chronologique ou l'identifiant indiqué sur la page)

### Récupérer des données:

## Soit on veut tout un dataset, par exemple ici les enquêtes de conjonctures (en se limitant aux 12 dernières obs)
dataset_enq_confiance_last12 <- get_insee_dataset("ENQ-CONJ-MENAGES",lastNObservations = 12)
## On a récupéré quelques observations de 2010...
## Il semblerait qu'il y ait des idbank pour des séries d'enquêtes conj désormais arrêtées
## Donc l'insee les considère comme une idbank distincte de la série actuelle, avec ses
## propres 12 dernières observations.


### Soit on a en tête certaines séries précises :
## dans ce cas on liste individuellement les idbanks.
sal_reel_series <- get_insee_idbank("011793934", "011794169","001759971")
