
//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var	EC = protractor.ExpectedConditions;

var expect = chai.expect;
var ResultList = require('../pages/ResultList.js');
list = new ResultList();

var SearchFilter = require('../pages/filter.js');
searchfilter = new SearchFilter();
var ViewMetadata = require('../pages/ViewMetadata.js');
viewmetadata = new ViewMetadata();

module.exports = function() {

 this.Given(/^that the user has searched for "([^"]*)"$/, function (arg1,callback) {
         // Write code here that turns the phrase above into concrete actions
			browser.wait(EC.visibilityOf(searchfilter.searchElement), 2000).then(function(){
					 searchfilter.freeTextSearch(arg1);
			});

		callback();

	 });

this.Given(/^the post "([^"]*)" is listet in resulttable$/, function (arg1, callback) {
	browser.driver.sleep(3000);

	titleElement = list.resultList.get(0).element(by.css('h1.ng-binding'));
	browser.wait(EC.visibilityOf(titleElement), 20000).then(function(){
			 expect(titleElement.getText()).to.eventually.equal(arg1).and.notify(callback);
	});
	callback();
       });


this.When(/^the user clickes on the link to visa metadata$/, function (callback) {
         // Write code here that turns the phrase above into concrete actions
				 var viewMetadataElement = list.resultList.get(0).element(by.css('[ng-if="!user.isEditorOrMore()"]'));
				browser.wait(EC.visibilityOf(viewMetadataElement), 20000).then(function(){
					viewMetadataElement.element(by.xpath("//*[contains(text(),'Visa metadata')]")).click();

				 })
				 callback();
       });


this.Then(/^metadata on the chosen tab is displayed$/, function (callback) {
	// Write code here that turns the phrase above into concrete actions
	 var oversikt =  element(by.css('a[href*="#gn-tab-introduction"]'));
	 expect(oversikt.getText()).to.eventually.equal('ÖVERSIKT');

	 var infomd =  element(by.css('a[href*="#gn-tab-metadata2"]'));
	 expect(infomd.getText()).to.eventually.equal('INFORMATION OM METADATA').and.notify(callback);
/*
	 var infodata =  element(by.css('a[href*="#gn-tab-understandResource"]'));
	 expect(infodata.getText()).to.eventually.equal('INFORMATION OM DATA');

	 var distr =  element(by.css('a[href*="#gn-tab-distributionInfo"]'));
	 expect(distr.getText()).to.eventually.equal('DISTRIBUTION');

		var kval =  element(by.css('a[href*="#gn-tab-dataQualityInfo"]'));
		expect(kval.getText()).to.eventually.equal('KVALITET');

		var kval =  element(by.css('a[href*="#gn-tab-dataQualityInfo"]'));
		expect(kval.getText()).to.eventually.equal('KVALITET');
		*/

		callback();
		});


//ÖVERSIKT  INFORMATION OM METADATA  INFORMATION OM DATA  DISTRIBUTION  KVALITET  RESTRIKTIONER  ALLA METADATA

}
