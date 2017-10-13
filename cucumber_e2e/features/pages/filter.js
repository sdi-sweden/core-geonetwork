'use strict';

//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var EC = protractor.ExpectedConditions;
var Filter = function () {};

 Filter.prototype = Object.create({}, {

   veiwFilter: {get: function(){

     return 	element(by.xpath("//*[contains(text(),'visa filtrering ')]")).click();
   }},
   searchElement:{get: function(){
 		return element(by.id('gn-or-field'));
  }},

	pageTitle: {get: function(){
      browser.ignoreSynchronization = true;
      return browser.getTitle();
      }},

	basicCategoryList: {get: function(){
		return  element.all(by.repeater('topic in topicCategories | orderBy: orderByTranslated'));
	}},

	doFreeTextSearch: {get: function(){
	    var el = element(by.id('gn-or-field'));
	    browser.driver.sleep(500);
		return el.sendKeys(protractor.Key.ENTER);
//    return element(by.xpath("//*[@id='gn-or-field']")).sendKeys(protractor.Key.ENTER);
	}},

	typeSearchPhrase:{value: function(searchPhrase){
		return element(by.id('gn-or-field')).sendKeys(searchPhrase);
	}},

	clearFilter: {get: function(){
		return element(by.css('[data-ng-click="viewAllMetadata()"]')).click();

   }},


	clearFreetext:{get: function(){
		element(by.xpath("//*[@id='gn-or-field']")).clear();
		//this.doFreeTextSearch;
	}},

	freeTextSearch: {value: function(searchPhrase){
    //this.clearFilter;
		this.typeSearchPhrase(searchPhrase);

		this.doFreeTextSearch;


	}},

	selectCategory: {value: function(bc){
    browser.wait(EC.visibilityOf(element(by.partialLinkText(bc))), 2000).then(function(){
				element(by.partialLinkText(bc)).click();
		});
  }},

  openAdvanceView: {get: function(){

   var isClickable = EC.elementToBeClickable(element(by.css('[data-ng-click="toggleAdvancedOptions()"]')));
   browser.wait(isClickable, 50000);
   return element(by.css('[data-ng-click="toggleAdvancedOptions()"]')).click();
  }},

  addFromDate: {value: function(fromDate){
    element(by.model('searchObj.params.resourceDateFrom')).sendKeys(fromDate);
    element(by.model('searchObj.params.resourceDateFrom')).sendKeys(protractor.Key.ENTER);
  }},
  addToDate: {value: function(toDate){
    Element(by.model('searchObj.params.resourceDateTo')).sendKeys(toDate);
    Element(by.model('searchObj.params.resourceDateTo')).sendKeys(protractor.Key.ENTER);
  }},
  ViewMetadata: {value: function(index){

   browser.wait(EC.visibilityOf('[data-ng-click="showMetadata(0, md, searchResults.records)"]'), 20000).then(function(){
     return element(by.css('[data-ng-click="showMetadata(0, md, searchResults.records)"]')).click();
   });
 }},

 selectOrganisation:{value: function(org){

   var catlist=	element.all(by.repeater('c in category')).map(function(orgNameOwner, indx) {
     return{
       organisationName: orgNameOwner.element(by.css('p.ng-binding')).getText(),
       index:indx
     }
    });
    catlist.then(function (value) {
      for (var i = 0; i < value.length; ++i) {
        if(org === value[i].organisationName){
          element.all(by.repeater('c in category')).get(value[i].index).click();
        }
      }
 });
 }},
 getSelectedFilterList:{get: function(){
   var items = element.all(by.css('.selected-filter-list li')).map(function(elm, index) {
     return {
       index: index,

       class: elm.getAttribute('class')
  };
});


   return items;

 }},

 toggleFavorite:{get: function(){

   return element(by.css('[data-ng-click="toggleExclusiveFilter(\'favorites\')"]')).click();

 }},

 toggleMapResources:{get: function(){

   return element(by.css('[data-ng-click="toggleExclusiveFilter(\'favorites\')"]')).click();

 }},



 toggleDownloadResources:{get: function(){

   return element(by.css('[data-ng-click="toggleExclusiveFilter(\'favorites\')"]')).click();

 }}


   });

module.exports = Filter;
