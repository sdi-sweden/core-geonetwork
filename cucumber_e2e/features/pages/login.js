'use strict';

//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var EC = protractor.ExpectedConditions;
var Login = function () {};

 Login.prototype = Object.create({}, {
   loginAs: {value: function(username, password){
     console.log(username)


     var loginButton = element(by.css('a.header-login.header-text'));
     browser.wait(EC.visibilityOf(loginButton), 20000).then(function(){
    element(by.css('a.header-login.header-text')).click();

     })

     var  userElement = element(by.id('USER'));
 browser.wait(EC.visibilityOf(userElement), 20000);
 userElement.sendKeys(username);

 var  pswElement = element(by.id('PASSWORD'));
browser.wait(EC.visibilityOf(pswElement), 20000);
pswElement.sendKeys(password)


    var login = element(by.buttonText('Logga in'));
     browser.wait(EC.elementToBeClickable(login),5000);
     login.click();

 

   }}


  });

module.exports = Login;
