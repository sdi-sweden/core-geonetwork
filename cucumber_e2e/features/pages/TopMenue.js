'use strict';

//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;

var AdvanceView = function () {};

 AdvanceView.prototype = Object.create({}, {


	 pageTitle: {get: function(){ return browser.getTitle(); }},

   

});

module.exports = AdvanceView;
