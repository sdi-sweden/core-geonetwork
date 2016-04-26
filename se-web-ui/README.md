# se-web-ui module

## Content

This module contains a web user interface for Sweden Lantmäteriet specific features.


## Compile

Wro4j is is used to compile and manage JS dependencies.


## Check & format file

Maven build running with profile "jslint" runs:
 * fixjsstyle for fix JS style
 * gjslint for checking JS files
 
```
 mvn clean install -Pjslint
```

