component {
	// cfprocessingdirective( preserveCase=true );

	this.awsAccessKey= "";
	this.awsSecretKey= "";
	this.path= "";
	this.queryString= "";
	this.region= "";
	this.service= "";
	this.httpMethodName= "";
	this.headers= createObject( "java", "java.util.TreeMap" ).init();
	this.payload= "";
	this.hmacAlgorithm = "AWS4-HMAC-SHA256";
	this.aws4Request = "aws4_request";
	this.signedHeaders= "";
	this.xAmzDate= "";
	this.currentDate= "";

	function init( required string awsAccessKey, required string awsSecretKey ) {
		structAppend( this, arguments, true );
        var utcDateTime = dateConvert( "local2UTC", now() );
        this.currentDate = dateFormat( utcDateTime, "YYYYMMDD" );
		this.xAmzDate = this.currentDate & "T" & timeFormat( utcDateTime, "HHmmss") & "Z";
		return this;
	}
	
	function buildPath( string path ) {
		this.path = arguments.path;
		return this;
	}
	
	function buildQueryString( string queryString ) {
		this.queryString = arguments.queryString;
		return this;
	}
	
	function buildRegion( string region ) {
		this.region = arguments.region;
		return this;
	}

	function buildService( string service ) {
		this.service = arguments.service;
		return this;
	}
	
	function buildHttpMethodName( string httpMethodName ) {
		this.httpMethodName = arguments.httpMethodName;
		return this;
	}
	
	function buildHeaders( struct headers ) {
		this.headers= createObject( "java", "java.util.TreeMap" ).init();
		for( var h in arguments.headers ) {
			this.headers.put( h, arguments.headers[ h ] );
		}
		return this;
	}

	function buildPayload( string payload ) {
		this.payload = arguments.payload;
		return this;
	}

	function buildDate( string xAmzDate, string currentDate ) {
		this.xAmzDate = arguments.xAmzDate;
		this.currentDate = arguments.currentDate;
		return this;
	}

	function getHeaders() {
		this.headers.put( "x-amz-date", this.xAmzDate );
		// Step 1: CREATE A CANONICAL REQUEST
		var canonicalURL = this.prepareCanonicalRequest();
		// Step 2: CREATE THE STRING TO SIGN
		var stringToSign = this.prepareStringToSign( canonicalURL );
		// Step 2b: GET SIGNATURE KEY
		var signatureKey = this.getSignatureKey( this.awsSecretKey, this.currentDate, this.region, this.service );
		// Step 3: CALCULATE THE SIGNATURE
		var signature = this.calculateSignature( stringToSign, signatureKey );
		// Step 4: CALCULATE AUTHORIZATION HEADER
		this.headers.put( "authorization", this.buildAuthorizationString( signature ) );
		return this.headers;
	}

	function prepareCanonicalRequest() {
		var canonicalUrl = createObject( "java", "java.lang.StringBuilder" ).init();
		canonicalUrl.append( this.httpMethodName ).append("\n");
		canonicalUrl.append( this.path ).append("\n");
		canonicalUrl.append( this.queryString ).append("\n");
		var signedHeaderBuilder = createObject( "java", "java.lang.StringBuilder" ).init();
		if (!this.headers.isEmpty()) {
			it = this.headers.entrySet().iterator();
            while( it.hasNext() ) {
				entrySet = it.next();
                key = lCase( entrySet.getKey() );
                value = entrySet.getValue();
                signedHeaderBuilder.append(key).append(";");
                canonicalUrl.append(key).append(":").append(value).append("\n");
            }
        }
		canonicalUrl.append("\n");
		this.signedHeaders = signedHeaderBuilder.substring( 0, signedHeaderBuilder.length() - 1 );
		canonicalUrl.append( this.signedHeaders ).append("\n");
		canonicalUrl.append( this.hash256( this.payload ?: "" ) );
		return replace( canonicalUrl.toString(), "\n", chr(10), "all" );
	}

	function prepareStringToSign( string canonicalUrl ) {
		var stringToSign = this.hmacAlgorithm & "\n";
		stringToSign &= this.xAmzDate & "\n";
		stringToSign &= this.currentDate & "/" & this.region & "/" & this.service & "/" & this.aws4Request & "\n";
		stringToSign &= this.hash256( arguments.canonicalUrl );
		return replace( stringToSign, "\n", chr(10), "all" );
	}

	function calculateSignature( string stringToSign, signatureKey ) {
		signature = this.hmacSha256( arguments.signatureKey, arguments.stringToSign );
		return lCase( binaryEncode( signature, "HEX" ) );
	}

	function buildAuthorizationString( string signature ) {
		return this.hmacAlgorithm & " "
				& "Credential=" & this.awsAccessKey & "/" & this.currentDate & "/" & this.region & "/" & this.service & "/" & this.aws4Request & ","
				& "SignedHeaders=" & this.signedHeaders & ","
				& "Signature=" & arguments.signature;
	}

    function hash256( required text ){
        return lCase( hash( arguments.text, "SHA-256" ) );
	}

	function hmacSha256( required binary key, required string message ) {
		return binaryDecode( HMAC( arguments.message, arguments.key, "HMACSHA256", "UTF-8" ), "HEX" );
	}

	function getSignatureKey( string key, string date, string regionName, string serviceName ) {
		var kSecret = charsetDecode( "AWS4" & this.awsSecretKey, "UTF-8" );
		var kDate = this.hmacSha256( kSecret, arguments.date );
		var kRegion = this.hmacSha256( kDate, arguments.regionName );
		var kService = this.hmacSha256( kRegion, arguments.serviceName );
		var kSigning = this.hmacSha256( kService, this.aws4Request );
		return kSigning;
	}

}