
exports.config = {
  baseUrl: 'https://tst.geodata.se/geodataportalen/srv/swe/catalog.search?',
  seleniumAddress: 'http://localhost:4444/wd/hub',
  getPageTimeout: 60000,
  allScriptsTimeout: 500000,
  framework: 'custom',
  frameworkPath: 'node_modules/protractor-cucumber-framework',

  specs: [
    'features/HanteraFavoriter.feature',
	'features/Sok_Enkel_vy.feature',
    'features/Sok_Avancerad_vy.feature',
	'features/VisaMetadata.feature',
	'features/VisaResultat.feature',
	'featuresEditor/Login.feature',
	'featuresEditor/FilterMetadataInEditor.feature',
    'featuresEditor/PubliceraMetadatapost.feature',
	'featuresEditor/FilterMetadataInEditor.feature'
  ],
  
  cucumberOpts: {
    require: [
    'features/support/ResultList.js',
    'features/support/env.js',
    'features/support/hooks.js',
    'features/steps/Sok_Enkel_vy.steps.js',
    'features/steps/VisaMetadata.steps.js',
    'features/steps/Sok_advance_view.steps.js',
    'features/steps/PubliceraMetadatapost.steps.js',
    'features/steps/HanteraFavoriter.steps.js',
    'features/steps/VisaResultat.steps.js',
    'featuresEditor/steps/Login.steps.js',
    'featuresEditor/steps/FilterMetaDataInEditor.steps.js',
    'featuresEditor/steps/AdministrateMetadata.steps.js'
],

    format: 'pretty',
	keepAlive: true,
   tags:[
      '~@qa_readys',
      '~@qa_todo',
      '~@qa_dev'
    ]
  }
};
