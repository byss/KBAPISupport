KBAPISupport
============

This mini-library is used to access various types of HTTP-based APIs.

Features
========

* Support for GET/POST/PUT/DELETE HTTP requests.
* This library uses **GDataXML** for XML parsing. It could be downloaded <a href="http://code.google.com/p/gdata-objectivec-client/source/browse/#svn%2Ftrunk%2FSource%2FXMLSupport">here</a>. **GDataXML** depends only on standart **libxml2** headers and binary library. By the way, **GDataXML** uses non-ARC environment, so you should set compile flag `-fno-objc-arc` for **GDataXMLNode.m** file.
* This library uses **NSJSONSerialization** for JSON parsing by default, so iOS 5.0+ is supported. You may use **SBJson** aka **json-framework**, though (<a href="https://github.com/stig/json-framework">get it here</a>), but this library was only tested with **NSJSONSerialization**.
* Autoconstructing objects from JSON/XML using AutoObjects.
* This library is suitable for ARC- and non-ARC projects (AutoObjects are supported only in non-ARC environment). The author is not quite familliar with ARC mode though so feel free to enchance nasty pieces of code.

Config
======

There is main header file called **KBAPISupport.h**, where all other headers are #imported. Amongst other, there is **KBAPISupport-config.h**, where all configuration is done:

* \#define KBAPISUPPORT\_DEBUG 0

	Turns on and off internal debug messages.

* \#define KBAPISUPPORT\_JSON 1

	Turns on and off support for server JSON responses.

* \#define KBAPISUPPORT\_USE\_SBJSON 0

	If you need to use this library on iOS 4.3 and older then you need to use **SBJson** library. Otherwise, you should use **NSJSONSerialization**, because it works faster and consumes less RAM (see e. g. <a href="http://blog.skulptstudio.com/nsjsonserialization-vs-sbjson-performance">this blog post</a>).

* \#define KBAPISUPPORT\_XML 1

	You should enable this option if you want to parse XML server responses. Depends on **GDataXMLNode.h**.

* \#define KBAPISUPPORT\_DECODE 0

	By default all parsers assume that server encoding is set to UTF-8. If this it not applicable then enable this option.

* \#define KBAPISUPPORT\_DECODE\_FROM (NSWindowsCP1251StringEncoding)

	It has effect only if KBAPISUPPORT_DECODE is nonzero. Set the server encoding here to convert responses to Apple's Unicode.
	
Usage
=====

* \#import "KBAPISupport.h"
	
	This would import all KBAPISupport features, excluding GDataXMLElement category and debug macros. Suitable for including in prefix precompiled header. You may also #import single header files.
	
* **KBAPISupport** doesn't provide any API interfaces by itself, you should extend the **KBAPIRequest** class. Every child must overload at least *-(NSString *)URL* method so that HTTP request could be performed. Of course you may add some arbitrary request properties resulting in different URL string. For example, Wikipedia API search request class may be implemented like this:

```  objective-c

#import "WikiHeader.h"

@interface WikipediaSearchRequest: KBAPIRequest

@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation WikipediaSearchRequest

- (void) dealloc {
	[_searchText release];
	
	[super dealloc];
}

- (NSString *) URL {
	return [NSString stringWithFormat:@"http://en.wikipedia.org/w/api.php?action=opensearch&search=%@&limit=%d", self.searchText, self.count];
}

+ (Class) expected {
	return [WikiHeader class];
}

@end


```

Another handy method is shown here, *+(Class)expected* method, may be used to auto-construct response objects from JSON/XML. If receiver returns some class conforming to protocol descripbed below than every API connection with this request type would attempt to create object of this class. The protocol is:

* **KBEntity**. This protocol has only one or two required methods: *+(instancetype)entityFromJSON:(id)JSON* and *+(instancetype)entityFromXML:(GDataXMLElement *)XML*. Of course if you set KBAPISUPPORT\_JSON to zero or KBAPISUPPORT\_XML to zero then first and second methods would disappear, respectively. If a class implements corresponding method for creating it from JSON or XML then it could be autoconstructed in response to some request.

* **KBAPIConnection**. This is the most important class in the library. To use it you must first create **KBAPIRequest**, then you should create **KBAPIConnection** with this request and set the delegate to receive API events such as errors, JSON, XML or autoconstructed objects receiving. Here is an example of reading flagconfig response from Wikipedia API:

```  objective-c

///////////////// WikipediaFlagconfigInfo /////////////////

@interface WikipediaFlagconfigInfo: NSObject <KBEntity>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) NSUInteger levels;
@property (nonatomic, assign) NSUInteger tier1;
@property (nonatomic, assign) NSUInteger tier2;
@property (nonatomic, assign) NSUInteger tier3;

@end

@implementation WikipediaFlagconfigInfo

- (void) dealloc {
	[_name release];
	
	[super dealloc];
}

+ (WikipediaFlagconfigInfo) entityFromJSON: (id) JSON {
	if (![JSON isKindOfClass:[NSArray class]] || ([JSON count] == 0) || ![[JSON objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
		return nil;
	}
	
	NSDictionary *flagInfoDict = [JSON objectAtIndex:0];
	WikipediaFlagconfigInfo *result = [[[self alloc] init] autorelease];

	result.name = [flagInfoDict objectForKey:@"name"];
	result.levels = [[flagInfoDict objectForKey:@"levels"] unsignedIntegerValue];
	result.tier1 = [[flagInfoDict objectForKey:@"tier1"] unsignedIntegerValue];
	result.tier2 = [[flagInfoDict objectForKey:@"tier2"] unsignedIntegerValue];
	result.tier3 = [[flagInfoDict objectForKey:@"tier3"] unsignedIntegerValue];

	return result;	
}

@end

///////////////// WikipediaFlagconfigRequest /////////////////

@interface WikipediaFlagconfigRequest: KBAPIRequest

@end

@implementation WikipediaFlagconfigRequest

- (NSString *) URL {
	return @"http://en.wikipedia.org/w/api.php?action=flagconfig&format=json";
}

+ (Class) expected {
	return [WikipediaFlagconfigInfo class];
}

@end

///////////////// some view controller or something else /////////////////

- (IBAction) buttonTapped: (id) sender {
	WikipediaFlagconfigRequest *req = [WikipediaFlagconfigRequest request];
	[[KBAPIConnection connectionWithRequest:req delegate:self] start];
}

- (void) connection: (KBAPIConnection *) connection didFailWithError:(NSError *)error {
	NSLog (@"Sorry, an error occured: %@", error);
}

- (void) connection:(KBAPIConnection *)connection didReceiveResponse: (id <KBEntity>) response {
	WikipediaFlagconfigInfo *flagInfo = response;
	NSLog (@"Fields:");
	NSLog (@"Name: %@", flagInfo.name);
	NSLog (@"Levels: %d", flagInfo.levels);
	NSLog (@"Tier1: %d", flagInfo.tier1);
	NSLog (@"Tier2: %d", flagInfo.tier2);
	NSLog (@"Tier3: %d", flagInfo.tier3);
}


```

* **KBEntityList**. API answers include arrays of similar elements very often, so there is some generic list container. Subclasses should overload method *+(Class)entityClass* to enable list autoconstructing (this method must return Class of list's elements). If you use XML you should also overload *+(NSString *)entityTag;* method to specify tag name of the list's children.

* **KBAutoEntity**. You may inherit your object from **KBAutoEntity** to use AutoObjects feature. Detailed description would be added later.

Extended Usage
==============

For more usage examples please refer to KBAPISupport Demo projects at https://github.com/byss/KBAPISupport.
