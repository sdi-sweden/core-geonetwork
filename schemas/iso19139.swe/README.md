# Swedish ISO 19139 schema plugin

This is the ISO19139 schema plugin for Swedish profile for GeoNetwork 3.x or greater version.

## Description

This plugin is composed of:

* indexing
* editing (Angular editor only)
* viewing
* CSW
* from/to ISO19139 conversion
* multilingual metadata support
* validation (XSD and Schematron)

## Metadata identification

The ISO19139 metadata containing the following element is assigned to this schema in GeoNetwork.

```
<gmd:metadataStandardName>
    <gco:CharacterString>SS-EN ISO 19115-geodata.se</gco:CharacterString>
</gmd:metadataStandardName>
```

**TODO:** Review this check


## Configuration

In catalog settings, add to `metadata/editor/schemaConfig` the editor configuration for the schema:

    "iso19139.swe":{"defaultTab":"swedish","displayToolTip":false,"related":{"display":true,"categories":[]},"suggestion":{"display":true},"validation":{"display":true}}
