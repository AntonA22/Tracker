//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Codex on 27.05.2026.
//

import Foundation

#if canImport(AppMetricaCore)
import AppMetricaCore
#endif

enum AnalyticsService {
    enum Event: String {
        case open
        case close
        case click
    }

    enum Item: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete
    }

    static func activate() {
        #if canImport(AppMetricaCore)
        guard
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "AppMetricaAPIKey") as? String,
            !apiKey.isEmpty,
            apiKey != "YOUR_API_KEY"
        else {
            return
        }

        guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else { return }
        AppMetrica.activate(with: configuration)
        #endif
    }

    static func report(_ event: Event, screen: String = "Main", item: Item? = nil) {
        var parameters: [String: String] = [
            "event": event.rawValue,
            "screen": screen
        ]

        if let item {
            parameters["item"] = item.rawValue
        }

        #if DEBUG
        print("Analytics event:", parameters)
        #endif

        #if canImport(AppMetricaCore)
        AppMetrica.reportEvent(name: event.rawValue, parameters: parameters)
        #endif
    }
}
