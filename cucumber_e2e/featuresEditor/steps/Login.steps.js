var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised)
var expect = chai.expect;
var Login = require('../pages/login.js');
login = new Login();
var EC = protractor.ExpectedConditions;
module.exports = function() {

    this.Given(/^that the user has opend the portal$/, function(callback) {

        login.loginAs("lantt010", "******", function(result) {
            setTimeout(callback, 1000);
        });
    });

    this.When(/^the user go to the admin view$/, function(callback) {

        login.goToAdminView(function(result) {
            setTimeout(callback, 1000);
        });
    });

    this.When(/^I goto the contribute screen$/, function(callback) {

        login.clickOnContribute(function(result) {
            setTimeout(callback, 1000);
        });
    });

    this.Then(/^I see a list of all metadata displayed$/, function(callback) {

        login.verifyMetaDataDisplayed(function(count) {
            expect(count).to.equal(20);
            setTimeout(callback, 1000);
        });
    });

    this.Then(/^I can only work on metadata for my group$/, function(callback) {

        login.verifyOnlyWorkOnMyMetadata(function(result) {
            setTimeout(callback, 1000);
        });
    });

}
