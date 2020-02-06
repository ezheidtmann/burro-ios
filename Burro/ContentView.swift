//
//  ContentView.swift
//  Burro
//
//  Created by Evan Heidtmann on 1/30/20.
//  Copyright © 2020 Evan Heidtmann. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    @State private var showDetails = false
    @State var selectedTrackingMode = TrackingState.none
    
    @EnvironmentObject var trackingStatus: TrackingViewData
 
    var body: some View {
        TabView(selection: $selection){
            VStack(alignment: .leading) {
                Button(action: {
                    self.trackingStatus.selectedTrackingState = TrackingState.none
                }) {
                    
                    Text("Tracking off")
                    .fontWeight(self.trackingStatus.selectedTrackingState == TrackingState.none ? Font.Weight.bold : Font.Weight.regular)
                    .underline(self.trackingStatus.selectedTrackingState == TrackingState.none)
                    .font(.title)
                    .shadow(radius: self.trackingStatus.selectedTrackingState == TrackingState.none ? 10 : 0)
                
                    
                }
                Button(action: {
                    self.$trackingStatus.selectedTrackingState.wrappedValue = TrackingState.toPickup
//                    self.$trackingStatus.selectedTrackingState.
                }) {
                    Text("Traveling to pickup")
                    .fontWeight(self.trackingStatus.selectedTrackingState == TrackingState.toPickup ? Font.Weight.bold : Font.Weight.regular)
                    .underline(self.trackingStatus.selectedTrackingState == TrackingState.toPickup)
                    .font(.title)
                    .shadow(radius: self.trackingStatus.selectedTrackingState == TrackingState.toPickup ? 10 : 0)
                    
                }
                Button(action: {
                    self.trackingStatus.selectedTrackingState = TrackingState.toDelivery
                }) {
                    Text("Traveling to delivery")
                    .fontWeight(self.trackingStatus.selectedTrackingState == TrackingState.toDelivery ? Font.Weight.bold : Font.Weight.regular)
                    .underline(self.trackingStatus.selectedTrackingState == TrackingState.toDelivery)
                    .font(.title)
                    .shadow(radius: self.trackingStatus.selectedTrackingState == TrackingState.toDelivery ? 10 : 0)
                }
                Text(self.trackingStatus.haveGoodGPSFix ? "Good fix" : "bad fix or no fix")
            }
                .tabItem {
                    VStack {
                        Image("first")
                        Text("First")
                    }
                }
                .tag(0)
            
            Text("Second View")
                .font(.title)
                .tabItem {
                    VStack {
                        Image("second")
                        Text("Second")
                    }
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(TrackingViewData())
    }
}
