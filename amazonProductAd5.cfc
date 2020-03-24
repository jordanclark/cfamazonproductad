component {
	cfprocessingdirective( preserveCase=true );

	function init(
		required string accessKeyId
	,	required string secretAccessKey
	,	required string partnerTag
	,	string partnerType= "Associates"
	,	string defaultLanguage= ""
	,	string defaultMarketplace= ""
	,	string defaultCurrency= ""
	,	string defaultDelim= ";"
	,	string region= "us-east-1"
	,	string userAgent= "cfAmazonProductAd5/v0.2"
	,	numeric throttle= 1000
	,	numeric httpTimeOut= 120
	,	string httpMethod= "POST"
	,	boolean debug= ( request.debug ?: false )
	,	
	) {
		structAppend( this, arguments, true );
		this.setEndPoint( "webservices.amazon.com", "paapi5" );
		if( isSimpleValue( this.defaultLanguage ) ) {
			arguments.defaultLanguage= listToArray( arguments.defaultLanguage, this.defaultDelim );
		}
		this.offSet= getTimeZoneInfo().utcTotalOffset;
		this.hmacAlgorithm= "AWS4-HMAC-SHA256";
		this.aws4Request= "aws4_request";
		this.lastRequest= 0;
		this.amazonEncoding= "amz-1.0";
		this.serviceName= "ProductAdvertisingAPI"
		this.operationTargets= {
			"GetBrowseNodes"= "com.amazon.paapi5.v1.ProductAdvertisingAPIv1.GetBrowseNodes"
		,	"GetItems"= "com.amazon.paapi5.v1.ProductAdvertisingAPIv1.GetItems"
		,	"GetVariations"= "com.amazon.paapi5.v1.ProductAdvertisingAPIv1.GetVariations"
		,	"SearchItems"= "com.amazon.paapi5.v1.ProductAdvertisingAPIv1.SearchItems"
		};	
		return this;
	}

	function debugLog( required input ) {
		if( structKeyExists( request, "log" ) && isCustomFunction( request.log ) ) {
			if( isSimpleValue( arguments.input ) ) {
				request.log( "AmazonProductAd5: " & arguments.input );
			} else {
				request.log( "AmazonProductAd5: (complex type)" );
				request.log( arguments.input );
			}
		} else if( this.debug ) {
			cftrace( text=( isSimpleValue( arguments.input ) ? arguments.input : "" ), var=arguments.input, category="AmazonProductAd5", type="information" );
		}
		return;
	}

	function getWait() {
		var wait= 0;
		if( this.throttle > 0 ) {
			this.lastRequest= max( this.lastRequest, server.amzad_lastRequest ?: 0 );
			if( this.lastRequest > 0 ) {
				wait= max( this.throttle - ( getTickCount() - this.lastRequest ), 0 );
			}
		}
		return wait;
	}

	function setLastReq( numeric extra= 0 ) {
		if( this.throttle > 0 ) {
			this.lastRequest= max( getTickCount(), server.amzad_lastRequest ?: 0 ) + arguments.extra;
			server.amzad_lastRequest= this.lastRequest;
		}
	}

	function setEndPoint( required string hostName= "webservices.amazon.com", required string uri= "paapi5" ) {
		this.apiUrl= "https://#arguments.hostName#/#arguments.uri#";
		this.apiHost= arguments.hostName;
		this.apiPath= "/#arguments.uri#/";
	}

	function australiaDefaults() {
		this.defaultLanguage= [ "en_AU" ];
		this.defaultMarketplace= "www.amazon.com.au";
		this.setEndPoint( "webservices.amazon.com.au" );
		this.defaultCurrency= "AUD";
		this.region= "us-west-2";
		return this;
	}

	function brazilDefaults() {
		this.defaultLanguage= [ "pt_BR" ];
		this.defaultMarketplace= "www.amazon.com.br";
		this.setEndPoint( "webservices.amazon.com.br" );
		this.defaultCurrency= "BRL";
		this.region= "us-east-1";
		return this;
	}

	function canadaDefaults() {
		this.defaultLanguage= [ "en_CA" ];
		this.defaultMarketplace= "www.amazon.ca";
		this.setEndPoint( "webservices.amazon.ca" );
		this.defaultCurrency= "CAD";
		this.region= "us-east-1";
		return this;
	}

	function franceDefaults() {
		this.defaultLanguage= [ "fr_FR" ];
		this.defaultMarketplace= "www.amazon.fr";
		this.setEndPoint( "webservices.amazon.fr" );
		this.defaultCurrency= "EUR";
		this.region= "eu-west-1";
		return this;
	}

	function germanyDefaults( string language= "de_DE" ) {
		this.defaultLanguage= [ arguments.language ]; // cs_CZ, de_DE, en_GB, nl_NL, pl_PL, tr_TR
		this.defaultMarketplace= "www.amazon.de";
		this.setEndPoint( "webservices.amazon.de" );
		this.defaultCurrency= "EUR";
		this.region= "eu-west-1";
		return this;
	}

	function indiaDefaults() {
		this.defaultLanguage= [ "en_IN" ];
		this.defaultMarketplace= "www.amazon.in";
		this.setEndPoint( "webservices.amazon.in" );
		this.defaultCurrency= "INR";
		this.region= "eu-west-1";
		return this;
	}

	function italyDefaults() {
		this.defaultLanguage= [ "it_IT" ];
		this.defaultMarketplace= "www.amazon.it";
		this.setEndPoint( "webservices.amazon.it" );
		this.defaultCurrency= "EUR";
		this.region= "eu-west-1";
		return this;
	}

	function japanDefaults( string language= "en_US" ) {
		this.defaultLanguage= [ arguments.language ]; // en_US, ja_JP, zh_CN
		this.defaultMarketplace= "www.amazon.co.jp";
		this.setEndPoint( "webservices.amazon.co.jp" );
		this.defaultCurrency= "JPY";
		this.region= "us-west-2";
		return this;
	}

	function mexicoDefaults() {
		this.defaultLanguage= [ "es_MX" ];
		this.defaultMarketplace= "www.amazon.com.mx";
		this.setEndPoint( "webservices.amazon.com.mx" );
		this.defaultCurrency= "MXN";
		this.region= "us-east-1";
		return this;
	}

	function netherlandsDefaults() {
		this.defaultLanguage= [ "nl_NL" ];
		this.defaultMarketplace= "www.amazon.nl";
		this.setEndPoint( "webservices.amazon.nl" );
		this.defaultCurrency= "EUR";
		this.region= "eu-west-1";
		return this;
	}

	function singaporeDefaults() {
		this.defaultLanguage= [ "en_SG" ];
		this.defaultMarketplace= "www.amazon.sg";
		this.setEndPoint( "webservices.amazon.sg" );
		this.defaultCurrency= "SGD";
		this.region= "us-west-2";
		return this;
	}

	function spainDefaults() {
		this.defaultLanguage= [ "es_ES" ];
		this.defaultMarketplace= "www.amazon.es";
		this.setEndPoint( "webservices.amazon.es" );
		this.defaultCurrency= "EUR";
		this.region= "eu-west-1";
		return this;
	}

	function turkeyDefaults() {
		this.defaultLanguage= [ "tr_TR" ];
		this.defaultMarketplace= "www.amazon.com.tr";
		this.setEndPoint( "webservices.amazon.com.tr" );
		this.defaultCurrency= "TRY";
		this.region= "eu-west-1";
		return this;
	}

	function uaeDefaults( string language= "en_AE" ) {
		this.defaultLanguage= [ arguments.language ]; // en_AE, ar_AE
		this.defaultMarketplace= "www.amazon.ae";
		this.setEndPoint( "webservices.amazon.ae" );
		this.defaultCurrency= "AED";
		this.region= "eu-west-1";
		return this;
	}

	function ukDefaults() {
		this.defaultLanguage= [ "en_GB" ];
		this.defaultMarketplace= "www.amazon.co.uk";
		this.setEndPoint( "webservices.amazon.co.uk" );
		this.defaultCurrency= "GBP";
		this.region= "eu-west-1";
		return this;
	}

	function usDefaults( string language= "en_US", string currency= "USD" ) {
		this.defaultLanguage= [ arguments.language ]; // en_US, de_DE, es_US, ko_KR, pt_BR, zh_CN, zh_TW
		this.defaultMarketplace= "www.amazon.com";
		this.setEndPoint( "webservices.amazon.com" );
		this.defaultCurrency= arguments.currency; // AED,AMD,ARS,AUD,AWG,AZN,BGN,BND,BOB,BRL,BSD,BZD,CAD,CLP,CNY,COP,CRC,DOP,EGP,EUR,GBP,GHS,GTQ,HKD,HNL,HUF,IDR,ILS,INR,JMD,JPY,KES,KHR,KRW,KYD,KZT,LBP,MAD,MNT,MOP,MUR,MXN,MYR,NAD,NGN,NOK,NZD,PAB,PEN,PHP,PYG,QAR,RUB,SAR,SGD,THB,TRY,TTD,TWD,TZS,USD,UYU,VND,XCD
		this.region= "us-east-1";
		return this;
	}

	function awsV4SignReq( required string path, required string payload, required struct headers ) {
        var utcDateTime= dateConvert( "local2UTC", now() );
        var currentDate= dateFormat( utcDateTime, "YYYYMMDD" );
		var xAmzDate= currentDate & "T" & timeFormat( utcDateTime, "HHmmss") & "Z";
		// copy headers into tree
		arguments.headers[ "x-amz-date" ]= xAmzDate;
		var headerTree= createObject( "java", "java.util.TreeMap" ).init();
		for( h in arguments.headers ) {
			headerTree.put( lCase( h ), arguments.headers[ h ] );
		}
		// STEP 1: CREATE A CANONICAL REQUEST
		var canonicalURL= this.httpMethod & "\n" & arguments.path & "\n" & "" & "\n"; // queryString
		var signedHeaders= "";
		// loop over treemap, somehow the aws needs it's "natural ordering" vs a regular cf struct
		for( entry in headerTree.entrySet().toArray() ) {
			signedHeaders= listAppend( signedHeaders, entry.getKey(), ";" );
			canonicalURL &= entry.getKey() & ":" & entry.getValue() & "\n";
		}
		canonicalURL &= "\n"
			& signedHeaders & "\n"
			& lCase( hash( arguments.payload, "SHA-256" ) );
		canonicalURL= replace( canonicalURL, "\n", chr(10), "all" );
		// STEP 2: CREATE THE STRING TO SIGN
		var stringToSign= this.hmacAlgorithm & "\n"
			& xAmzDate & "\n"
			& currentDate & "/" & this.region & "/" & this.serviceName & "/" & this.aws4Request & "\n"
			& lCase( hash( canonicalUrl, "SHA-256" ) )
		stringToSign= replace( stringToSign, "\n", chr(10), "all" );
		// Step 2b: GET SIGNATURE KEY
		var signature= charsetDecode( "AWS4" & this.secretAccessKey, "UTF-8" );
		// Step 3: CALCULATE THE SIGNATURE: 
		for( var part in [ currentDate, this.region, this.serviceName, this.aws4Request, stringToSign ] ) {
			// run hmacSha256 against a series of message keys
			signature= binaryDecode( HMAC( part, signature, "HMACSHA256", "UTF-8" ), "HEX" )
		}
		signature= lCase( binaryEncode( signature, "HEX" ) );
		// Step 4: CALCULATE AUTHORIZATION HEADER
		var auth= this.hmacAlgorithm & " "
				& "Credential=" & this.accessKeyId & "/" & currentDate & "/" & this.region & "/" & this.serviceName & "/" & this.aws4Request & ","
				& "SignedHeaders=" & signedHeaders & ","
				& "Signature=" & signature;
		//headerTree.put( "authorization", auth );
		arguments.headers[ "authorization" ]= auth;
		return arguments.headers;
	}

	
	struct function apiRequest( required string operation, required struct params ) {
		var http= {};
		var out= {
			success= false
		,	error= ""
		,	status= ""
		,	statusCode= 0
		,	response= ""
		,	requestUrl= this.apiUrl & "/" & lCase( arguments.operation )
		,	requestHeaders= {
				"host"= this.apihost
			,	"content-type"= "application/json; charset=utf-8"
			,	"x-amz-target"= this.operationTargets[ arguments.operation ]
			,	"content-encoding"= this.amazonEncoding
			}
		,	payload= ""
		,	wait= 0
		};
		// serialize params to json
		out.payload= serializeJSON( arguments.params );
		// sign request with public/private keys
		this.awsV4SignReq(
			path= this.apiPath & lCase( arguments.operation )
		,	payload= out.payload
		,	headers= out.requestHeaders
		);
		// throttle requests to keep it from going too fast
		out.wait= this.getWait();
		if( out.wait > 0 ) {
			this.debugLog( "Pausing for #out.wait#/ms" );
			sleep( out.wait );
		}
		cftimer( type="debug", label="amzProductAd request" ) {
			cfhttp( result="http", method="POST", url=out.requestUrl, charset="UTF-8", throwOnError=false, timeOut=this.httpTimeOut, userAgent= this.userAgent ) {
				for( var h in out.requestHeaders ) {
					cfhttpparam( type= "header", name= h, value= out.requestHeaders[ h ] );
				}
				cfhttpparam( type= "body", value= out.payload );
			};
		}
		this.setLastReq();
		out.http= http;
		out.response= toString( http.fileContent );
		out.statusCode= http.responseHeader.Status_Code ?: 500;
		if( len( out.error ) ) {
			out.success= false;
		} else if( out.statusCode == "401" ) {
			out.error= "Error 401, unauthorized";
		} else if( out.statusCode == "429" ) {
			out.error= "Error 429, submitting requests too quickly";
			this.setLastReq( this.throttle );
		} else if( left( out.statusCode, 1 ) == "4" ) {
			out.error= "Error #out.statusCode#, transient error, resubmit.";
		} else if( left( out.statusCode, 1 ) == "5" ) {
			out.error= "Error #out.statusCode#, internal aws error";
		} else if( out.statusCode == "" ) {
			out.error= "unknown error, no status code";
		} else if( out.response == "Connection Timeout" || out.response == "Connection Failure" ) {
			out.error= out.response;
		} else if( out.statusCode != "200" ) {
			out.error= "Non-200 http response code";
		} else {
			out.success= true;
		}
		try {
			out.data= deserializeJSON( out.response );
			if( structKeyExists( out.data, "errors" ) && isArray( out.data.errors ) ) {
				for( e in out.data.errors ) {
					out.error &= e.Message & " ";
				}
			}
		} catch (any cfcatch) {
			out.error= "JSON Error: " & (cfcatch.message?:"No catch message") & " " & (cfcatch.detail?:"No catch detail");
		}
		if( len( out.error ) ) {
			out.success= false;
		}
		this.debugLog( out.statusCode & " " & out.error );
		return out;
	}

	struct function cleanArguments( args ) {
		for( a in args ) {
			if( isNull( args[ a ] ) ) {
				structDelete( args, a );
			} else if( isSimpleValue( args[ a ] ) && !len( args[ a ] ) ) {
				structDelete( args, a );
			} else if( isArray( args[ a ] ) && !arrayLen( args[ a ] ) ) {
				structDelete( args, a );
			} else if( isStruct( args[ a ] ) && structCount( args[ a ] ) == 0 ) {
				structDelete( args, a );
			}
		}
		return args;
	}

	struct function GetItems(
		required ItemIds
	,	required Resources= ""
	,	string IdType= "ASIN"
	,	string Condition= "Any" // New, Used, Collectible, Refurbished
	,	string CurrencyOfPreference= this.defaultCurrency
	,	LanguagesOfPreference= this.defaultLanguage
	,	string Marketplace= this.defaultMarketplace
	,	string Merchant= "All" // "Amazon"
	,	numeric OfferCount= 1
	,	string PartnerTag= this.PartnerTag
	,	string PartnerType= this.PartnerType
	) {
		if( isSimpleValue( arguments.ItemIds ) ) {
			arguments.ItemIds= listToArray( arguments.ItemIds, this.defaultDelim );
		}
		if( isSimpleValue( arguments.Resources ) ) {
			arguments.Resources= listToArray( arguments.Resources, this.defaultDelim );
		}
		if( len( arguments.LanguagesOfPreference ) && isSimpleValue( arguments.LanguagesOfPreference ) ) {
		 	arguments.LanguagesOfPreference= listToArray( arguments.LanguagesOfPreference, this.defaultDelim );
		}
		arguments= this.cleanArguments( arguments );
		return this.apiRequest( "GetItems", arguments );
	}

	struct function GetVariations(
		required string ASIN
	,	required Resources= ""
	,	string Condition= "Any" // New, Used, Collectible, Refurbished
	,	string CurrencyOfPreference= this.defaultCurrency
	,	LanguagesOfPreference= this.defaultLanguage
	,	string Marketplace= this.defaultMarketplace
	,	string Merchant= "All" // "Amazon"
	,	numeric OfferCount= 1
	,	numeric VariationCount= 10
	,	numeric VariationPage= 1
	,	string PartnerTag= this.PartnerTag
	,	string PartnerType= this.PartnerType
	) {
		if( isSimpleValue( arguments.Resources ) ) {
			arguments.Resources= listToArray( arguments.Resources, this.defaultDelim );
		}
		if( len( arguments.LanguagesOfPreference ) && isSimpleValue( arguments.LanguagesOfPreference ) ) {
		 	arguments.LanguagesOfPreference= listToArray( arguments.LanguagesOfPreference, this.defaultDelim );
		}
		arguments= this.cleanArguments( arguments );
		return this.apiRequest( "GetVariations", arguments );
	}

	struct function SearchItems(
		string Keywords= ""
	,	required Resources
	,	string Actor= ""
	,	string Artist= ""
	,	string Author= ""
	,	string Availability= "" // Available | IncludeOutOfStock
	,	string Brand= ""
	,	string BrowseNodeId= ""
	,	string Condition= ""
	,	string CurrencyOfPreference= this.defaultCurrency
	,	DeliveryFlags= "" // AmazonGlobal | FreeShipping | FulfilledByAmazon | Prime
	,	numeric ItemCount= 10
	,	numeric ItemPage= 1
	,	LanguagesOfPreference= this.defaultLanguage
	,	string Marketplace= this.defaultMarketplace
	,	numeric MaxPrice
	,	numeric MinPrice
	,	string Merchant= "All" // "Amazon"
	,	numeric MinReviewsRating
	,	numeric MinSavingPercent
	,	numeric OfferCount= 1
	,	Properties
	,	string SearchIndex= "All"
	,	string SortBy= "" // AvgCustomerReviews | Featured | NewestArrivals | Price:HighToLow | Price:LowToHigh | Relevance
	,	string Title= ""
	,	string PartnerTag= this.PartnerTag
	,	string PartnerType= this.PartnerType
	) {
		if( isSimpleValue( arguments.Resources ) ) {
			arguments.Resources= listToArray( arguments.Resources, this.defaultDelim );
		}
		if( structKeyExists( arguments, "DeliveryFlags" ) && isSimpleValue( arguments.DeliveryFlags ) ) {
		 	arguments.DeliveryFlags= listToArray( arguments.DeliveryFlags, this.defaultDelim );
		}
		if( len( arguments.LanguagesOfPreference ) && isSimpleValue( arguments.LanguagesOfPreference ) ) {
		 	arguments.LanguagesOfPreference= listToArray( arguments.LanguagesOfPreference, this.defaultDelim );
		}
		arguments= this.cleanArguments( arguments );
		return this.apiRequest( "SearchItems", arguments );
	}

	struct function GetBrowseNodes(
		required BrowseNodeIds
	,	required Resources
	,	LanguagesOfPreference= this.defaultLanguage
	,	string Marketplace= this.defaultMarketplace
	,	string PartnerTag= this.PartnerTag
	,	string PartnerType= this.PartnerType
	) {
		if( isSimpleValue( arguments.BrowseNodeIds ) ) {
			arguments.BrowseNodeIds= listToArray( arguments.BrowseNodeIds, this.defaultDelim );
		}
		if( isSimpleValue( arguments.Resources ) ) {
			arguments.Resources= listToArray( arguments.Resources, this.defaultDelim );
		}
		if( structKeyExists( arguments, "DeliveryFlags" ) && isSimpleValue( arguments.DeliveryFlags ) ) {
		 	arguments.DeliveryFlags= listToArray( arguments.DeliveryFlags, this.defaultDelim );
		}
		if( len( arguments.LanguagesOfPreference ) && isSimpleValue( arguments.LanguagesOfPreference ) ) {
		 	arguments.LanguagesOfPreference= listToArray( arguments.LanguagesOfPreference, this.defaultDelim );
		}
		arguments= this.cleanArguments( arguments );
		return this.apiRequest( "GetBrowseNodes", arguments );
	}


}
