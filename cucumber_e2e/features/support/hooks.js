
var myHooks = function () {

	this.Before(function (scenario, callback) {
 		browser.manage().timeouts().pageLoadTimeout(5000);
		browser.manage().timeouts().implicitlyWait(2500);
//		browser.restart();
		browser.get('https://tst.geodata.se/geodataportalen/srv/swe/catalog.search#/home');
//        browser.get('http://localhost:8080/geodataportalen');
		browser.ignoreSynchronization = true;

		callback();
	});

	// Generate a screenshot at the end of each scenario (if failed; configurable to always)
/* 	this.After(function (scenario, done) {
		browser.getProcessedConfig().then(config => {
			if (!config.screenshots.onErrorOnly || scenario.isFailed()) {
				return browser.driver.takeScreenshot().then(function (png) {
					let decodedImage = new Buffer(png.replace(/^data:image\/(png|gif|jpeg);base64,/, ''), 'base64');
					scenario.attach(decodedImage, 'image/png');
					done();
				});
			} else {
				done();
			}
		});
	});
 */
/*   	this.After(function (scenario) {
       if(scenario.result!=null){
		  if(scenario.result.exception!=null){  
            console.log("Exception is.........."+scenario.result.exception);
		  }
       }
	});
 */
};

module.exports = myHooks;
