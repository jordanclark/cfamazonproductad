```
        __                                                                    _               _              _ 
  ___  / _|  __ _  _ __ ___    __ _  ____ ___   _ __   _ __   _ __  ___    __| | _   _   ___ | |_  __ _   __| |
 / __|| |_  / _` || '_ ` _ \  / _` ||_  // _ \ | '_ \ | '_ \ | '__|/ _ \  / _` || | | | / __|| __|/ _` | / _` |
| (__ |  _|| (_| || | | | | || (_| | / /| (_) || | | || |_) || |  | (_) || (_| || |_| || (__ | |_| (_| || (_| |
 \___||_|   \__,_||_| |_| |_| \__,_|/___|\___/ |_| |_|| .__/ |_|   \___/  \__,_| \__,_| \___| \__|\__,_| \__,_|
                                                      |_|                                                      
```
# cfamazonproductad
Amazon Product Advertising ColdFusion Rest API Client, new v5 API supported in amazonProductAd5.cfc, previous v4
API available in amazonProductAd

v5 has full api coverage of methods: GetBrowseNodes, GetItems, GetVariations, SearchItems, function takes the same
arguments as the REST api in AWS documentation.

Case of arguments is important, Lucee supports preserving case, but this might be an issue with Adobe ColdFusion which doesn't support "cfprocessingdirective( preserveCase=true )".

## To Install
Run the following from commandbox:
`box install cfamazonproductad`

## Example usage
```
<cfscript>
amz = new amazonProductAd5(
	accessKeyId= "XXXXYYYYYZZZZ"
,	secretAccessKey= "ABC123ABC123ABC123"
,	partnerTag= "abcdefg-20"
).usDefaults();
test= amz.SearchItems( "fred", "ItemInfo.Title" );
dump( test );
</cfscript>
```

## Changes
2020-03-23 Added support for all amazon regions/markets to v5
2020-02-23 Complete rewrite to support new PAAPI v5
2019-06-03 Open source release

## API documentation
https://webservices.amazon.com/paapi5/documentation/
https://docs.aws.amazon.com/AWSECommerceService/latest/DG/Welcome.html
