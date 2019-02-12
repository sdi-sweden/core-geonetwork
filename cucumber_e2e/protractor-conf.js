
exports.config = {
  baseUrl: 'https://tst.geodata.se/geodataportalen/srv/swe/catalog.search#/home',
//  baseUrl: 'http://localhost:8080/geodataportalen',
  seleniumAddress: 'http://localhost:4444/wd/hub',
  getPageTimeout: 60000,
  allScriptsTimeout: 240000,
  framework: 'custom',
  frameworkPath: 'node_modules/protractor-cucumber-framework',
  multiCapabilities: 
    {
	  shardTestFiles: true,
	  browserName: 'chrome',
	  chromeOptions: {
            args: [
//                   'headless', 
			       'disable-gpu',			
				   'no-sandbox'
				  ]
        }	  
    },
  specs: [
    'features/HanteraFavoriter.feature',
	'features/Sok_Enkel_vy.feature',
	'features/VisaResultat.feature',
    'features/Sok_Avancerad_vy.feature',
	'features/VisaMetadata.feature',	
    'features/Sok_Generellt.feature',
	'features/VisaDoljFiltrering.feature',
	'features/VisaHjalptexter.feature',
	'features/VisaKarttjanster.feature',
	'features/VisaRekommenderadeDatasamlingar.feature'
  ],
  
  cucumberOpts: {
    require: [
    'features/support/ResultList.js',
    'features/support/env.js',
    'features/support/hooks.js',
    'features/steps/Sok_Enkel_vy.steps.js',
    'features/steps/VisaMetadata.steps.js',
    'features/steps/Sok_Avancerad_vy.steps.js',
	'features/steps/Sok_Generellt.steps.js',
    'features/steps/HanteraFavoriter.steps.js',
    'features/steps/VisaResultat.steps.js',
	'features/steps/Kartnavigering.steps.js',
	'features/steps/search.steps.js',
	'featuresEditor/steps/PubliceraMetadatapost.steps.js',
    'featuresEditor/steps/Login.steps.js',
    'featuresEditor/steps/FilterMetaDataInEditor.steps.js',
    'featuresEditor/steps/AdministrateMetadata.steps.js'
    ],

    strict: true,
	failfast: true,
    format: ['pretty', 'json:reports/report.json'],
	keepAlive: false,
	ignoreUncaughtExceptions: true,
	untrackOutstandingTimeouts: true,
    tags: '@qa_ready'  
  }
  ,
  plugins: [{
        package: 'protractor-multiple-cucumber-html-reporter-plugin',
        options:{
		    automaticallyGenerateReport: true,
            removeExistingJsonReportFile: true,
			jsonOutputPath: 'reports/',
			openReportInBrowser: true
        }
  }]
  
};
