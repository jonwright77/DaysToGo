import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Image("DaysToGo_Splash")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
    }
}
