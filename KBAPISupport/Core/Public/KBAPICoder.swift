//
//  KBAPIAPICoder.swift
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

/// A type that can transcode values between various formats.
public protocol KBAPICoder {
	/// Any contextual information set by the user for encoding.
	var userInfo: [CodingUserInfoKey: Any] { get set }
}

/// A type that can encode values into a native format for external representation.
public protocol KBAPIEncoder: KBAPICoder {
	/// Returns data representing an encoded version of supplied `parameters`.
	///
	/// - Parameter parameters: Value to encode.
	/// - Throws: If encoded object does not conform encoding schema for given type.
	func encode <T> (_ parameters: T) throws -> Data where T: Encodable;
}

/// A type that can decode values from a native format into in-memory representations.
public protocol KBAPIDecoder: KBAPICoder {
	/// Decodes a value of the given type.
	///
	/// - Parameter data: Raw bytes of HTTP response.
	/// - Returns: Returns a value of the type you specify, decoded from esponse data.
	/// - Throws: If supplied data are unable to conform decoding schema for given type.
	func decode <T> (from data: Data) throws -> T where T: Decodable;
	
	/// Decodes a value of the given type.
	///
	/// - Parameter data: Raw bytes of HTTP response.
	/// - Returns: Returns a value of the type you specify, decoded from esponse data.
	/// - Throws: If supplied data are unable to conform decoding schema for given type.
	func decode <T> (from data: Data?) throws -> T where T: Decodable;
	
	/// Decodes a value of the given type.
	///
	/// - Parameters:
	///   - data: Raw bytes of HTTP response.
	///   - response: Full HTTP response, including status code and headers.
	/// - Returns: Returns a value of the type you specify, decoded from esponse data.
	/// - Throws: If supplied data are unable to conform decoding schema for given type.
	///
	/// - Note: bundled decoders store this response info `userInfo` for key `CodingUserInfoKey.urlResponseKey`
	///         and chain decoding to `decode(from:)`.
	func decode <T> (from data: Data?, response: URLResponse) throws -> T where T: Decodable;
}

/// A type that can represent arbitrary values as properties of HTTP request, e.g. URL, request data, HTTP headers.
///
/// Default implementation performs only pre-serialization of the given request, assuming that conformers
/// should implement only encoder-specific algorithm details but nevertheless keeping the exact format of
/// resulting HTTP request fully under conformer's control. Specifically, following operations are performed
/// (in order) when `serializeRequest(_:)` is being invoked.
///  * Creates a new URLRequest with URL address, as specified via `url` property of serialized request.
///    Be aware that query string is generated oinly by `KBAPIURLEncodingSerializer` and types inheriting it.
///  * Sets HTTP request method as specified via `httpMethod` property.
///  * Sets common request headers, suiting for almost all use cases. Following request header fields are
///    sent unconditionally at the moment of writing:
///     - `Accept-Encoding: gzip, deflate`. Compression is always nice!
///     - `Accept: application/json`. KBAPISupport currently does not use or provide any facilities capable
///       of decoding data formats other than JSON (`JSONSerialization` and `JSONDecoder`).
///     - `Accept-Language` header. Its value is derived from `Bundle.preferredLocalizations` using
///        geometric progression `1.0, 0.5, …` for language weights.
///  * Appends HTTP headers specified via `httpHeaders` property of the request, owerwriting already serialized data.
///    Note that full set of headers is realized only when combined with URLSessionCOnfiguration's `httpAdditionalHeaders`.
///  * Obtains `asBodyData` from `shouldSerializeRequestParametersAsBodyData (for:)`.
///  * Invokes `serializeParameters(_:asBodyData:info:)` with resulting arguments to perform encoder-specific actions.
///  * After `serializeRequest(_:)` returns, the URLRequest instance that was passed as `inout` parameter is
///    returned unchenged.
/// Therefore, `serializeParameters…` has access to the common serialization logic output, only `parameters`
/// are required to be serialized by conformer if needed and is able to tweak or even abandon default request
/// handling alltogether and implement their own algorightm overriding just single method.
///
public protocol KBAPIRequestSerializerProtocol: KBAPICoder {
	/// State encoding destination for arbitrary data on per-request basis. Data size if not fixed and may be absent at all.
	///
	/// - Parameter request: Request to evaluate.
	/// - Returns: Whether such data should be encoded as part of request body (`true`) or as URL query (`false`).
	/// - Note: Default implementation returns `false` iff HTTP method for this request is GET or DELETE
	func shouldSerializeRequestParametersAsBodyData <R> (for request: R) -> Bool where R: KBAPIRequest;
	
	/// Perfoms URL request serialization, delegating request parameters encoding to `serializeParameters(_:asBodyData:info:)`.
	/// Refer to protocol description for specific implementation details.
	///
	/// - Parameter request: Request that needs serialization as HTTP request.
	/// - Returns: HTTP request that represents given request.
	/// - Throws: Does not throw any errors by itself but rethrows those throws from parameters serialization.
	func serializeRequest <R> (_ request: R) throws -> URLRequest where R: KBAPIRequest;
	
	/// Perfoms serialization of request parameters
	///
	/// - Parameters:
	///   - parameters: Parameters of request that are needed to be serialized.
	///   - asBodyData: Boolean flag indication whether `bodyData` is expected to contain any bytes after return of
	///                 this method. Note that its value is merely a hint, no additional sanity checks are performed further.
	///   - request: Pre-serialized request.
	/// - Throws: Builtin implementations do not throw; specified so that conformers were able to throw errors.
	func serializeParameters <P> (_ parameters: P, asBodyData: Bool, into request: inout URLRequest) throws where P: Encodable;
}

/// Generic version of `KBAPIDecoder` protocol
public protocol KBAPIResponseSerializerProtocol: KBAPICoder {
	/// Data type, for which this is able to perform deserialization.
	associatedtype ResponseType;
	
	/// Decodes a `ResponseType` from response data.
	///
	/// - Parameter data: Raw bytes of HTTP response.
	/// - Returns: Returns `ResponseType` instance represented by the given data.
	/// - Throws: If supplied data are unable to conform decoding schema for given type.
	func decode (from data: Data) throws -> ResponseType;
	
	/// Decodes a `ResponseType` from response data.
	///
	/// - Parameter data: Raw bytes of HTTP response.
	/// - Returns: Returns `ResponseType` instance represented by the given data.
	/// - Throws: If supplied data are unable to conform decoding schema for given type.
	func decode (from data: Data?) throws -> ResponseType;
	
	/// Decodes a `ResponseType` from response data.
	///
	/// - Parameters:
	///   - data: Raw bytes of HTTP response.
	///   - response: Full HTTP response, including status code and headers.
	/// - Returns: Returns `ResponseType` instance represented by the given data.
	/// - Throws: If supplied data are unable to conform decoding schema for given type.
	func decode (from data: Data?, response: URLResponse) throws -> ResponseType;
}
