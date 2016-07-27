/*
'************************************************************
'*         TERMS & CONDITIONS / COPYRIGHT NOTICE            *
'************************************************************
'*   By Downloading or using this software, you agree to    *
'*   the terms and conditions as stated in the Software     *
'*   License Agreement.  An updated copy of this agreement  *
'*   can be seen at http://www.pagedowntech.com/terms.      *
'*                                                          *
'*   NOTICE: We do not recommend changing the code below    *
'*   as it may interfere with future updates/upgrades.      *
'*                                                          *
'*        PageDown Technology, LLC., Copyright 2009.        *
'*             pagedowntech.com / pdshop.com                *
'*                                                          *
'*  (this copyright notice must not be altered or removed)  *
'************************************************************
*/

function buynow(qaid, qaqty) {
    document.quickbuy.itemid.value = qaid;
    document.quickbuy.qty.value = qaqty;
    document.quickbuy.submit()
}

function showimage(thefile) {
    if (!window.popWindow) {
        popWindow = window.open("" + thefile, "View", "width=500,height=450,toolbar=0,status=0,location=0,menubar=0,scrollbars=yes,resizable=1");
    }
    else {
        if (!popWindow.closed) {
            popWindow.focus();
            popWindow.location = '' + thefile
        }
        else {
            popWindow = window.open("" + thefile, "View", "width=500,height=450,toolbar=0,status=0,location=0,menubar=0,scrollbars=yes,resizable=1");
        }
    }
}


function openpdwindow(theurl, thewidth, theheight, thepar) {
    window.open(theurl, '_blank', "width=" + thewidth + ",height=" + theheight + ",toolbar=0,status=1,location=0,menubar=0,scrollbars=yes,resizable=1");

}


function addtowishlist() {

    document.getElementById('pageform').action = document.getElementById('shopcarturl').value + 'wlistcart.aspx';
    document.getElementById('pageform').submit();
}


function updateprice() {
    document.getElementById('pageform').action = top.location;
    document.getElementById('pageform').submit();
}

function showwindow(theurl, thewidth, theheight, thepar) {

    window.open(theurl, '_blank', "width=" + thewidth + ",height=" + theheight + ",toolbar=0,status=1,location=0,menubar=0,scrollbars=yes,resizable=1");

}

function showimagewindow(thefile) {
    showPopWin(thefile, 500, 400, null, true, false)
}

function showterms() {
    showPopWin('popup_terms.aspx', 600, 500, null, true, false)
}


function printnormal() {
    var browser = navigator.appName;
    if ((browser == "Microsoft Internet Explorer")) {
        document.execCommand('print', false, null);
    }
    else {
        window.print();
    }
}


function dopdshopalert() {
    if (document.alertform) {
        var testifinit = alertform.elements['alertmessage'].value + ''
        if (testifinit != '') {
            showPopWin('popup_alert.aspx', parseFloat(alertform.elements["alertwinw"].value), parseFloat(alertform.elements["alertwinh"].value), null, true, false);
        }
    }
}

function pdshopalert(zmessage) {

    alertform.elements["alertmessage"].value = zmessage;

}


/**
* SUBMODAL v1.6
* Used for displaying DHTML only popups instead of using buggy modal windows.
*
* By Subimage LLC
* http://www.subimage.com
*
* Contributions by:
* 	Eric Angel - tab index code
* 	Scott - hiding/showing selects for IE users
*	Todd Huss - inserting modal dynamically and anchor classes
*
* Up to date code can be found at http://submodal.googlecode.com
*/

// Popup code
var gPopupInitialized = null;
var gPopupMask = null;
var gPopupContainer = null;
var gPopFrame = null;
var gReturnFunc;
var gPopupIsShown = false;
var gDefaultPage = "popup_loading.htm";
var gHideSelects = true;
var gReturnVal = null;



function initPopUp() {
    // Add the HTML to the body

    theBody = document.getElementsByTagName('BODY')[0];
    popmask = document.createElement('div');
    popmask.id = 'popupMask';
    popcont = document.createElement('div');
    popcont.id = 'popupContainer';
    popcont.innerHTML = '' +
		'<div id="popupInner" class="popupInnerClass">' +
			'<div id="popupTitleBar">' +
				'<div id="popupTitle"></div>' +
				'<div id="popupControls">' +
					// '<img width="19" height="19" src="img/close.gif" onclick="hidePopWin(false);" id="popCloseBox" />' +
				'</div>' +
			'</div>' +
			'<iframe style="width:100%;height:100%;background-color:transparent;" scrolling="auto" frameborder="0" allowtransparency="true" id="popupFrame" name="popupFrame"></iframe>' +
		'</div>';
    theBody.appendChild(popmask);
    theBody.appendChild(popcont);

    gPopupMask = document.getElementById("popupMask");
    gPopupContainer = document.getElementById("popupContainer");
    gPopFrame = document.getElementById("popupFrame");

    gPopupInitialized = 'Y'
}

