var tsFontAwesomeButtonID = 'BootstrapWebButtonFAID';

if (!document.getElementById(tsFontAwesomeButtonID)) {
    var toHead  = document.getElementsByTagName('head')[0];
    var toCSS  = document.createElement('link');
    toCSS.id   = tsFontAwesomeButtonID;
    toCSS.rel  = 'stylesheet';
    toCSS.type = 'text/css';
    toCSS.href = '//use.fontawesome.com/releases/v5.15.1/css/all.css';
    toCSS.media = 'all';
    
    toHead.appendChild(toCSS);
    
}