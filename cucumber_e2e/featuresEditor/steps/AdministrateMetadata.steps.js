var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var assert = chai.assert;
var FilterInEditor = require('../pages/filterInEditor.js');
FilterInEditor = new FilterInEditor();
var EC = protractor.ExpectedConditions;
module.exports = function() {

    this.When(/^the user validates metadata$/, function(callback) {
        setTimeout(callback, 2000);
    });

    this.Then(/^the metadata is validated$/, function(callback) {
        setTimeout(callback, 2000);
    });

    this.Given(/^that the user has permission to edit metadata "([^"]*)"$/,
            function(title, callback) {
                setTimeout(callback, 2000);
            });
    
    this.Given(/^that the metadata is valid$/, function(callback) {
        setTimeout(callback, 2000);
    });

    this.When(/^the user publishes metadata$/, function(callback) {
        setTimeout(callback, 2000);
    });

    this.Then(/^the metadata is publised$/, function(callback) {
        setTimeout(callback, 2000);
    });

    this.Given(/^that the metadata is published$/, function(callback) {
        setTimeout(callback, 2000);
    });

    this.When(/^the user depublishes metadata$/, function(callback) {
        setTimeout(callback, 2000);
    });

    this.Then(/^the metadata is depublised$/, function(callback) {
        setTimeout(callback, 2000);
    });

    this.Given(/^that the metadata is created$/, function(callback) {
        setTimeout(callback, 2000);
    });

    this.When(/^the user deletes metadata$/, function(callback) {
        setTimeout(callback, 2000);
    });

    this.Then(/^the metadata is deleted$/, function(callback) {
        setTimeout(callback, 2000);
    });

}
