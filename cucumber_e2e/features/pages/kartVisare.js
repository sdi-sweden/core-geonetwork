
'use strict';

//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var EC = protractor.ExpectedConditions;
var KartVisare = function () {


  };

 KartVisare.prototype = Object.create({}, {

   getMiniMizedMap: {get: function(){
     var MiniMizedMapElement = element(by.css('[floating-map-cont]'));
 		  browser.wait(EC.visibilityOf(MiniMizedMapElement), 20000).then(function(){
 	     return MiniMizedMapElement;
      })
   }},

   extendMiniMizedMap: {get: function(){
      browser.wait(EC.visibilityOf(element(by.css('[data-ng-click="showMapPanel()"]'))), 20000).then(function(){
        element(by.css('[data-ng-click="showMapPanel()"]')).click();
       return ;
      })
   }},
   
   closeExtendedMap: {get: function(){
        element(by.css('[ngeo-map="map"]')).click();
       return ;

   }}



 })

module.exports = KartVisare;
