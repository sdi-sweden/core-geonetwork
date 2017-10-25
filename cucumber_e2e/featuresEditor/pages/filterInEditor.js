'use strict';

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var EC = protractor.ExpectedConditions;
var FilterInEditor = function () {};

 FilterInEditor.prototype = Object.create({}, {

     
   
   veiwFilter: {get: function(){

     return 	element(by.xpath("//*[contains(text(),'visa filtrering ')]")).click();
   }},
   searchElement:{get: function(){
 		return element(by.id('gn-or-field'));
  }},




   });

module.exports = FilterInEditor;
