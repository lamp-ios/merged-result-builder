import Foundation

// Хотим
//
//{
//    "id": "1asfdasd",
//    "name" : "George",
//    "age" : 27,
//}

// Получаем по умолчанию
//{
//    {
//        "id": "1asfdasd"
//    },
//    {
//        "name" : "George"
//    },
//    {
//        "age" : 27
//    }
//}

@resultBuilder
enum MergedBuilder {
    static func buildBlock<P1: Codable>(_ p1: P1) -> P1 {
        p1
    }
    
    static func buildBlock<P1: Codable, P2: Codable>(_ p1: P1, _ p2: P2) -> Merged2<P1, P2> {
        .init(p1, p2)
    }
    
    static func buildBlock<P1: Codable, P2: Codable, P3: Codable>(_ p1: P1, _ p2: P2, _ p3: P3) -> Merged3<P1, P2, P3> {
        .init(p1, p2, p3)
    }
}

extension MergedBuilder {
    struct Merged2<P1: Codable, P2: Codable>: Codable {
        var p1: P1
        var p2: P2
        
        init(_ p1: P1, _ p2: P2) {
            self.p1 = p1
            self.p2 = p2
        }
        
        func encode(to encoder: Encoder) throws {
            try p1.encode(to: encoder)
            try p2.encode(to: encoder)
        }
    }

    struct Merged3<P1: Codable, P2: Codable, P3: Codable>: Codable {
        var p1: P1
        var p2: P2
        var p3: P3
        
        init(_ p1: P1, _ p2: P2, _ p3: P3) {
            self.p1 = p1
            self.p2 = p2
            self.p3 = p3
        }
        
        func encode(to encoder: Encoder) throws {
            try p1.encode(to: encoder)
            try p2.encode(to: encoder)
            try p3.encode(to: encoder)
        }
    }
}

struct Merged<Payload: Codable>: Codable {
    let payload: Payload
    
    init(@MergedBuilder buildPayload: () -> Payload) {
        self.payload = buildPayload()
    }
    
    func encode(to encoder: Encoder) throws {
        try payload.encode(to: encoder)
    }
}


struct IdParams: Codable {
    var id: String
}

struct UserInfo: Codable {
    var name: String
}

struct UserDetails: Codable {
    var age: Int
}

// Not universal
struct Payload: Codable {
    var id: IdParams
    var info: UserInfo
//    var details: UserDetails
    
    func encode(to encoder: Encoder) throws {
        try id.encode(to: encoder)
        try info.encode(to: encoder)
//        try details.encode(to: encoder)
    }
}


@main
struct ExampleApp {
    static func main() throws {
        
//        let payload = Payload(
//            id: .init(id: "deadbeef"),
//            info: .init(name: "George")
//            details: .init(age: 27)
//        )
        
        let payload = Merged {
            IdParams(id: "deadbeef")
            UserInfo(name: "George")
            UserDetails(age: 27)
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        
        let data = try encoder.encode(payload)
        let jsonString = String(data: data, encoding: .utf8)!
        
        print(jsonString)
    }
}
