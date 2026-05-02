import SwiftUI

struct SplashView: View {
    @State private var isShowingHome = false

    var body: some View {
        ZStack {
            if isShowingHome {
                HomeView()
                    .transition(.opacity)
            } else {
                splashContent
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.5))

            withAnimation(.easeInOut(duration: 0.35)) {
                isShowingHome = true
            }
        }
    }

    private var splashContent: some View {
        VStack(spacing: 18) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.green)
                .frame(width: 96, height: 96)
                .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 24))

            VStack(spacing: 6) {
                Text("FPL Insight")
                    .font(.largeTitle.weight(.bold))

                Text("Fantasy predictions, ready fast")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressView()
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    SplashView()
}