function showPopWin(url, width, height, returnFunc, showCloseBox, showPrintButton) {

    if (gPopupInitialized == null) {
        initPopUp();

    }
//    if (showCloseBox == null || showCloseBox == true) {
//        document.getElementById("popCloseBox").style.display = "block";
//    } else {
//        document.getElementById("popCloseBox").style.display = "none";
//    }

    gPopupIsShown = true;
    gPopupMask.style.display = "block";
    gPopupContainer.style.display = "block";
    centerPopWin(width, height);

    var titleBarHeight = parseInt(document.getElementById("popupTitleBar").offsetHeight, 10);


    gPopupContainer.style.width = width + "px";
    gPopupContainer.style.height = (height + titleBarHeight) + "px";
    setMaskSize();

    gPopFrame.style.width = parseInt(document.getElementById("popupTitleBar").offsetWidth, 10) + "px";
    gPopFrame.style.height = (height) + "px";

    gPopFrame.src = url;
    gReturnFunc = returnFunc;
    hideSelectBoxes();

}

function centerPopWin(width, height) {
    if (gPopupIsShown == true) {
        if (width == null || isNaN(width)) {
            width = gPopupContainer.offsetWidth;
        }
        if (height == null) {
            height = gPopupContainer.offsetHeight;
        }

        var theBody = document.getElementsByTagName("BODY")[0];
        var scTop = parseInt(getScrollTop(), 10);
        var scLeft = parseInt(theBody.scrollLeft, 10);

        setMaskSize();

        var titleBarHeight = parseInt(document.getElementById("popupTitleBar").offsetHeight, 10);
        var fullHeight = getViewportHeight();
        var fullWidth = getViewportWidth();

        gPopupContainer.style.top = (scTop + ((fullHeight - (height + titleBarHeight)) / 2)) + "px";
        gPopupContainer.style.left = (scLeft + ((fullWidth - width) / 2)) + "px";

    }
}

function setMaskSize() {
    var theBody = document.getElementsByTagName("BODY")[0];

    var fullHeight = getViewportHeight();
    var fullWidth = getViewportWidth();

    if (fullHeight > theBody.scrollHeight) {
        popHeight = fullHeight;
    } else {
        popHeight = theBody.scrollHeight;
    }

    if (fullWidth > theBody.scrollWidth) {
        popWidth = fullWidth;
    } else {
        popWidth = theBody.scrollWidth;
    }

    gPopupMask.style.height = popHeight + "px";
    gPopupMask.style.width = popWidth + "px";
}


function hidePopWin(callReturnFunc) {
    gPopupIsShown = false;
    var theBody = document.getElementsByTagName("BODY")[0];
    theBody.style.overflow = "";
    if (gPopupMask == null) {
        return;
    }
    gPopupMask.style.display = "none";
    gPopupContainer.style.display = "none";
    gPopFrame.src = gDefaultPage;
    if (gHideSelects == true) {
        displaySelectBoxes();
    }
}


function hideSelectBoxes() {
    var x = document.getElementsByTagName("SELECT");

    for (i = 0; x && i < x.length; i++) {
        x[i].style.visibility = "hidden";
    }
    if (document.getElementById("imouter0")) {
        imouter0.style.visibility = "hidden";
    }

}

function displaySelectBoxes() {
    var x = document.getElementsByTagName("SELECT");

    for (i = 0; x && i < x.length; i++) {
        x[i].style.visibility = "visible";
    }
    if (document.getElementById("imouter0")) {
        imouter0.style.visibility = "visible";
    }

}

/**
* Code below taken from - http://www.evolt.org/article/document_body_doctype_switching_and_more/17/30655/
*
* Modified 4/22/04 to work with Opera/Moz (by webmaster at subimage dot com)
*
*/
function getViewportHeight() {
    if (window.innerHeight != window.undefined) return window.innerHeight;
    if (document.compatMode == 'CSS1Compat') return document.documentElement.clientHeight;
    if (document.body) return document.body.clientHeight;

    return window.undefined;
}
function getViewportWidth() {
    var offset = 17;
    var width = null;
    if (window.innerWidth != window.undefined) return window.innerWidth;
    if (document.compatMode == 'CSS1Compat') return document.documentElement.clientWidth;
    if (document.body) return document.body.clientWidth;
}

function getScrollTop() {
    if (self.pageYOffset) // all except Explorer
    {
        return self.pageYOffset;
    }
    else if (document.documentElement && document.documentElement.scrollTop)
    // Explorer 6 Strict
    {
        return document.documentElement.scrollTop;
    }
    else if (document.body) // all other Explorers
    {
        return document.body.scrollTop;
    }
}
function getScrollLeft() {
    if (self.pageXOffset) // all except Explorer
    {
        return self.pageXOffset;
    }
    else if (document.documentElement && document.documentElement.scrollLeft)
    // Explorer 6 Strict
    {
        return document.documentElement.scrollLeft;
    }
    else if (document.body) // all other Explorers
    {
        return document.body.scrollLeft;
    }
}

function applysortby() {
    writeCookie('sortby', document.getElementById('sortby').value)
    window.location.reload();

}

function applyviewby() {
    writeCookie('viewby', document.getElementById('viewby').value)
    window.location.reload();

}

function readCookie(nam) {
    var tC = document.cookie.split('; ');
    for (var i = tC.length - 1; i >= 0; i--) {
        var x = tC[i].split('=');
        if (nam == x[0]) return unescape(x[1]);
    }
    return null;
}
function writeCookie(nam, val) {
    document.cookie = nam + '=' + escape(val);
} 
