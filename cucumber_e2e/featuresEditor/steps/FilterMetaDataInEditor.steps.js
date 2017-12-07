var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var assert = chai.assert;
var FilterInEditor = require('../pages/filterInEditor.js');
FilterInEditor = new FilterInEditor();
var Login = require('../pages/login.js');
login = new Login();
var EC = protractor.ExpectedConditions;
module.exports = function() {

 this.Given(/^that the user is in contribute view$/, function (callback) {
     login.loginAs("lantt010","*****", function(result){
         setTimeout(callback, 3000);
     });
     login.goToAdminView(function(result){
         setTimeout(callback, 3000);
     });
     login.clickOnContribute(function(result){
         setTimeout(callback, 3000);
     });
 });
 
 this.When(/^the user clicks "([^"]*)"$/, function (button, callback) {
     browser.sleep(2000);
     if (button == "show only my posts")
     {
         element(by.model('onlyMyRecord')).click();
     }
//     else if (button == "Datamängd"){
//         browser.sleep(2000);
//         var checkBox =  element.all(by.repeater('c in category | orderBy: label')).length;
//         //element.all(by.className("list-group ng-scope")).get(0);
//         console.log(checkBox);   
////         var dM =checkBox.all(by.repeater('c in category')).get(0);
////         var label = dM.element(by.xpath("//*[contains(text(),'Datamängd')]"));
////         label.click();
//         browser.sleep(2000);
//     }
     setTimeout(callback, 1000);
 });

 this.Then(/^only metadata belonging to the user should be displayed$/, function (callback) {
     setTimeout(callback, 2000); 
 });
 
 this.Then(/^only "([^"]*)" should be diplayed$/, function (arg1, callback) {
     setTimeout(callback, 2000);
 });
 
}
