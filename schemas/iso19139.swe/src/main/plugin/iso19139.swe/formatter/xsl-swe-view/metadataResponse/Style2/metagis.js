
var selectedrow;
var TitleData;
var NameData;
var MinScaleData;
var MaxScaleData;
var LegendURLData;
var MetadateURLData;
var SRSData;


function rowClick(evt) {
    if (!evt) {
        evt = window.event;
    }

    var srcElement;
    if (evt.srcElement) { srcElement = evt.srcElement; } else { srcElement = evt.target; }
    if (srcElement && srcElement.tagName == "TD") { srcElement = srcElement.parentNode; }

    var table = srcElement.parentNode; //parent table
    var rows = table.getElementsByTagName("tr"); //all rows
    var length = rows.length;

    for (i = 0; i < length; i++) {
        if (rows[i] == srcElement) {
            selectedrow = i;
            var cells = rows[i].getElementsByTagName("td");

            if (cells[0].hasChildNodes()) {
                TitleData = cells[0].firstChild.nodeValue;
            }
            if (cells[1].hasChildNodes()) {
                NameData = cells[1].firstChild.nodeValue;
            }
            if (cells[2].hasChildNodes()) {
                MinScaleData = cells[2].firstChild.nodeValue;
            }
            if (cells[3].hasChildNodes()) {
                MaxScaleData = cells[3].firstChild.nodeValue;
            }
            if (cells[4].hasChildNodes()) {
                if (cells[4].innerText.length > 1) {
                    LegendURLData = cells[4].childNodes[0].getAttribute('href');
                } else { LegendURLData = ' -' }
            }
            if (cells[5].hasChildNodes()) {
                if (cells[5].innerText.length > 1) {
                    MetadateURLData = cells[5].childNodes[0].getAttribute('href');
                } else { MetadateURLData = ' -' }
            }
            if (cells[6].hasChildNodes()) {
                SRSData = cells[6].firstChild.nodeValue;
            }

            break;
        }
    }

}


function showdata(img, j) {
    rowClick(event);

    var o = document.getElementById('divserviceiteminfo');
    if (o != null) {
        o.style.display = 'block';
        fnTaskSubmit(img.id, j, selectedrow);

        document.getElementById("tdTitleData").firstChild.nodeValue = TitleData;
        document.getElementById("tdNameData").firstChild.nodeValue = NameData;
        document.getElementById("tdMinScaleData").firstChild.nodeValue = MinScaleData;
        document.getElementById("tdMaxScaleData").firstChild.nodeValue = MaxScaleData;
        //    document.getElementById("tdLegendURLData").setAttribute('href',LegendURLData); 
        document.getElementById("tdLegendURLData").firstChild.nodeValue = LegendURLData;
        document.getElementById("tdMetadateURLData").firstChild.nodeValue = MetadateURLData;
        document.getElementById("tdSRSData").firstChild.nodeValue = SRSData;
    }
}

function hidedata() {
    var o = document.getElementById('divserviceiteminfo');
    if (o != null) {
        o.style.display = 'none';
    }
}


function fnTaskSubmit(img, j, i) {
    if (navigator.userAgent.indexOf("Firefox") != -1) // If Browser is Mozilla
    {
        var objPopup = new PopupWindow("divserviceiteminfo");
        objPopup.offsetX = 0;
        objPopup.offsetY = 0;
        objPopup.showPopup(img);
    }
    else {
        var objPopup = new PopupWindow("divserviceiteminfo");
        objPopup.offsetX = 0;
        objPopup.offsetY = 0;
        objPopup.showPopup(img);
    }
}


function $id(something) {
    if (typeof (something) == "string") {
        var elm = document.getElementById(something);
    } else {
        var elm = something;
    }
    if (something instanceof Array) {
        var elm = [];
        for (var i = 0; i < something.length; i++) { elm.push($id(something[i])); }
    }
    if (!elm) return false;
    return elm;
}


