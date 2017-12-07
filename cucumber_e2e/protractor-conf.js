
exports.config = {
  baseUrl: 'http://tst.geodata.se/geodataportalen/srv/swe/catalog.search?',
  seleniumAddress: 'http://localhost:4444/wd/hub',
  getPageTimeout: 60000,
  allScriptsTimeout: 500000,
  framework: 'custom',
  frameworkPath: 'node_modules/protractor-cucumber-framework',

  specs: [
    'featuresEditor/FilterMetadataInEditor.feature',
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
