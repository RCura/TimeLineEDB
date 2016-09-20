function startIntro(){
  var intro = introJs();
  intro.setOptions({
    steps: [
      { 
        intro: "Bienvenue dans l'application <b>TimeLine</b> <b>E</b>xploratory <b>D</b>ash<b>B</b>oard!"
      },{ 
        intro: "Cette application va vous permettre d'explorer des données de localisation que Google possède sur ses utilisateurs ( et peut-être sur vous ..) au sein d'une application dénommée Google TimeLine."
      },{
        intro: "L'objectif est de vous amener à comprendre des éléments de la vie privé d'un utilisateur dont on possède les données."
      },{
        intro: "Ces données sont complexes et massives. Affichées toutes ensemble, elles se superposent sans donner de grandes informations sur l'individu suivi."
      },{
        intro: "Mais en se \"promenant\" dans ces données, on peut aussi discerner des éléments très privés."
      },{
        intro: "Pour se faire, on va faire appel aux méthodes de <b>l'analyse exploratoire interactive de données</b>."
      },{
        intro: "Les \"composants graphiques\" (cartes, diagrammes) présentés sur cette page sont interactifs. C\'est-à-dire que vous pouvez effecter des sélections dedans, et que chacun réagit aux sélections effectuées dans les autres."
      },{
        intro : "Pour faciliter la compréhension, on va maintenant présenter les composants un par un."
      },{
        element: "#map",
        intro: "Vous disposez ici d'une carte montrant l'ensemble des localisations de l'individu.<br /> C'est une carte de type <i>heatmap</i>, ou \"carte de chaleur\".<br />Les points proches sont superposés, et plus il y a de points superposés, plus la couleur s'approche du bleu."
      },{
        element: "#map",
        intro: "Un point très bleu est donc une zone dans laquelle l'individu s'est rendu très souvent. C'est ce que l'on appelle un <i>hot-spot</i>, ou \"point chaud \"."
      },{
        element: "#map",
        intro: "Afin de comprendre à quoi  correspondent ces points chauds, vous pouvez zoomer, dézoomer, mais aussi vous déplacer dans la carte."
      },{
        element: ".mapSettingsCheckBox",
        intro: "Des réglages pour la carte sont accessibles en cliquant sur cette icône."
      },{
        element: "#map",
        intro: "Vous pouvez aussi effectuer une sélection, grâce à l'outil de dessin suivant."
      },{
        element: ".leaflet-draw-toolbar-top",
        intro: "En dessinant une zone rectangulaire avec cet outil, une sélection spatiale des points situés à l'intérieur de la zone sera effectuée.<br /><hr /> Cette sélection sera reprise sur l'ensemble des autres graphiques, ce qui vous permettra par exemple de comprendre à quel moment de la journée un utilisateur se rend dans un lieu donné."
      },{
        element: "#daydensity",
        intro: "Ce graphique interactif affiche la fréquence temporelle (heures de la journée) des enregistrement de l\'utilisateur.\n<br />Vous pouvez effectuer une sélection sur ces heures, ce qui aura pour effet de modifier les points affichés sur la carte, et ainsi, essayer de trouver les lieux fréquentés par l\'utilisateur aux différentes heures de la journée.\n<hr /> En cas de sélection spatale, la différence entre la fréquence générale (en bleu) et la fréquence de la sélection (en rouge) vous permettront de mieux comprendre l\'usage temporel d\'un lieu, et donc sa fonction."
      },{
        element: "#daydensity",
        intro: "Vous pouvez par exemple sélectionner les heures correspondant à la nuit pour trouver les endroits où l'utilisateur passe ses nuits, et donc, sans doute, son domicile."
      },{
        element: "#dayfreq",
        intro: "Ce graphique interactif affiche la fréquence hebdomadaire (jours de la semaine) des enregistrement de l\'utilisateur.\n<br />Vous pouvez effectuer une sélection sur ces jours, ce qui aura pour effet de modifier les points affichés sur la carte, et ainsi, essayer de trouver les lieux fréquentés par l\'utilisateur selon les jours de la semaine."
      },{
        element: "#dayfreq",
        intro: "Vous pouvez par exemple observer la différence entre la localisation de l'utilisateur en semaine et en week-end pour faire ressortir la différence de fréquentation des lieux de travail et des lieux de loisir."
      },{
        element: "#monthfreq",
        intro: "Comme le graphique précédent, mais celui-ci informe sur la fréquence mensuelle. Vous pouvez ainsi différencier les mois d'été, qui peuvent montrer les vacances de l'utilisateur, des mois usuels."
      },{
        element: "#yearPlot",
        intro: "Vous pouvez utiliser ce graphique annuel afin de différencier les localisations de l'utilisateur, par exemple pour observer si celui-ci a déménagé ou changé de lieu de travail."
      },{
        element: "#calendarPlot",
        intro: "Ce graphique présente une vue calendaire. Chaque carré représente un jour du mois. Plus la densité est forte (bleu clair ou rouge clair selon qu'il y a une sélection spatiale ou non), plus l'utilisateur a de points enregistrés ce jour là."
      },{
        element: "#calendarPlot",
        intro: "Cela permet par exemple de comprendre quand l'utilisateur a effectué un voyage particulier, ou encore d'avoir une idée de l'occupation sur l'année d'un lieu secondaire pour l'utilisateur."
      },{
        element: "#automaticAnalysis",
        intro: "Dans ce paneau, vous pouvez executer (en cochant l'icône \"Lancer les analyses\") une analyse automatique qui vise à deviner où l'utilisateur est domicilié et où il travaille.<br /><hr /> Pour cela, on effectue une opération de classification des points, en observant les lieux où l'utilisateur se trouve le plus souvent. On isole ensuite parmi ces lieux l'endroit où l'utilisateur est le plus souvent pendant la journée de travail,  en jours de semaines, pour trouver le lieu de travail. En effectuant la même opération pour les heures de nuit, on trouve le domicile probable.<br />Grâce à une opération nommée \"géocodage inverse\", on peut alors déduirGérard Augraffee l'adresse de ces deux \"hot-spots\"."
      },{
        intro: "C'est la fin de cette visite guidée, vous êtes maintenant invités à explorer le jeu de données qui vous est ici présenté, en essayant de comprendre le déroulement des journées et semaines de l'utilisateur qui vous est ainsi livré."
      },{
        element: ".userSettingsCheckBox",
        intro: "Vous pourrez ensuite exploiter ces méthodes d'explorations sur vos propres données, en cliquant sur ce bouton."
      },{
        element: "#mainHelp",
        intro: "Vous pouvez cliquer ici à tout moment pour ré-afficher cette présentation de TimeLine EDB.<hr /> Bonne exploration !"
      }
      ],
    tooltipPosition: 'auto',
    tooltipClass:'customDefault',
    positionPrecedence: ['left', 'right', 'bottom', 'top'],
    showProgress: true
  });
  
  intro.start();
}

