component {

	function init(
		required string accessKeyId
	,	required string secretAccessKey
	,	required string associateTag
	,	string version= "2011-08-01"
	,	string service= "AWSECommerceService"
	,	numeric throttle= 1250
	,	numeric httpTimeOut= 120
	,	boolean debug= ( request.debug ?: false )
	) {
		this.accessKeyId= arguments.accessKeyId;
		this.secretAccessKey= arguments.secretAccessKey;
		this.associateTag= arguments.associateTag;
		this.throttle= arguments.throttle;
		this.httpTimeOut= arguments.httpTimeOut;
		this.version= arguments.version;
		this.service= arguments.service;
		this.apiUrl= "http://webservices.amazon.com/onca/xml";
		this.requestHost= "webservices.amazon.com";
		this.requestURI= "/onca/xml";
		this.offSet= getTimeZoneInfo().utcTotalOffset;
		this.lastRequest= server.amzad_lastRequest ?: 0;
		return this;
	}

	function debugLog( required input ) {
		if ( structKeyExists( request, "log" ) && isCustomFunction( request.log ) ) {
			if ( isSimpleValue( arguments.input ) ) {
				request.log( "AmazonProductAd: " & arguments.input );
			} else {
				request.log( "AmazonProductAd: (complex type)" );
				request.log( arguments.input );
			}
		} else if( this.debug ) {
			cftrace( text=( isSimpleValue( arguments.input ) ? arguments.input : "" ), var=arguments.input, category="AmazonProductAd", type="information" );
		}
		return;
	}

	/**
	 * @description NSA SHA256 Algorithm
	 */
	binary function HMAC_SHA256( required string signKey, required string signMessage ) {
		var local= {};
		local.jMsg= JavaCast( "string", arguments.signMessage ).getBytes( "iso-8859-1" );
		local.jKey= JavaCast( "string", arguments.signKey ).getBytes( "iso-8859-1" );
		local.key= createObject( "java", "javax.crypto.spec.SecretKeySpec" ).init( local.jKey, "HmacSHA256" );
		local.mac= createObject( "java", "javax.crypto.Mac" );
		local.mac= local.mac.getInstance( local.key.getAlgorithm() );
		local.mac.init( local.key );
		local.mac.update( local.jMsg );
		return local.mac.doFinal();
	}

	string function zDateFormat( required date date ) {
		arguments.date= dateAdd( "s", this.offSet, arguments.date );
		return dateFormat( arguments.date, "yyyy-mm-dd" ) & "T" & timeFormat( arguments.date, "HH:mm:ss") & "Z";
	}

	struct function apiRequest( string apiMethod= "GET", required struct params, boolean parse= false ) {
		var http= {};
		var item= "";
		var key= "";
		var amp= "";
		var out= {
			success= false
		,	error= ""
		,	status= ""
		,	statusCode= 0
		,	response= ""
		,	requestUrl= this.apiUrl
		};
		arguments.block= uCase( arguments.apiMethod ) & chr(10) & this.requestHost & chr(10) & this.requestURI & chr(10);
		arguments.canonical= "";
		arguments.canonical2= "";
		if ( !structKeyExists( arguments.params, "AWSAccessKeyId" ) ) {
			arguments.params[ "AWSAccessKeyId" ]= this.accessKeyId;
		}
		if ( !structKeyExists( arguments.params, "AssociateTag" ) ) {
			arguments.params[ "AssociateTag" ]= this.associateTag;
		}
		if ( !structKeyExists( arguments.params, "Service" ) ) {
			arguments.params[ "Service" ]= this.service;
		}
		if ( !structKeyExists( arguments.params, "Version" ) ) {
			arguments.params[ "Version" ]= this.version;
		}
		if ( !structKeyExists( arguments.params, "Timestamp" ) ) {
			arguments.params[ "Timestamp" ]= zDateFormat( now(), this.offSet );
		}
		arguments.keyList= listSort( structKeyList( arguments.params ), "textnocase", "asc" );
		arguments.keyList= replace( arguments.keyList, "AssociateTag,AWSAccessKeyId", "AWSAccessKeyId,AssociateTag" );
		// Build arguments.canonical Query String 
		for ( key in arguments.keyList ) {
			arguments.canonical &= amp & key & "=" & replaceList( urlEncodedFormat( arguments.params[ key ] ), "%2D", "-" );
			amp= "&";
		}
		arguments.block &= arguments.canonical;
		arguments.params[ "Signature" ]= toBase64( HMAC_SHA256( this.secretAccessKey, arguments.block ) );
		arguments.canonical &= amp & "Signature=" & replaceList( urlEncodedFormat( arguments.params[ "Signature" ] ), "%2D", "-" );
		out.requestUrl= "#this.apiUrl#?#arguments.canonical#";
		if ( this.lastRequest > 0 && this.throttle > 0 ) {
			var wait= this.throttle - ( getTickCount() - this.lastRequest );
			if ( wait > 0 ) {
				this.debugLog( "Pausing for #wait#/ms" );
				sleep( wait );
			}
		}
		cftimer( type="debug", label="amzProductAd request" ) {
			cfhttp( result="http", method="GET", url=out.requestUrl, charset="UTF-8", throwOnError=false, timeOut=this.httpTimeOut );
			if ( this.throttle > 0 ) {
				this.lastRequest= getTickCount();
				server.amzad_lastRequest= this.lastRequest;
			}
		}
		out.response= toString( http.fileContent );
		out.statusCode= http.responseHeader.Status_Code ?: 500;
		this.debugLog( out.statusCode );
		if ( len( out.error ) ) {
			out.success= false;
		} else if ( out.statusCode == "401" ) {
			out.error= "Error 401, unauthorized";
		} else if ( out.statusCode == "503" ) {
			out.error= "Error 503, submitting requests too quickly";
		} else if ( left( out.statusCode, 1 ) == "4" ) {
			out.error= "Error #out.statusCode#, transient error, resubmit.";
		} else if ( left( out.statusCode, 1 ) == "5" ) {
			out.error= "Error #out.statusCode#, internal aws error";
		} else if ( out.statusCode == "" ) {
			out.error= "unknown error, no status code";
		} else if ( out.response == "Connection Timeout" || out.response == "Connection Failure" ) {
			out.error= out.response;
		} else if ( out.statusCode != "200" ) {
			out.error= "Non-200 http response code";
		} else if ( find( "<IsValid>False</IsValid>", out.response ) ) {
			out.error= "Invalid Request";
		} else {
			out.success= true;
		}
		// parse response 
		if ( arguments.parse ) {
			try {
				out.xml= xmlParse( out.response  );
				if ( find( "<Errors>", out.response ) ) {
					out.error= out.xml.ItemLookupResponse.Items.Request.Errors.Error.Message.XmlText;
				}
			} catch (any cfcatch) {
				out.error= "XML parse error: #cfcatch.message# #cfcatch.detail#";
			}
		}
		if ( len( out.error ) ) {
			out.success= false;
		}
		return out;
	}

	struct function ItemLookup(
		required string ItemID
	,	string ResponseGroup= ""
	,	string SearchIndex= "All"
	,	string IdType= ""
	,	string Condition= ""
	,	string MerchantId= ""
	,	boolean parse= false
	) {
		var params= {};
		if ( !len( arguments.IdType ) ) {
			arguments.IdType= "ASIN";
		}
		if ( arguments.IdType == "ASIN" ) {
			arguments.SearchIndex= "";
		}
		params[ "Operation" ]= "ItemLookup";
		params[ "ItemId" ]= arguments.ItemID;
		if ( len( arguments.ResponseGroup ) ) {
			params[ "ResponseGroup" ]= arguments.ResponseGroup;
		}
		if ( len( arguments.SearchIndex ) ) {
			params[ "SearchIndex" ]= arguments.SearchIndex;
		}
		if ( len( arguments.IdType ) ) {
			params[ "IdType" ]= arguments.IdType;
		}
		if ( len( arguments.Condition ) ) {
			params[ "Condition" ]= arguments.Condition;
		}
		if ( len( arguments.MerchantId ) ) {
			params[ "MerchantId" ]= arguments.MerchantId;
		}
		return this.apiRequest( apiMethod= "GET", params= params, parse= parse );
	}

	struct function ItemLookupBatch(
		required ItemIDs
	,	string ResponseGroup= ""
	,	string SearchIndex= "All"
	,	string IdType= ""
	,	string Condition= ""
	,	string MerchantId= ""
	,	boolean parse= false
	) {
		var params= {};
		var x= 0;
		if ( !len( arguments.IdType ) ) {
			arguments.IdType= "ASIN";
		}
		if ( arguments.IdType == "ASIN" ) {
			arguments.SearchIndex= "";
		}
		params[ "Operation" ]= "ItemLookup";
		for ( x=1 ; x<=arrayLen( arguments.itemIDs ) ; x++ ) {
			params[ "ItemLookup.#x#.ItemId" ]= arguments.itemIDs[ x ];
		}
		if ( len( arguments.ResponseGroup ) ) {
			params[ "ItemLookup.Shared.ResponseGroup" ]= arguments.ResponseGroup;
		}
		if ( len( arguments.SearchIndex ) ) {
			params[ "ItemLookup.Shared.SearchIndex" ]= arguments.SearchIndex;
		}
		if ( len( arguments.IdType ) ) {
			params[ "ItemLookup.Shared.IdType" ]= arguments.IdType;
		}
		if ( len( arguments.Condition ) ) {
			params[ "ItemLookup.Shared.Condition" ]= arguments.Condition;
		}
		if ( len( arguments.MerchantId ) ) {
			params[ "ItemLookup.Shared.MerchantId" ]= arguments.MerchantId;
		}
		return this.apiRequest( apiMethod= "GET", params= params, parse= parse );
	}

	struct function ItemSearch(
		string Keywords= ""
	,	string ResponseGroup= "small"
	,	string SearchIndex= "All"
	,	string Condition= "New"
	,	string Node= ""
	,	string Title= ""
	,	string MinPrice= ""
	,	string MaxPrice= ""
	,	string Page= 1
	,	boolean parse= false
	) {
		// 1-10 
		var params= {
			"Operation"= "ItemSearch"
		,	"ItemPage"= arguments.page
		,	"ResponseGroup"= arguments.ResponseGroup
		,	"SearchIndex"= arguments.SearchIndex
		,	"Condition"= arguments.condition
		};
		if ( len( arguments.node ) ) {
			params[ "BrowseNode" ]= arguments.node;
		}
		if ( len( arguments.title ) ) {
			params[ "Title" ]= arguments.title;
		}
		if ( len( arguments.minPrice ) ) {
			params[ "MinimumPrice" ]= arguments.minPrice;
		}
		if ( len( arguments.maxPrice ) ) {
			params[ "MaximumPrice" ]= arguments.maxPrice;
		}
		return this.apiRequest( apiMethod= "GET", params= params, parse= parse );
	}

	struct function SimilarityLookup(
		required string ItemID
	,	string SimilarityType= ""
	,	string ResponseGroup= ""
	,	string Condition= ""
	,	boolean parse= false
	) {
		var params= {
			"Operation"= "SimilarityLookup"
		,	"ItemId"= arguments.ItemID
		};
		if ( len( arguments.SimilarityType ) ) {
			params[ "SimilarityType" ]= arguments.SimilarityType;
		}
		if ( len( arguments.ResponseGroup ) ) {
			params[ "ResponseGroup" ]= arguments.ResponseGroup;
		}
		if ( len( arguments.condition ) ) {
			params[ "Condition" ]= arguments.condition;
		}
		return this.apiRequest( apiMethod= "GET", params= params, parse= parse );
	}

	// public struct function TagLookup(
	// 	required string TagName
	// ,	string ResponseGroup= ""
	// ,	required string Count
	// ,	boolean parse= false
	// ) {
	// 	var params= {
	// 	,	"Operation"= "TagLookup"
	// 	,	"TagName"= arguments.TagName
	//	};
	// 	if ( len( arguments.ResponseGroup ) ) {
	// 		params[ "ResponseGroup" ]= arguments.ResponseGroup;
	// 	}
	// 	if ( len( arguments.Count ) ) {
	// 		params[ "Count" ]= arguments.Count;
	// 	}
	// 	return this.apiRequest( apiMethod= "GET", params= params, parse= parse );
	// }

	struct function CartCreate(
		required string ItemID
	,	string Quantity= 1
	,	boolean parse= false
	) {
		var params= {
			"Operation"= "CartCreate"
		};
		var x= 1;
		var i= "";
		for ( i in arguments.itemID ) {
			params[ "Item.#x#.ASIN" ]= i;
			params[ "Item.#x#.Quantity" ]= ( find( ",", arguments.Quantity ) >= x ? listGetAt( arguments.Quantity, x ) : arguments.Quantity );
		}
		return this.apiRequest( apiMethod= "GET", params= params, parse= parse );
	}

}
