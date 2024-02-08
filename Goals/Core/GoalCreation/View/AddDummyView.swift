//
//  AddDummyView.swift
//  Goals
//
//  Created by Jeremy Daines on 08/02/2024.
//

import SwiftUI

struct AddDummyView: View {
    @State private var presented = false
    @Binding var tabIndex: Int
    
    var body: some View {
        VStack { }
        .onAppear { presented = true }
        .sheet(isPresented: $presented) {
            AddView(tabIndex: $tabIndex)
                .presentationDetents([.height(200)])
                .presentationBackground(.clear)
        }
    }
}

//#Preview {
//    AddDummyView()
//}
