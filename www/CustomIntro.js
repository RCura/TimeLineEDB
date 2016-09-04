function startIntro(){
  var intro = introJs();
  intro.setOptions({
    steps: [
      { 
        intro: "Bienvenue dans l'application <b>TimeLine</b> <b>E</b>xploratory <b>D</b>ash<b>B</b>oard!"
      },
      { 
        intro: "Cette application va vous permettre d'explorer des données de localisation que Google possède sur ses utilisateurs " +
        "( et peut-être sur vous ..) " +
        "au sein d'une application dénommée Google TimeLine."
      },
      {
        intro: "L'objectif est de vous amener à comprendre des éléments de la vie privé" +
        "d'un utilisateur dont on possède les données."
      },
            {
        intro: "Ces données sont complexes et massives. Affichées toutes ensemble, elles se superposent sans" +
        "donner de grandes informations sur l'individu suivi."
      },
            {
        intro: 'Mais en se "promenant" dans ces données, on peut aussi discerner des éléments très privés.'
      },
            {
        intro: "Pour se faire, on va faire appel aux méthodes de <b> l'analyse exploratoire interactive de données</b>."
      },
            {
        intro: 'Les "composants grapihques" (cartes, diagrammes) présentés sur cette page sont interactifs.' +
        "C'est-à-dire que vous pouvez effecter des sélections dedans, " +
        "et que chacun réagit aux séléctions effectuées dans les autres."
      },
      {
        intro : "Pour faciliter la compréhension, on va maintenant présenter les composants un par un."
      },
      {
        element: '#map',
        intro: "Vous disposez ici d'une carte montrant l'ensemble des localisations de l'individu." +
        "<br />" +
        'C\'est une carte de type <i>heatmap</i>, ou "carte de chaleur".' +
        "<br />" +
        "Les points proches sont superposés, et plus il y a de points superposés, plus la couleur s'approche du bleu."
      },
            {
        element: '#map',
        intro: "Un point très bleu est donc une zone dans laquelle l'individu s'est rendu très souvent." +
        "C'est ce que l'on appelle un <i>hot-spot</i>, ou \"point chaud \"."
      },
      {
        element: '#daydensity',
        intro: 'Ce graphique interactif affiche la fréquence temporelle (heures de la journée) des enregistrement de l\'utilisateur.\n<br />Vous pouvez effectuer une sélection sur ces heures, ce qui aura pour effet de modifier les points affichés sur la carte, et ainsi, essayer de trouver les lieux fréquentés par l\'utilisateur aux différentes heures de la journée.\n<hr /> En cas de sélection spatale, la différence entre la fréquence générale (en bleu) et la fréquence de la sélection (en rouge) vous permettront de mieux comprendre l\'usage temporel d\'un lieu, et donc sa fonction.'
      },
      {
        element: '#dayfreq',
        intro: 'Ce graphique interactif affiche la fréquence temporelle (heures de la journée) des enregistrement de l\'utilisateur.\n<br />Vous pouvez effectuer une sélection sur ces heures, ce qui aura pour effet de modifier les points affichés sur la carte, et ainsi, essayer de trouver les lieux fréquentés par l\'utilisateur aux différentes heures de la journée'
      },
      {
        element: '#monthfreq',
        intro: 'monthfreq'
      },
      {
        element: '.well',
        intro: 'Analyse auto'
      },
      {
        element: '#userData',
        intro: "Charger données"
      },
      {
        element: '#mainHelp',
        intro: "Vous pouvez cliquer ici à tout moment pour ré-afficher cette présentation de TimeLine EDB.\n<hr /> Bonne exploration !"
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
      },
      {
        intro: "Pour cela, cliquez sur l'image suivante et connectez-vous avec votre compte Google.<br />" +
        "<a href='https://www.google.com/maps/timeline' target='_blank'>" +
        "<img src='img/google_timeline_home.png'>" +
        "</a>"
      },{
        intro: "Si des données se sont bien affichées, il va falloir les télécharger depuis le serveur de Google afin de les insérer dans l'application."
      },{
        intro: "Pour ce faire, cliquez sur l'image suivante, laissez les réglages par défaut (comme dans l'image) et cliquez sur suivant." +
        "<a href='https://takeout.google.com/settings/takeout/custom/location_history?hl=fr&gl=FR' target='_blank'>" +
        "<img src='img/google_takeout_home.png'>" +
        "</a>"
      },{
        intro: 'Vous pouvez alors cliquer sur "Créér une archive".' +
        "<img src='img/google_takeout_export.png'>"
      },{
        intro: 'Et attendre que le fichier <i>zip</i> vous soit proposé, et le télécharger.' +
        "<img src='img/google_takeout_download.png'>"
      },{
        intro: "Une fois ce <i>zip</i> téléchargé, vous pourrez l'entrer dans l'application."
      },
      {
        element: '#userData',
        intro: "En cliquant sur ce menu."
      },
      {
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