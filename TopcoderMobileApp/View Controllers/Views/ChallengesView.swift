//
//  ChallengesView.swift
//  TopcoderMobileApp
//
//  Created by Volkov Alexander on 8/14/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import SwiftUI
import SwiftEx83

/// the challenge filter
enum ChallengeFilter: Int {
    case allActive, allOpen, openForReview, past, my
}

/// "Challenges" screen
struct ChallengesView: View {
    
    /// the data source
    @ObservedObject var data: ChallengesDataSource = ChallengesDataSource()
    
    /// the top section index
    @State var selectedSection = 0
    /// true - if top picker is open, false - else
    @State var topPickerOpen = false
    
    enum Sections: Int, CaseIterable {
        case allChallenges, alg, gig, practice
        
        var title: String {
            switch self {
            case .allChallenges: return "All Challenges"
            case .alg: return "Competitive Programming"
            case .gig: return "Gig Work"
            case .practice: return "Practice"
            }
        }
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                if selectedSection == 0 {
                    // List
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Top button
                            Button(action: {
                                topPickerOpen = !topPickerOpen
                            }, label: {
                                HStack {
                                    Text("Compete")
                                        .medium(size: 20)
                                    Image(systemName: topPickerOpen ? "chevron.up" : "chevron.down")
                                        .bold(size: 11)
                                }
                                .foregroundColor(.black)
                                .frame(height: 50)
                            })
                        
                            SearchTextField(title: "Search for Challenge", text: Binding<String>(get: { () -> String in
                                return data.searchString
                            }, set: { (value) in
                                data.filter(searchString: value)
                            }))
                            .padding([.leading, .trailing], 10)
                            .padding([.top, .bottom], 13)
                            Divider()
                        }
                        .background(Color.white)
                        VStack(spacing: 20) {
                            ChallengeFiltersView(filter: $data.filter)
                                .environmentObject(data)
                                .block()
                            Button(action: {
                                showStub()
                            }, label: {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                    Text("More Filters")
                                        .bold(size: 11)
                                    Spacer()
                                }
                                .padding(.leading, 14)
                                .foregroundColor(Color(0x737380))
                            })
                            .block()
                            
                            ForEach(data.challenges) { item in
                                NavigationLink(
                                    destination: ChallengeDetailsView(item: item),
                                    label: {
                                        ChallengeCell(item: item)
                                    })
                            }
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                    }
                    .background(Color(UIColor(0xebebeb)))
                }
                
                // Top picker
                if topPickerOpen {
                    ZStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Sections.allCases, id: \.self) { item in
                                HStack(spacing: 13) {
                                    if selectedSection == item.rawValue {
                                        Color(0x34d4a1).frame(width: 4, height: 24)
                                        Text(item.title).semibold(size: 16)
                                    }
                                    else {
                                        Text(item.title).regular(size: 16)
                                    }
                                    Spacer()
                                }
                                .frame(height: 43)
                                .tag(item.rawValue)
                            }
                        }
                        .padding(.leading, 24)
                        .padding([.top, .bottom], 8)
                        .frame(maxWidth: .infinity)
                        Color(0x2e8c70).frame(height: 1)
                    }
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0.0, y: 10)
                    .padding(.top, 50)
                }
            }
        }
    }
}

extension View {
    
    func block() -> some View {
        self.frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.white)
            .cornerRadius(8)
    }
}

struct ChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengesView(data: ChallengesDataSource(challenges: [
            Challenge(name: "Challenge 1"),
            Challenge(name: "Challenge 2")
        ]))
    }
}
