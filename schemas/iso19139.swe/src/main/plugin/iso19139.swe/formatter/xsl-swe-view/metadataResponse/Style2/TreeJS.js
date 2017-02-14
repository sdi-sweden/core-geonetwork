function ExpanderClicked()
{
    //alert('step 1');

	//Get the element that was clicked
	var ctlExpander = event.srcElement;
	var ctlSelectedEntry = ctlExpander.parentElement;
	//Get all the DIV elements that are direct descendants
	var colChild = ctlSelectedEntry.children.tags("DIV");
	
//	alert('child: ' + colChild.length);
	
	if(colChild.length > 0)
	{
//	    alert('Enter in length loop');
	    
		var strCSS;
		//Get the hidden element that indicates whether or not entry is expanded
		var ctlHidden = ctlSelectedEntry.all("hidIsExpanded");
		
		if(ctlHidden.value == "1")
		{
//		    alert('Enter in IF loop');
			//Entry was expanded and is being contracted
			ctlExpander.innerHTML = "+&nbsp;";
			ctlHidden.value = "0";
			strCSS = "NotVisible";
		}
		else
		{
//		    alert('Enter in ELSE loop');
			//Entry is being expanded
			ctlExpander.innerHTML = "-&nbsp;";
			ctlHidden.value = "1";
			strCSS = "IsVisible";
		}
		//Show all the DIV elements that are direct children
		for(var intCounter = 0; intCounter < colChild.length; intCounter++)
		{
//		    alert('Enter in Final FOR loop');
//		    alert(strCSS);
			//currTabElem.setAttribute("class", "some_class_name"); 

			//colChild[intCounter].className = strCSS;
//			alert(colChild[intCounter]);
			colChild[intCounter].setAttribute("className",strCSS); 
		}
	}
	
}
