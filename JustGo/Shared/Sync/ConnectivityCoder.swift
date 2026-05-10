import Foundation

enum ConnectivityCoder {
    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    static func encode<T: Encodable>(_ value: T) -> Data? {
        try? encoder.encode(value)
    }

    static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        try? decoder.decode(type, from: data)
    }

    static func wrapForContext<T: Encodable>(_ value: T, key: String) -> [String: Any] {
        guard let data = encode(value) else { return [:] }
        return [key: data]
    }

    static func unwrapFromContext<T: Decodable>(
        _ context: [String: Any],
        key: String,
        type: T.Type
    ) -> T? {
        guard let data = context[key] as? Data else { return nil }
        return decode(type, from: data)
    }
}
