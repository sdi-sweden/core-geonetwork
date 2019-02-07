'use strict';

//http://chaijs.com/
var chai = require('chai');

//https://github.com/domenic/chai-as-promised/
var chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
var expect = chai.expect;
var EC = protractor.ExpectedConditions;
var ResultList = function () {};

ResultList.prototype = Object.create({}, {
		resultList: {
			get: function () {
				return element.all(by.repeater('md in searchResults.records'));
			}
		},

		getPostByTitle: {
			value: function (title) {

				var reslist = element.all(by.repeater('md in searchResults.records')).map(function (post, indx) {
						return {
							title: post.element(by.css('h1.ng-binding')).getText(),
							index: indx
						}
					});
				return reslist;
			}
		},

		setPostAsFavorite: {
			value: function (title) {

				var reslist = element.all(by.repeater('md in searchResults.records')).map(function (post, indx) {
						return {
							title: post.element(by.css('h1.ng-binding')).getText(),
							index: indx
						}
					});
				reslist.then(function (res) {
					for (var i = 0; i < res.length; ++i) {
						if (title === res[i].title) {

							return element.all(by.repeater('md in searchResults.records')).get(res[i].index).element(by.css('div.star-cont')).click();

						}
					}
				});
			}
		},

		removePostAsFavorite: {
			value: function (title) {

				var reslist = element.all(by.repeater('md in searchResults.records')).map(function (post, indx) {
						return {
							title: post.element(by.css('h1.ng-binding')).getText(),
							index: indx
						}
					});
				reslist.then(function (res) {
					for (var i = 0; i < res.length; ++i) {
						if (title === res[i].title) {

							return element.all(by.repeater('md in searchResults.records')).get(res[i].index).element(by.css('div.star-cont')).click();

						}
					}
				});
			}
		},

		getNumberOfRecords: {
			get: function () {
				var el = element(by.css('span.result-text'));
				return el.$('.ng-binding');
			}
		},

		setFullViewResult: {
			get: function () {
				return element(by.css('[data-ng-click="setFullViewResults()"]')).click();
			}
		},

		setCompactViewResult: {
			get: function () {
				return element(by.css('[data-ng-click="setCompactViewResults()"]')).click()
			}
		}

	});

module.exports = ResultList;
