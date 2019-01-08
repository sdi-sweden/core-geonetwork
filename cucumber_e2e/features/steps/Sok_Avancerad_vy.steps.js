
//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var ResultList = require('../pages/ResultList.js');
list = new ResultList();
var SearchFilter = require('../pages/filter.js');
searchfilter = new SearchFilter();
var EC = protractor.ExpectedConditions;
module.exports = function() {



this.Given(/^that the user is in Avancerad sokning$/, function (callback){
browser.driver.sleep(3000);
		browser.driver.manage().window().maximize();
		searchfilter.openAdvanceView;
		callback();
		});


this.When(/^the user select ansvarig "([^"]*)"$/, function (arg1, callback) {

		browser.driver.sleep(3000);
		searchfilter.selectOrganisation(arg1);

		callback();
	});


this.Then(/^"([^"]*)" is listed in AdvanceView$/, function (arg1, callback) {
	browser.driver.sleep(3000);


	titleElement = list.resultList.get(0).element(by.css('h1.ng-binding'));
	browser.wait(EC.visibilityOf(titleElement), 20000).then(function(){
		expect(titleElement.getText()).to.eventually.equal(arg1).and.notify(callback);
	});
callback();
       });



/*
 this.When(/^the user enters "([^"]*)" in the fran field$/, function (arg1, callback) {
 			// Write code here that turns the phrase above into concrete actions
 			callback();
 		});

*/

}
