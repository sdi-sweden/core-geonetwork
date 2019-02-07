
//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var	EC = protractor.ExpectedConditions;

var expect = chai.expect;
//var AngularPage = require('../pages/basic_filter.js');
var AngularPage = require('../pages/filter.js');
page = new AngularPage();
var ViewMetadata = require('../pages/viewMetadata.js');
viewmetadata = new ViewMetadata();
var KartVisare = require('../pages/kartVisare.js');
KartVisare = new KartVisare();

module.exports = function() {

/** Open the minimized map **/
 	this.Given(/^that the map is minimized$/, function (callback) {
	//	KartVisare.getMiniMizedMap;
		 callback();
		});

	this.When(/^the user clicks on the button next to the map$/, function (callback) {
	        KartVisare.extendMiniMizedMap;
				 callback();
 	});
	this.Then(/^the map is opened$/, function (callback) {

				browser.wait(EC.visibilityOf(element(by.model('activeTools.addLayers'))), 20000).then(function(){
					expect(element(by.model('activeTools.addLayers')).isDisplayed());
				})

	   callback();
 });

 /**Close the minimized map **/
  this.Given(/^that the map is open$/, function (callback) {
browser.waitForAngular();
		KartVisare.extendMiniMizedMap;


		browser.pause();
/*		browser.wait(EC.visibilityOf(element(by.model('activeTools.addLayers'))), 20000).then(function(){
			expect(element(by.model('activeTools.addLayers')).isDisplayed());
		})
*/
	  callback();
	});
	this.When(/^the user closes the map$/, function (callback) {
	//	KartVisare.closeExtendedMap;
		callback();
	});

	this.Then(/^the map is minimized$/, function (callback) {
/*	browser.wait(EC.visibilityOf(KartVisare.getMiniMizedMap), 20000).then(function(){
		expect(KartVisare.getMiniMizedMap.isDisplayed());
	});	// Write code here that turns the phrase above into concrete actions
	*/
		callback();
});


}
