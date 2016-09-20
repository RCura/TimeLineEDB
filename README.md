# TimeLineEDB
Robin Cura. (2016). TimeLine Exploratory DashBoard [web application]. Zenodo. http://doi.org/10.5281/zenodo.154528
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.154528.svg)](https://doi.org/10.5281/zenodo.154528)

## Cadre et objectifs de l'application :

Cette application web permet à ses utilisateurs d'explorer dynamiquement les traces GPS collectés par la société Google dans le cadre de son programme « Timeline ». Lorsqu'un individu possède un smartphone fonctionnant avec le système « Android », celui-ci lui propose d'enregistrer régulièrement et automatiquement les coordonnées de l'endroit où il se trouve. Ce choix effectué, les coordonnées ainsi que l'heure seront enregistrées, environ toutes les 5 minutes, et communiquées aux serveurs de Google. L'utilisateur peut alors les consulter sur un site dédié : https://www.google.fr/maps/timeline. Ce site ne permet qu'une consultation jour par jour, et les données y sont en grande partie masquées, seuls les lieux identifiés par Google y apparaissant. On peut télécharger ces données, massives, mais les outils pour les consulter et explorer manquent.

TimeLine EDB s'inscrit dans cet usage, en poursuivant en particulier trois objectifs pédagogiques et didactiques :  

1. Sensibiliser le public à la masse de données privées qu'il communique, parfois inconsciemment, à de grands opérateurs privés. L'application permet ainsi, en laissant un utilisateur explorer ces données, de réaliser la quantité d'informations personnelles qu'il est possible de récupérer avec des traitements simples sur ces données. Le volume de celles-ci permet ainsi d'identifier très aisément les lieux de résidence, de travail, de sorties, de vacances ainsi que les plages horaires associées d'un utilisateur.

2. Illustrer et faire expérimenter la démarche d'exploration interactive de données spatio-temporelles par une approche ludique, sous forme « d'investigation » à partir de ses propres données ou du jeu de données par défaut utilisé par l'application. On cherche ainsi à remettre au cœur des pratiques géographiques quantitatives l'exploration interactive, souvent utilisée sur des données purement statistiques, mais rarement sur des données spatiales et/ ou temporelles

3. Montrer avec pédagogie la richesse et la complexité des données spatio-temporelles et des méthodes d'analyse qu'elles requièrent, tout en illustrant l'un des apports de la géomatique à la géographie et aux sciences humaines et sociales.

## Outils :  

Un tutoriel interactif (Fig. 2) se déclenchant lors d'une nouvelle utilisation de l'application permet de se familiariser aux outils disponibles. Ceux-ci se divisent en deux catégories :  

1. Les outils d'affichage et d'interrogation temporelle : ces graphiques affichent la fréquence temporelle des points de la base de données. Le premier graphique montre la fréquence journalière (plages horaires), le second la fréquence hebdomadaire (jours de la semaine) et le dernier la fréquence annuelle (mois de l'année). Une sélection peut être réalisée (via l'action de « brushing ») afin d'isoler les points répondant aux critères temporels sélectionnés. Quand cela est fait, la carte est mise à jour en ne montrant que ces points isolés,  ce qui permet ainsi d'explorer les lieux pratiqués selon les différentes temporalités de l'utilisateur.

2. La carte interactive : cette carte dynamique affiche, sous forme de heatmap, les points de l'utilisateur. La carte est mise à jour lors de sélections temporelles, et elle permet, en dessinant un rectangle ou un polygone, de sélectionner un sous-ensemble des points. Cette sélection est alors reportée sur les graphiques temporels, montrant les usages temporels des lieux choisis.

## Utilisation :  

TimeLine EDB s'utilise en deux temps :  

1. En premier lieu, l'utilisateur est amené à explorer le jeu de données inclus, montrant les déplacements d'un utilisateur anonyme. Il peut ainsi se familiariser à l'utilisation des outils et à la démarche d'exploration interactive de ce type de données spatio-temporelles.

2. Dans un second temps, l'utilisateur est invité à appliquer cette démarche sur ses propres données, en lui indiquant comment vérifier leur existence et le cas échéant, les insérer dans l'application.


## Technique :

Cette application s'utilise depuis tout navigateur internet « moderne », et est développée dans le langage d'analyse de données R. Elle utilise pour ce faire le package Shiny, qui permet de créer une interface web interactive de visualisation et de manipulation de données. Tous les modules développés tirent ainsi partie du large « écosystème de fonctions» porté par ce langage, l'intégration des différents composants se faisant directement en langage R.
TimeLine EDB est un logiciel libre, sous licence AGPL.
