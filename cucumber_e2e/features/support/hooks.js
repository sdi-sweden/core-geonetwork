
var myHooks = function () {

  this.Before(function(scenario, callback) {
    browser.manage().timeouts().pageLoadTimeout(4000);
    browser.manage().timeouts().implicitlyWait(2500);
    browser.restart();
    browser.get('https://tst.geodata.se/geodataportalen/srv/swe/catalog.search?#/search?');
    browser.ignoreSynchronization = true;

    callback();
  });


};

module.exports = myHooks;