function userDataIntro(){
  var introUserData = introJs();
  introUserData.setOptions({
    steps: [
      { 
        intro: "Vous pouvez maintenant explorer vos propres données, si toutefois Google en possède sur vous !"
      },{
        intro: "Pour cela, cliquez sur l'image suivante et connectez-vous avec votre compte Google.<br /><a href='https://www.google.com/maps/timeline' target='_blank'><img src='img/google_timeline_home.png'></a>"
      },{
        intro: "Si des données se sont bien affichées, il va falloir les télécharger depuis le serveur de Google afin de les insérer dans l'application."
      },{
        intro: "Pour ce faire, cliquez sur l'image suivante, laissez les réglages par défaut (comme dans l'image) et cliquez sur suivant. <a href='https://takeout.google.com/settings/takeout/custom/location_history?hl=fr&gl=FR' target='_blank'><img src='img/google_takeout_home.png'></a>"
      },{
        intro: "Vous pouvez alors cliquer sur \"Créér une archive\".<img src='img/google_takeout_export.png'>"
      },{
        intro: "Et attendre que le fichier <i>zip</i> vous soit proposé, et le télécharger.<img src='img/google_takeout_download.png'>"
      },{
        intro: "Une fois ce <i>zip</i> téléchargé, vous pourrez l'entrer dans l'application."
      },{
        element: '#userData',
        intro: "En cliquant sur ce menu."
      },{
        intro: "Tous les graphiques et la carte se mettront alors à jour avec vos propres données. Bonne exploration avec TimeLine EDB !"
      },{
        element: "#userDataHelp",
        intro: "Retrouvez ce tutoriel à tout moment en cliquant sur cette icône."
      }],
    tooltipPosition: 'auto',
    tooltipClass:'customDefault',
    positionPrecedence: ['left', 'right', 'bottom', 'top'],
    showProgress: true
  });
  
  introUserData.start();
}