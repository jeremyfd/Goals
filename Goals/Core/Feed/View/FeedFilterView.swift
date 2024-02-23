//
//  FeedFilterView.swift
//  Goals
//
//  Created by Jeremy Daines on 23/02/2024.
//

import SwiftUI

struct FeedFilterView: View {
    @Binding var selectedFilter: FeedFilterViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(FeedFilterViewModel.allCases) { filter in
                    Text(filter.title)
                        .foregroundColor(filter == selectedFilter ? Color.theme.primaryBackground : Color.theme.primaryText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 130, height: 42)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        }
                        .background(filter == selectedFilter ? Color.theme.primaryText : .clear)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedFilter = filter
                            }
                        }
                }
            }
            .padding(.horizontal)

        }
    }
}

//#Preview {
//    FeedFilterView()
//}
