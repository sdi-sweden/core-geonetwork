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

	this.Given(/^that the user is in Enkel vy$/, function (callback) {
		callback();
	});

	this.When(/^the user enters the text "([^"]*)" in the fritext field$/, function (arg1, callback) {
		browser.wait(EC.visibilityOf(searchfilter.searchElement), 20000).then(function () {
			searchfilter.freeTextSearch(arg1);
		});
		callback();
	});

	/*
	Funktion för att hämta verifiera title i resultatlistans första post
	 */
	this.Then(/^"([^"]*)" is listed$/, function (arg1, callback) {
		browser.wait(EC.visibilityOf(element(by.css('div.geo-data-list-cont'))), 20000).then(function () {
			titleElement = list.resultList.get(0).element(by.css('h1.ng-binding'));
			browser.wait(EC.textToBePresentInElement(titleElement, arg1), 50000)
			browser.wait(EC.visibilityOf(titleElement), 20000).then(function () {
				expect(titleElement.getText()).to.eventually.equal(arg1).and.notify(callback);
			});

		});
		callback();
	});
	this.Then(/^"([^"]*)" and "([^"]*)" is listed$/, function (arg1, arg2, callback) {
		browser.wait(EC.visibilityOf(element(by.css('div.geo-data-list-cont'))), 20000).then(function () {
			titleElement = list.resultList.get(0).element(by.css('h1.ng-binding'));
			browser.wait(EC.textToBePresentInElement(titleElement, arg1), 50000)
			browser.wait(EC.visibilityOf(titleElement), 20000).then(function () {
				expect(titleElement.getText()).to.eventually.equal(arg1).and.notify(callback);
			});

		});
		browser.wait(EC.visibilityOf(element(by.css('div.geo-data-list-cont'))), 20000).then(function () {
			titleElement = list.resultList.get(0).element(by.css('h1.ng-binding'));
			browser.wait(EC.textToBePresentInElement(titleElement, arg2), 50000)
			browser.wait(EC.visibilityOf(titleElement), 20000).then(function () {
				expect(titleElement.getText()).to.eventually.equal(arg2).and.notify(callback);
			});

		});
		callback();
	});

	this.When(/^the user select amne "([^"]*)"$/, function (arg1, callback) {
		searchfilter.selectCategory(arg1);
		callback();
	});

	this.When(/^the user combine amne "([^"]*)" with entering the text "([^"]*)" in the fritext field$/, function (arg1, arg2, callback) {
		searchfilter.selectCategory(arg1);
		searchfilter.freeTextSearch(arg2);
		callback();
	});

	this.Given(/^the user has clicked Amne "([^"]*)"$/, function (arg1, callback) {
		searchfilter.selectCategory(arg1);
		callback();
	});

	this.When(/^the user deselects Amne "([^"]*)"$/, function (arg1, callback) {
		searchfilter.selectCategory(arg1)
		callback();
	});

	this.When(/^clicks Amne "([^"]*)"$/, function (arg1, callback) {
		searchfilter.selectCategory(arg1)
		callback();
	});

}