function ShowMetadata(theUUID) {
    var aURL = "http://planportgpt2:8081/Treeview/metadata/" + theUUID + ".xml";
    if (!metaWindow || metaWindow.closed) {
        metaWindow = window.open(aURL, 'metaWindow', 'menubar=no,status=yes,resizeable=yes,scrollbars=yes,width=1200,height=800');
    }
}


function fix(id) {

    var e = document.getElementById(id);
    var content = e.innerHTML.split("\n");
    //var content = e.innerHTML.replace("\n",'<br/>');
    for (i = 0; i < content.length; i++) {
        content[i] = content[i].trim();
        if (content[i].startsWith("#")) {
            var ndx = content[i].mid(1, 1);
            //console.info(ndx);

            switch (ndx) {
                case "1":
                    var h4 = document.createElement("h4");
                    h4.innerHTML = content[i];
                    h4.innerHTML = h4.innerHTML.replace("#1", "");
                    e.parentNode.appendChild(h4);
                    break;

                case "2":
                    var h5 = document.createElement("h5");
                    h5.innerHTML = content[i];
                    h5.innerHTML = h5.innerHTML.replace("#2", "");
                    e.parentNode.appendChild(h5);
                    break;

                case "3":
                    var h6 = document.createElement("h6");
                    h6.innerHTML = content[i];
                    h6.innerHTML = h6.innerHTML.replace("#3", "");
                    e.parentNode.appendChild(h6);
                    break;

                case "L":
                    var li = document.createElement("li");
                    li.innerHTML = content[i];
                    li.innerHTML = li.innerHTML.replace("#L", "");
                    e.parentNode.appendChild(li);
                    break;

                default:
                    var da = document.createElement("da");
                    da.innerHTML = content[i];
                    e.parentNode.appendChild(da);
                    break;
            }
        }
        else {
            var n = document.createElement("div");
            e.parentNode.appendChild(n);
            n.innerHTML = content[i];
            e.parentNode.appendChild(n);
        }
    }
    e.parentNode.removeChild(e);
}


function fix2(id) {    
    var e = document.getElementById(id);
    var content = e.innerHTML;
    //var content = e.innerHTML.replace(/\n/g, '<br/>');    
    if (content.indexOf("&lt;") === -1)
    {     
        content = content.replace(/\n/g, '<br/>');
    }    
    content = content.replace("<![CDATA[", "")
    content = content.replace("]]>", "")
    content = content.replace(/&lt;/gi, "<")
    content = content.replace(/&gt;/gi, ">")
    content = content.replace(/&br;/gi, "<br>")
    content = content.replace(/&b;/gi, "<b>")    
    //content = content.replace(/&/b;/gi,"<b>")    
    var aDiv = document.createElement("div");
    aDiv.id = "abstractDiv"    
    aDiv.innerHTML = content;
    e.parentNode.appendChild(aDiv);
    e.parentNode.removeChild(e);        
}

/*
* Extended Strings
*/

if (!String.prototype.repeat) {
    String.prototype.repeat = function (times) {
        var ret = '';
        for (var i = 0; i < times; i++) { ret += this; }
        return ret;
    };
}

if (!String.prototype.startsWith) {
    String.prototype.startsWith = function (str) {
        return (this.indexOf(str) === 0);
    };
}

if (!String.prototype.endsWith) {
    String.prototype.endsWith = function (str) {
        var reg = new RegExp(str + "$");
        return reg.test(this);
    };
}

if (!String.prototype.mid) {
    String.prototype.mid = function (start, len) {
        if (start < 0 || len < 0) return "";
        var iEnd, iLen = String(this).length;
        if (start + len > iLen)
            iEnd = iLen;
        else
            iEnd = start + len;
        return String(this).substring(start, iEnd);
    };
}


