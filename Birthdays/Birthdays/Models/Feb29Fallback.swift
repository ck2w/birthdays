//
//  Feb29Fallback.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation

enum Feb29Fallback: String, Codable, CaseIterable, Identifiable {
    case feb28

    var id: Self { self }
}
