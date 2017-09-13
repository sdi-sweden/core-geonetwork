'use strict';

//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var EC = protractor.ExpectedConditions;
var ViewMetadata = function () {


  };

 ViewMetadata.prototype = Object.create({}, {

  fromResultList: {value: function(post){
    var viewMetadataElement = post.element(by.css('[ng-if="!user.isEditorOrMore()"]'));
		browser.wait(EC.visibilityOf(viewMetadataElement), 20000).then(function(){
	    viewMetadataElement.element(by.xpath("//*[contains(text(),'Visa metadata')]")).click();
    })
  }}


});

module.exports = ViewMetadata;
