//
//  ChallengesDataSource.swift
//  TopcoderMobileApp
//
//  Created by Volkov Alexander on 8/14/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import SwiftUI
import SwiftEx83
import RxSwift

/// the data source for the Challenges screen
final class ChallengesDataSource: ObservableObject {
    
    @Published var challenges: [Challenge] = []
    private var allChallenges: [Challenge] = []
    
    /// the search string
    var searchString: String = ""
    
    /// the challenges filter
    var filter: ChallengeFilter = .allActive
    
    init(challenges: [Challenge] = []) {
        if challenges.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.fetchChallenges()
            }
        }
        else {
            self.allChallenges = challenges
            applyFilters()
        }
    }
    
    /// Fetch challenges
    private func fetchChallenges() {
        let s: String? = searchString.isEmpty ? nil : searchString
        var o: Observable<[Challenge]>!
        switch filter {
        case .allActive: o = API.getAllChallenges(searchString: s)
        case .allOpen: o = API.getOpenForRegistration(searchString: s)
        case .past: o = API.getPastChallenges(searchString: s)
        case .my: o = API.getMyChallenges(searchString: s)
        default: o = API.getAllChallenges(searchString: s)
        }
        _ = o
            .subscribe(onNext: { [weak self] value in
                self?.allChallenges = value
                self?.applyFilters()
                return
            }, onError: { error in
                showError(errorMessage: error.localizedDescription)
            })
    }
    
    /// Filter by search string
    /// - Parameter searchString: the search string
    func filter(searchString: String) {
        self.searchString = searchString.trim()
        let s = self.searchString
        applyFilters()
        delay(0.5) { [weak self] in
            if s == self?.searchString {
                self?.fetchChallenges()
            }
        }
    }
    
    /// Set filter
    /// - Parameter filter: the filter
    func setFilter(_ filter: ChallengeFilter) {
        self.filter = filter
        fetchChallenges()
    }
    
    /// Applies filters
    private func applyFilters() {
        if searchString.isEmpty {
            challenges = allChallenges
        }
        else {
            let s = searchString.lowercased()
            challenges = allChallenges.filter({$0.match(s)})
        }
    }
}

extension Challenge {
    
    /// Check if challenge matches the string
    /// - Parameter string: the string
    func match(_ string: String) -> Bool {
        return name?.lowercased().contains(string) ?? false
    }
}
