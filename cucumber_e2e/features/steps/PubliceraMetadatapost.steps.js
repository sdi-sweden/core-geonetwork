
//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);

var expect = chai.expect;
var Login = require('../pages/login.js');
login = new Login();
var Publicera = require('../pages/PubliceraMetadata.js');
publicera = new Publicera();
var EC = protractor.ExpectedConditions;
module.exports = function() {
 this.Given(/^that the user is loged in$/, function (callback) {
   login.loginAs("swpojoje","6EoeT5t49er");
   var nyMetadata = element(by.xpath("//*[contains(text(),'Ny metadata')]"));

    browser.wait(EC.visibilityOf(nyMetadata), 20000).then(function(){

      callback();
    })
   });

   this.Given(/^is in search page$/, function (callback) {
     var viewAllResources = element(by.xpath("//*[contains(text(),'visa alla resurser')]"))
     browser.wait(EC.visibilityOf(viewAllResources), 20000).then(function(){
       callback();
     })
   });

   this.When(/^the user clicks the button ny metadata$/, function (callback){
     var nyMetadata = element(by.xpath("//*[contains(text(),'Skapa ny metadatapost')]"));

      browser.wait(EC.visibilityOf(nyMetadata), 20000).then(function(){
        nyMetadata.element(by.xpath("..")).click();


          })
          callback();

   });

   this.Then(/^a form with templates are visible$/, function (table, callback) {
     // Write code here that turns the phrase above into concrete actions
     var tmplList = publicera.getTemplateList;
     expect(tmplList.get(0).element(by.css('span.ngr-radio-label.ng-binding')).getText()).to.eventually.equal(table.hashes()[0].templates).and.notify(callback);
     expect(tmplList.get(1).element(by.css('span.ngr-radio-label.ng-binding')).getText()).to.eventually.equal(table.hashes()[1].templates).and.notify(callback);

   });




     this.Given(/^that the user has clicked on ny metadata$/, function (callback) {
       login.loginAs("swpojoje","6EoeT5t49er");
       var nyMetadata = element(by.xpath("//*[contains(text(),'Skapa ny metadatapost')]"));

        browser.wait(EC.visibilityOf(nyMetadata), 20000).then(function(){
  nyMetadata.element(by.xpath("..")).click();

          callback();
        })

     });

       this.When(/^the user select a datamängd$/, function (callback) {
         browser.driver.sleep(3000);
         var tmplList = publicera.getTemplateList;
         var isClickable = EC.elementToBeClickable(tmplList.get(0).element(by.css('span.ngr-radio-label.ng-binding')));
         browser.wait(isClickable, 50000);

         tmplList.get(0).element(by.css('span.ngr-radio-label.ng-binding')).element(by.xpath("..")).click();
         element(by.xpath("//a[contains(text(),'Skapa')]")).click();

         callback();
       });

       this.When(/^the user select a tjänst$/, function (callback) {
         browser.driver.sleep(3000);
         var tmplList = publicera.getTemplateList;
         var isClickable = EC.elementToBeClickable(tmplList.get(1).element(by.css('span.ngr-radio-label.ng-binding')));
         browser.wait(isClickable, 50000);

         tmplList.get(1).element(by.css('span.ngr-radio-label.ng-binding')).element(by.xpath("..")).click();
         element(by.xpath("//a[contains(text(),'Skapa')]")).click();
         
         callback();
       });



     this.Then(/^the editor opens whit selected "([^"]*)"$/, function (arg1, callback) {
       // Write code here that turns the phrase above into concrete actions
       callback();
     });
}
