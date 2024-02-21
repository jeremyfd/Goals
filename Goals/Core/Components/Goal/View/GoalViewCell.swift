//
//  GoalViewCell.swift
//  Goals
//
//  Created by Jeremy Daines on 05/02/2024.
//

import SwiftUI
import Kingfisher

struct GoalViewCell: View {
    @ObservedObject var viewModel: GoalViewCellViewModel
    let goal: Goal
    @State private var showReactions = false
    @Binding var selectedImageURL: String?
    @Binding var isShowingImage: Bool
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 5) {
                Text(goal.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.black)
            
                HStack {
                    CircularProfileImageView(user: goal.user, size: .small)
                    Text(goal.user?.username ?? "")
                        .font(.title2)
                        .foregroundStyle(Color.black)
                }
            }
            
            Text("Completed \(goal.currentCount) times.")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.black)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.evidences, id: \.id) { evidence in // Ensure your evidence conforms to Identifiable or provides a unique ID
                        ZStack {
                            KFImage(URL(string: evidence.imageUrl)) // Ensure this matches your model's property name
                                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 50, height: 50)))
                                .scaleFactor(UIScreen.main.scale)
                                .cacheOriginalImage()
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .cornerRadius(40)
                                .onTapGesture {
                                    selectedImageURL = evidence.imageUrl // Ensure this matches your model's property name
                                    isShowingImage = true
                                }
                            
                            if evidence.verified { // Adjust according to your actual property name
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.green)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .offset(x: 40, y: 40) // Adjusted for visibility
                            }
                        }
                    }
                    .padding(.bottom)
                }
            }
            .matchedGeometryEffect(id: "collapsedScroll", in: animation)
            
            HStack {
                ExpansionButtonView(isExpanded: $showReactions)
                
                Spacer()
                
                NavigationLink(destination: ExpandedGoalView(goal: goal)) {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(40)
    }
}

//#Preview {
//    GoalViewCell()
//}
