//
//  KBAPIEncoder.swift
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/20/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//

import Foundation

public protocol KBAPIJSONEncoderProtocol: KBAPIEncoder {
	var outputFormatting: JSONEncoder.OutputFormatting { get set }
	var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy { get set }
	var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get set }
	var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy { get set }
	var nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy { get set }
}

public protocol KBAPIJSONDecoderProtocol: KBAPIDecoder {
	var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get set }
	var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get set }
	var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy { get set }
	var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy { get set }
}

extension JSONEncoder: KBAPIJSONEncoderProtocol {
	public static var defaultForRequestSerialization: JSONEncoder {
		let result = JSONEncoder ();
		#if DEBUG
		if #available(iOS 11.0, *) {
			result.outputFormatting = [.prettyPrinted, .sortedKeys];
		} else {
			result.outputFormatting = [.prettyPrinted];
		}
		#endif
		result.keyEncodingStrategy = .convertToSnakeCase;
		result.dateEncodingStrategy = .secondsSince1970;
		result.dataEncodingStrategy = .base64;
		result.nonConformingFloatEncodingStrategy = .convertToString (positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan");
		return result;
	}
}

extension JSONDecoder: KBAPIJSONDecoderProtocol {
	public func decode <T> (from data: Data) throws -> T where T: Decodable {
		return try self.decode (T.self, from: data);
	}
	
	public static var defaultForResponseSerialization: JSONDecoder {
		let result = JSONDecoder ();
		result.keyDecodingStrategy = .convertFromSnakeCase;
		result.dateDecodingStrategy = .secondsSince1970;
		result.dataDecodingStrategy = .base64;
		result.nonConformingFloatDecodingStrategy = .convertFromString (positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan");
		return result;
	}
}
