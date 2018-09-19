//
//  URLRequest+curl.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/21/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if DEBUG

import Foundation

public extension URLRequest {
	public func makeCurlCommand (targetSession session: URLSession = .shared, verbose: Bool = true) -> String {
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
		
		let resultingHeaders: [String: String];
		switch (self.allHTTPHeaderFields, session.configuration.httpAdditionalHeaders as? [String: String]) {
		case (nil, nil):
			resultingHeaders = [:];
		case (.some (let headers), nil), (nil, .some (let headers)):
			resultingHeaders = headers;
		case (.some (let requestHeaders), .some (let sessionHeaders)):
			resultingHeaders = requestHeaders.merging (sessionHeaders) { x, _ in x };
		}
		
		for header in resultingHeaders {
			result += "-H '\(header.key): \(header.value)' ";
		}
		for cookie in session.configuration.httpCookieStorage?.cookies (for: url) ?? [] {
			result += "-b '\(cookie.name)=\(cookie.value)' ";
		}
		
		if let body = self.httpBody {
			if (body.count < 0x1000) {
				result += "-d '\(String (data: body, encoding: .utf8)!)' ";
			} else {
				return "# request body is too long";
			}
		} else if self.httpBodyStream != nil {
			return "# request body is streamed";
		}
		
		result += "'\(url.absoluteString)'";
		return result;
	}
}

public extension NSURLRequest {
	@objc public func makeCurlCommand (targetSession session: URLSession, verbose: Bool) -> String {
		return (self as URLRequest).makeCurlCommand (targetSession: session, verbose: false);
	}
}

#endif
