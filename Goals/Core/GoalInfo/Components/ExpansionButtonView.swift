//
//  ExpansionButtonView.swift
//  Goals
//
//  Created by Work on 29/12/2023.
//

import SwiftUI

struct ExpansionButtonView: View {
    @Binding var isExpanded: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                isExpanded.toggle()
            }
        }) {
            Image(systemName: "heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .foregroundColor(isExpanded ? .red : .gray)
        }
        .padding(8)
    }
}

