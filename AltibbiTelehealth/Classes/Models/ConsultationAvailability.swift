//
//  ConsultationAvailability.swift
//  AltibbiIOS
//

import Foundation

public struct ConsultationAvailableShift: Decodable {
    public let value: String?
    public let from: String?
    public let to: String?
    public let day: String?
    public let booked: Bool?
    public let fullDate: String?
    public let startAt: String?
    public let endAt: String?
    public let startsAt: String?
    public let endsAt: String?

    private enum CodingKeys: String, CodingKey {
        case value
        case from
        case to
        case day
        case booked
        case fullDate = "full_date"
        case startAt = "start_at"
        case endAt = "end_at"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
    }

    public init(from decoder: Decoder) throws {
        if let singleValue = try? decoder.singleValueContainer(),
           let stringValue = try? singleValue.decode(String.self) {
            self.value = stringValue
            self.from = nil
            self.to = nil
            self.day = nil
            self.booked = nil
            self.fullDate = nil
            self.startAt = nil
            self.endAt = nil
            self.startsAt = nil
            self.endsAt = nil
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try Self.decodeFlexibleString(from: container, forKey: .value)
        self.from = try Self.decodeFlexibleString(from: container, forKey: .from)
        self.to = try Self.decodeFlexibleString(from: container, forKey: .to)
        self.day = try Self.decodeFlexibleString(from: container, forKey: .day)
        self.booked = try container.decodeIfPresent(Bool.self, forKey: .booked)
        self.fullDate = try Self.decodeFlexibleString(from: container, forKey: .fullDate)
        self.startAt = try Self.decodeFlexibleString(from: container, forKey: .startAt)
        self.endAt = try Self.decodeFlexibleString(from: container, forKey: .endAt)
        self.startsAt = try Self.decodeFlexibleString(from: container, forKey: .startsAt)
        self.endsAt = try Self.decodeFlexibleString(from: container, forKey: .endsAt)
    }

    private static func decodeFlexibleString(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> String? {
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int.self, forKey: key) {
            return String(value)
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
        }
        if let value = try? container.decode(Bool.self, forKey: key) {
            return String(value)
        }
        return nil
    }
}

public struct ConsultationAvailableShifts: Decodable {
    public let shifts: [ConsultationAvailableShift]

    private enum CodingKeys: String, CodingKey {
        case shifts
        case data
        case availableShifts = "available_shifts"
        case availableShiftsCamel = "availableShifts"
    }

    public init(from decoder: Decoder) throws {
        if let singleValue = try? decoder.singleValueContainer(),
           let directArray = try? singleValue.decode([ConsultationAvailableShift].self) {
            self.shifts = directArray
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let availableShifts = try container.decodeIfPresent([ConsultationAvailableShift].self, forKey: .availableShifts) {
            self.shifts = availableShifts
        } else if let availableShiftsCamel = try container.decodeIfPresent([ConsultationAvailableShift].self, forKey: .availableShiftsCamel) {
            self.shifts = availableShiftsCamel
        } else if let shifts = try container.decodeIfPresent([ConsultationAvailableShift].self, forKey: .shifts) {
            self.shifts = shifts
        } else if let data = try container.decodeIfPresent([ConsultationAvailableShift].self, forKey: .data) {
            self.shifts = data
        } else {
            self.shifts = []
        }
    }
}
