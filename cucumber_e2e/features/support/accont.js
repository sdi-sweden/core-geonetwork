'use strict';

var UserAccount = function UserAccount(callback) {
    	//browser.get('http://localhost:8080/geonetwork/srv/eng/catalog.search?view=swe#/home');
	browser.ignoreSynchronization = true;
	this.prop = "Hello from the World!";

    this.greetings = function(name, callback) {
      console.log("\n----Hello " + name);
      callback();
    };

   // callback();

};

module.exports.World = World;

var user = ["swpojoje","lantt009"]
var psw = ["******","*******"]