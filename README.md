## KBAPISupport

Thin Swifty wrapper for NSURLSession that is strongly influenced by Moya/Alamofire.

### License

MIT

### Quickstart

````

import KBAPISupport

/// Arbitrary Decodable type
internal struct Client: Decodable {
	internal let identifier: UUID;
	internal let name: String;
	internal let balance: Decimal;
	internal let creditCardNumber: String;
}

/// Request parameters storage
internal struct MyRequest: KBAPIRequest {
	internal typealias ResponseType = [Client]; /// "Successful" response type
	
	internal let serializer = URLEncodingSerializer (); /// Serializer for reqeuest's URL, HTTP Headers and such
	
	internal let responseSerializer = JSONResponseSerializer (); /// Serializer (deserializer to be precise) dedicated to response handling
	
	/// Serves as prefix or starting point of request's URL, does not usually change during app lifetime 
	internal let baseURL = URL (string: "https://my-glorious-service.com/api/")!;
	
	/// URL "Suffix", usually differs between various request kinds.
	internal var path: String { 
		return "clients/get";
	}
	
	/// Splitting URL into base part and suffix is purely optional. One may use generic `url` property to
	/// take full control and responsibility in theirs hands. Or not.
	/// Its value is equal to `URL (string: self.path, relativeTo: self.baseURL)` by default.
	/*
	internal var url: URL {
		return URL (string: "https://en.wikipedia.org/wiki/IMJUSTVERYSHY");
	}
	*/
}


// Class that actually performs networking
KBAPIConnection (request: MyRequest ()).start {
	// Response block is called asynchronously but on main thread by default
	switch ($0) { // Response type is Optional-like enum called (surprise surpsise) Result.
		case .success (let clients):
			// Networking, backend and response decoding went well, `clients` array is containing `Client` struct instances  
			print ("Let's rock!");
			print (clients.map { $0.creditCardNumber });
		
	case .failure (let error):
		// Any other result is treated as error and is acccompanied by `error` value that contains more details about this incident.
		print ("OH NOES: \(error)");
	}
};
````

### More docs!

Please refer to documentation comments throught the library.
