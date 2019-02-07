
//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var EC = protractor.ExpectedConditions;

var expect = chai.expect;
var ResultList = require('../pages/ResultList.js');
list = new ResultList();

var SearchFilter = require('../pages/filter.js');
searchfilter = new SearchFilter();

module.exports = function () {

	this.Given(/^that the user has a search result$/, function (callback) {
		browser.driver.manage().window().maximize();

		callback();
	});

	this.When(/^the user clicks the star next to the post "([^"]*)" that does not have a star$/, function (arg1, callback) {
		browser.wait(EC.visibilityOf(searchfilter.searchElement), 20000).then(function () {
			searchfilter.freeTextSearch(arg1);
		});

		browser.wait(EC.visibilityOf(element(by.css('div.geo-data-list-cont'))), 20000).then(function () {
			list.setPostAsFavorite(arg1);
		});
		callback();
	});

	this.Then(/^the post is added as a favorit$/, function (callback) {
//        browser.driver.sleep(3000);
    	searchfilter.toggleFavorite;
//		browser.driver.sleep(3000);
		
		var el = element(by.css('span.result-text'));
		expect(el.$('.ng-binding').getText()).to.eventually.equal('1').and.notify(callback);
//		expect(list.getNumberOfRecords()).to.equal('1').and.notify(callback);
	});

	this.Given(/^the post "([^"]*)" is a favorite$/, function (arg1, callback) {
		browser.wait(EC.visibilityOf(searchfilter.searchElement), 2000).then(function () {
			searchfilter.freeTextSearch(arg1);
		});

//		browser.driver.sleep(3000);
		list.setPostAsFavorite(arg1);
//		browser.driver.sleep(3000);

		//searchfilter.toggleFavorite;
		el = element(by.css('span.result-text'));
		expect(el.$('.ng-binding').getText()).to.eventually.equal('1').and.notify(callback);

	});

	this.When(/^the user clicks the star next to the post "([^"]*)"$/, function (arg1, callback) {
//		browser.driver.sleep(3000);
		list.setPostAsFavorite(arg1);
		callback();

	});

	this.When(/^the user clicks the yellow star next to the post "([^"]*)"$/, function (arg1, callback) {
		searchfilter.toggleFavorite;

		browser.wait(EC.visibilityOf(element(by.css('div.geo-data-list.ng-scope'))), 20000).then(function () {
			list.removePostAsFavorite(arg1);
		});
		callback();

	});

	this.Then(/^the post is removed as a favorit$/, function (callback) {
		//searchfilter.toggleFavorites;
		//searchfilter.clearFilter;

//		browser.driver.sleep(3000);
		searchfilter.toggleFavorites;

		el = element(by.css('span.result-text'));
		browser.wait(EC.visibilityOf(el), 20000).then(function () {
			expect(el.$('.ng-binding').getText()).to.eventually.equal('0').and.notify(callback);
		});
		callback();
	});

}
