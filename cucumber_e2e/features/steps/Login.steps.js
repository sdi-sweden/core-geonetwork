
//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);

var expect = chai.expect;
var Login = require('../pages/login.js');
login = new Login();
var EC = protractor.ExpectedConditions;
module.exports = function() {

 this.Given(/^that the user has opend the portal$/, function (callback) {
					//	 element(by.css('a.header-login.header-text')).click();
								// browser.driver.manage().window().maximize();
	login.loginAs("swpojoje","6EoeT5t49er");
             // Write code here that turns the phrase above into concrete actions
             //callback();
           });


}