function setLinkClickable(id) {    
    var e = document.getElementById(id);
    var inputText = e.innerHTML;

    var replacedText, replacePattern1, replacePattern2;

    //URLs starting with http://, https://, or ftp://
    replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim;
    replacedText = inputText.replace(replacePattern1, '<a href="$1" target="_blank">$1</a>');

    //URLs starting with "www." (without // before it, or it'd re-link the ones done above).
    replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim;
    replacedText = replacedText.replace(replacePattern2, '$1<a href="http://$2" target="_blank">$2</a>');
    
    var aDiv = document.createElement("div");
    aDiv.innerHTML = replacedText;
    e.parentNode.appendChild(aDiv);
    e.parentNode.removeChild(e);
}

function printBtnClickEvent() {
	//Activate the Alla metadata tab
	var metadataTabberDiv = document.getElementById("metadataTabberDiv");
	for(var i=0; i<metadataTabberDiv.children[0].children.length; i++) {
		var metadataTabTitleEl = metadataTabberDiv.children[0].children[i];
		var tabHrefTag = metadataTabTitleEl.children[0];
				
		if(tabHrefTag.title.trim() == "Alla metadata") {
			if (typeof tabHrefTag.onclick == "function") {
				tabHrefTag.click();
			}
		}
	}
	
	//Open the Alla metadata tab items in a window for display the standard printing dialog		
	var printWindow = window.open('', 'metadata_all', 'scrollbars=yes,height=550,width=800');
	printWindow.document.open();
	printWindow.document.write('<html><head><title>Alla metadata</title>');
	printWindow.document.write('<style>#in {display:none}</style>');
	// Construct the dynamic link tags. Don't hard code css imports. Will not work for GN3.0
	var links = document.getElementsByTagName('link');
	if(links) {
		var length = links.length;
		for(var i = 0; i < length; i++) {
			var link = links[i];
			if(link) {
				var id = link.id;
				if(id && id.startsWith('link')) {
					var href = link.href;
					printWindow.document.write('<link id="' + id + '"rel="stylesheet" type="text/css" href="' + href + '"/>');
				}
			}
		}
	}
	//printWindow.document.write('<link rel="stylesheet" type="text/css" href="metadataResponse/Style2/styles.css"/>');
	//printWindow.document.write('<link rel="stylesheet" type="text/css" href="metadataResponse/Style2/TreeFromXMLUsingXSLT.css"/></head>');
	printWindow.document.write('<body onload="window.print()">');		
	
	var allMetadataTabEle = document.getElementById("allMetadataTab");
	var allMetadataTabInnerHtml = '';
	if(allMetadataTabEle) {
		allMetadataTabInnerHtml = allMetadataTabEle.innerHTML;
	}
	printWindow.document.write(allMetadataTabInnerHtml);
	printWindow.document.write('</body></html>');
	printWindow.document.close();
	printWindow.focus();
	
	//Change the image width for control the font size change on printing.
	var thumbnail = printWindow.document.getElementById("thumbnail");
	var newWidth = 600;
	if(thumbnail != undefined && thumbnail != null){
		if(thumbnail.clientWidth > newWidth) {
			thumbnail.style.width = newWidth + "px";
		}
	}
    return true;
}

