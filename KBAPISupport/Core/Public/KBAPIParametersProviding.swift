//
//  KBAPIParametersProviding.swift
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

import Foundation

/// A type containing data of a specific request.
public protocol KBAPIParametersProviding {
	/// A type represeting parameters for some request.
	///
	/// Speaking loosely, values of this type represent requests's "identity" amnongst
	/// other of its kind. For example, requests for user profiles are essentialy same
	/// except the identifier of the target person, requests for blog posts in specific
	/// dates range are idetifies by range's bounds, requests for sending a message from
	/// one user to another usually contain different messages and so on.
	///
	/// Separating request parameters from immutable request part is useful, when
	/// implementing requests as non-inheritable type (struct or enum), allowing
	/// to implement common logic in that type and deal with request-specific
	/// details in a request-specific type.
	associatedtype Parameters = VoidParameters where Parameters: Encodable;
	
	/// See `KBAPIRequestVoidParameters`.
	typealias VoidParameters = KBAPIRequestVoidParameters;
	
	/// Parameters value.
	var parameters: Parameters { get }
}

public extension KBAPIParametersProviding where Parameters == VoidParameters {
	public var parameters: Parameters {
		return Parameters ();
	}
}

public extension KBAPIParametersProviding where Parameters: ExpressibleByNilLiteral {
	public var parameters: Parameters {
		return nil;
	}
}

public extension KBAPIParametersProviding where Parameters: ExpressibleByArrayLiteral {
	public var parameters: Parameters {
		return Parameters ();
	}
}

public extension KBAPIParametersProviding where Parameters: ExpressibleByDictionaryLiteral {
	public var parameters: Parameters {
		return Parameters ();
	}
}

/// A value representing absense of parameters.
public struct KBAPIRequestVoidParameters: Encodable, CustomStringConvertible {
	public var description: String {
		return "none";
	}
	
	fileprivate init () {}
}
