//
//  FPL Insight
//  MyTeamSharedViews.swift
//  Developed by Md Afser Uddin
//
import SwiftUI

struct MyTeamPlayerImage: View {
    let urlString: String?
    let fallbackColor: Color

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()

            default:
                Image(systemName: "person.crop.circle.fill")
                    .font(.title3)
                    .foregroundStyle(fallbackColor)
            }
        }
    }

    private var imageURL: URL? {
        guard let urlString else { return nil }
        return URL(string: urlString)
    }
}

struct MyTeamPitchBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.48, blue: 0.21),
                        Color(red: 0.04, green: 0.36, blue: 0.16)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                GeometryReader { proxy in
                    let width = proxy.size.width
                    let height = proxy.size.height

                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.45), lineWidth: 2)
                            .padding(12)

                        Rectangle()
                            .fill(.white.opacity(0.45))
                            .frame(height: 2)

                        Circle()
                            .stroke(.white.opacity(0.45), lineWidth: 2)
                            .frame(width: 96, height: 96)

                        Rectangle()
                            .stroke(.white.opacity(0.45), lineWidth: 2)
                            .frame(width: width * 0.52, height: height * 0.14)
                            .position(x: width / 2, y: 12 + height * 0.07)

                        Rectangle()
                            .stroke(.white.opacity(0.45), lineWidth: 2)
                            .frame(width: width * 0.52, height: height * 0.14)
                            .position(x: width / 2, y: height - 12 - height * 0.07)
                    }
                }
            }
    }
}
