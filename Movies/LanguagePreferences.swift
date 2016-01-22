//
//  LanguagePreferences.swift
//  Movies
//
//  Created by Mathias Quintero on 12/31/15.
//  Copyright © 2015 LS1 TUM. All rights reserved.
//

import Foundation

enum LanguagePreference: String {
    
    case OriginalLanguage = "Original Language"
    case Subtitled = "Subtitled"
    case Dubbed = "Dubbed"
    case SubOrOriginal = "Subtitled Or Original Language"
    case SubOrDub = "Subtitles or Original Language"
    case NotCare = "Don't care"
    
    static func getPref(input: String) -> LanguagePreference {
        switch input {
        case OriginalLanguage.rawValue:
            return OriginalLanguage
        case Subtitled.rawValue:
            return Subtitled
        case Dubbed.rawValue:
            return Dubbed
        case SubOrOriginal.rawValue:
            return SubOrOriginal
        case SubOrDub.rawValue:
            return SubOrDub
        default:
            return NotCare
        }
    }
    
}