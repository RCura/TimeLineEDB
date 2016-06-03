//set the cookie when they first hit the site
function setCookie(c_name,value,exdays)
{
var exdate=new Date();
exdate.setDate(exdate.getDate() + exdays);
var c_value=escape(value) + ((exdays===null) ? "" : "; expires="+exdate.toUTCString());
document.cookie=c_name + "=" + c_value;
}

//check for the cookie when user first arrives, if cookie doesn't exist call the intro.
function getCookie(c_name)
{
var c_value = document.cookie;
var c_start = c_value.indexOf(" " + c_name + "=");
if (c_start == -1)
  {
  c_start = c_value.indexOf(c_name + "=");
  }
if (c_start == -1)
  {
  c_value = null;
  }
else
  {
  c_start = c_value.indexOf("=", c_start) + 1;
  var c_end = c_value.indexOf(";", c_start);
  if (c_end == -1)
  {
c_end = c_value.length;
}
c_value = unescape(c_value.substring(c_start,c_end));
}
return c_value;
}

function checkCookieIntro(){
   var cookie=getCookie("timelineEDB");

   if (cookie===null || cookie==="") {
      setCookie("timelineEDB", "1",90);
      startIntro();  //change this to whatever function you need to call to run the intro
      }
}

function startIntro(){
  var intro = introJs();
  intro.setOptions({
    steps: [
      { 
        intro: "Hello world!"
      },
      { 
        intro: "You <b>don't need</b> to define element to focus, this is a floating tooltip."
      },
      {
        element: '#map',
        intro: "This is a map."
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
        element: '#controls',
        intro: "This is a selectInput :)."
      },
      {
        element: '#step5',
        intro: 'Get it, use it.'
      }
      ],
    tooltipPosition: 'auto',
    positionPrecedence: ['left', 'right', 'bottom', 'top'],
    showProgress: true
  });
  
  intro.start();
}

window.onload = function() {
    checkCookieIntro();
}