//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var titleElement;
var EC = protractor.ExpectedConditions;
var ResultList = require('../pages/ResultList.js');
list = new ResultList();
var SearchFilter = require('../pages/filter.js');
searchfilter = new SearchFilter();

module.exports = function () {

	this.Given(/^that filtrering is shown$/, function (callback) {
		// Write code here that turns the phrase above into concrete actions
		callback(null, 'pending');
	});

	this.When(/^the user clicks the button Direktatkomliga resurser$/, function (callback) {
		// Write code here that turns the phrase above into concrete actions
		callback(null, 'pending');
	});

	this.Then(/^Testpost_direktatkomliga_resurser_Geodatasamverkan is listed$/, function (callback) {
		// Write code here that turns the phrase above into concrete actions
		callback(null, 'pending');
	});

	this.When(/^the user clicks the button Favoriter$/, function (callback) {
		// Write code here that turns the phrase above into concrete actions
		callback(null, 'pending');
	});

	this.Then(/^Testpost_direktatkomliga_resurser_Karttjänster is listed$/, function (callback) {
		// Write code here that turns the phrase above into concrete actions
		callback(null, 'pending');
	});

	this.When(/^the user clicks the button to show Favoriter$/, function (callback) {
		// Write code here that turns the phrase above into concrete actions
		callback(null, 'pending');
	});

	this.Then(/^Titel=Testpost_Favoriter is listed$/, function (callback) {
		// Write code here that turns the phrase above into concrete actions
		callback(null, 'pending');
	});

	this.When(/^the user clicks the button to show Geoteknik$/, function (callback) {
		// Write code here that turns the phrase above into concrete actions
		callback(null, 'pending');
	});

	this.Then(/^Titel=Testpost_Geoteknik is listed$/, function (callback) {
		// Write code here that turns the phrase above into concrete actions
		callback(null, 'pending');
	});

	this.Then(/^all selected filters are cleared$/, function (callback) {
		// Write code here that turns the phrase above into concrete actions
		callback(null, 'pending');
	});

	this.Then(/^all posts are listed$/, function (callback) {
		// Write code here that turns the phrase above into concrete actions
		callback(null, 'pending');
	});

}