function printBtnClickEventFromInBuiltStyleSheet() {	
	//Open the Alla metadata tab items in a window for display the standard printing dialog		
	var printWindow = window.open('', 'metadata_all', 'scrollbars=yes,height=550,width=800');
	printWindow.document.open();
	printWindow.document.write('<html><head><title>Alla metadata</title>');
	printWindow.document.write('<style>#in {display:none}</style>');
	// Construct the dynamic link tags. Don't hard code css imports. Will not work for GN3.0
	var links = document.getElementsByTagName('link');
	if(links) {
		var length = links.length;
		for(var i = 0; i < length; i++) {
			var link = links[i];
			if(link) {
				var id = link.id;
				if(id && id.startsWith('link')) {
					var href = link.href;
					printWindow.document.write('<link id="' + id + '"rel="stylesheet" type="text/css" href="' + href + '"/>');
				}
			}
		}
	}
	//printWindow.document.write('<link rel="stylesheet" type="text/css" href="metadataResponse/Style2/styles.css"/>');
	//printWindow.document.write('<link rel="stylesheet" type="text/css" href="metadataResponse/Style2/TreeFromXMLUsingXSLT.css"/></head>');
	printWindow.document.write('<body onload="window.print()">');		
	
	var allMetadataTabEle = document.getElementById("allMetadataTab");
	var allMetadataTabInnerHtml = '';
	if(allMetadataTabEle) {
		allMetadataTabInnerHtml = allMetadataTabEle.innerHTML;
	}
	printWindow.document.write(allMetadataTabInnerHtml);
	printWindow.document.write('</body></html>');
	printWindow.document.close();
	printWindow.focus();
	
	//Change the image width for control the font size change on printing.
	var thumbnail = printWindow.document.getElementById("thumbnail");
	var newWidth = 600;
	if(thumbnail != undefined && thumbnail != null){
		if(thumbnail.clientWidth > newWidth) {
			thumbnail.style.width = newWidth + "px";
		}
	}
    return true;
}

function mdContactFormTitleClick() {
	var metadataContactDivEle = document.getElementById('metadataContactDiv');
	if(metadataContactDivEle) {
		var visible = metadataContactDivEle.style.display;
		if(visible == "none") {
		  document.getElementById('metadataContactDiv').style.display = "block";
		}
		else {
		  document.getElementById('metadataContactDiv').style.display = "none";
		}
	}
}

function mdContactFormValidation() {
	var metadataContactForm = document.getElementById('metadataContactForm');

	var name = metadataContactForm.name;
	if ((name.value == null)||(name.value.trim() == "")){
		alert("Fields marked with * must be entered");
		name.focus();
		return false;
	}
	var email = metadataContactForm.email;
	if ((email.value == null)||(email.value.trim() == "")){
		alert("Fields marked with * must be entered");
		email.focus();
		return false;
	}
	var comments = metadataContactForm.comments;
	if ((comments.value == null)||(comments.value.trim() == "")){
		alert("Fields marked with * must be entered");
		comments.focus();
		return false;
	}
	var mailSendingTag = document.getElementById("msgSendingTag");
	mailSendingTag.style.display = "block";

	var xmlhttp;
	if (window.XMLHttpRequest) {
		// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp=new XMLHttpRequest();
	}
	else {
		// code for IE6, IE5
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}
	
	xmlhttp.onreadystatechange = function()
	{
		if (xmlhttp.readyState==4 && xmlhttp.status==200) {
			mailSendingTag.style.display = "none";
			document.getElementById("msgSuccessErrorBox").innerHTML = xmlhttp.responseText;
		} else if (xmlhttp.readyState==4 && xmlhttp.status==404) {
			mailSendingTag.style.display = "none";
			document.getElementById("msgSuccessErrorBox").innerHTML = 'Email functionality not yet implemented!!!';
		}
	}
	
	var param = "name=" + encodeURIComponent(name.value.trim());
	param += "&email=" + encodeURIComponent(email.value.trim());
	param += "&org=" + encodeURIComponent(metadataContactForm.org.value.trim());
	param += "&comments=" + encodeURIComponent(comments.value.trim());
	param += "&metadataTitle=" + encodeURIComponent(metadataContactForm.metadataTitle.value.trim());
	param += "&metadataToAddress=" + encodeURIComponent(metadataContactForm.metadataToAddress.value.trim());
	
	// Additional code to application context
	var path = window.location.pathname;
	var context = null;
	if(path) {
		context = path.substring(0, path.lastIndexOf("/"));
		context = (context.lastIndexOf("/srv") > -1) ? context.substring(0, context.lastIndexOf("/srv")) : context; // path with swe/eng locale
	}
	xmlhttp.open("POST",context + "/srv/api/metadata/feedback-swe",true);
	xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	xmlhttp.setRequestHeader("accept","text/plain; charset=utf-8");
	xmlhttp.send(param);
	
	return false;
}