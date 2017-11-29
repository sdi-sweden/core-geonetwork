'use strict';
var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var EC = protractor.ExpectedConditions;
var Login = function () {};
Login.prototype = Object.create({}, {
    loginAs: {value: function(username, password, callback){
       var loginUrl = 'http://tst.geodata.se/geodataportalen/login';
       browser.get(loginUrl);
//     var loginButton = element(by.css('a.header-login.header-text'));
//     browser.wait(EC.visibilityOf(loginButton), 20000).then(function(){
//     element(by.css('a.header-login.header-text')).click();
 //
//      })
       var  userElement = element(by.id('USER'));
       browser.wait(EC.visibilityOf(userElement), 20000);
       userElement.sendKeys(username);

       var  pswElement = element(by.id('PASSWORD'));
       browser.wait(EC.visibilityOf(pswElement), 20000);
       pswElement.sendKeys(password);

       var login = element(by.buttonText('Logga in'));
       browser.wait(EC.elementToBeClickable(login),5000);
       login.click().then(function(){
           callback();
       });
       }
    },
  
    goToAdminView:{value:function(callback){
       
       var adminConsoleUrl = 'http://tst.geodata.se/geodataportalen/admin.console';
       browser.get(adminConsoleUrl);
       var contribute = element.all(by.className("fa fa-plus")).first();
       browser.wait(EC.elementToBeClickable(contribute),5000).then(function(){
           callback();
       });
       
       }
    },
    
    clickOnContribute:{value:function(callback){
       var contribute = element.all(by.className("fa fa-plus")).first();
       contribute.click().then(function(){
           callback();
       })
    }
    },
    
    verifyMetaDataDisplayed:{value:function(callback){
        element.all(by.repeater('md in searchResults.records')).count().then(function(count){
            callback(count);
        });
        
       }
    },
    
    verifyOnlyWorkOnMyMetadata:{value:function(callback){
        
        var onlyMyRecordButton = element(by.model('onlyMyRecord'));
        
        onlyMyRecordButton.click().then(function(){
            
            browser.sleep(5000);
            var  triggerSearch = element(by.css('[data-ng-click="triggerSearch()"]'));
            triggerSearch.click().then(function(){
                
                
                var editButton = element(by.css('[title=Redigera]'));
                
                editButton.click();
                //console.log(editButton);
                
//                element.all(by.repeater('md in searchResults.records')).each(function(elem{
//                    
//                    element(by.css('div[title=Redigera]'));
//                    
//                }));
                
                //firstResult.
                
                browser.sleep(5000);
                callback();
                
            });
            
        });
        
       }
    }
    
 });



 module.exports = Login;