//
//  URLRequest+curl.swift
//  CPCommon
//
//  Created by Kirill Bystrov on 7/21/18.
//

#if DEBUG

import Foundation

public extension URLRequest {
	public func makeCurlCommand (verbose: Bool = true) -> String {
		guard let url = self.url else {
			return "# <nourl>";
		}
		
		var result = "curl ";
		if (verbose) {
			result += "-v ";
		}
		if let method = self.httpMethod {
			result += "-X '\(method)' ";
		}
		for header in self.allHTTPHeaderFields ?? [:] {
			result += "-H '\(header.key): \(header.value)' ";
		}
		for cookie in HTTPCookieStorage.shared.cookies (for: url) ?? [] {
			result += "-b '\(cookie.name)=\(cookie.value)' ";
		}
		if let body = self.httpBody {
			result += "-d '\(String (data: body, encoding: .utf8)!)' ";
		}
		result += "'\(url.absoluteString)'";
		return result;
	}
}

public extension NSURLRequest {
	@objc var curlCommand: String {
		return (self as URLRequest).makeCurlCommand (verbose: false);
	}
	
	@objc var verboseCurlCommand: String {
		return (self as URLRequest).makeCurlCommand (verbose: true);
	}
}

#endif
