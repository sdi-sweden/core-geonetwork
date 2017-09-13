'use strict';

//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var EC = protractor.ExpectedConditions;
var Publicera = function () {};

 Publicera.prototype = Object.create({}, {
   getTemplateList: {get: function(){
     return element.all(by.repeater('tpl in tpls'));

   }},
   selectTemplate: {value: function(templtIn){

     var templateList = element.all(by.repeater('tpl in tpls')).map(function(template, indx) {
       return{
         tmplt: template.element(by.css('span.ngr-radio-label.ng-binding')).getText(),
         index:indx
       }
      });
      templateList.then(function (tmpl) {
        console.log(tmpl)
        for (var i = 0; i < tmpl.length; ++i) {
          console.log(tmpl[i].tmplt)
        }
        });

   }}
  });

module.exports = Publicera;
