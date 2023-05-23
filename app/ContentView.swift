//
//  ContentView.swift
//  PulseTick
//
//  Created by Adam Massey on 23/05/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var tokens: [Token] = []
    @State private var timer = Timer.publish(every: 30.0, on: .main, in: .common).autoconnect()
    let orderedTokenSymbols = ["PLS", "PLSX", "INC", "HEX"]

    struct Token: Identifiable {
        let id = UUID()
        let name: String
        let priceUSD: Double
    }

    struct APIResponse: Codable {
        let tokens: [String: TokenDetails]

        struct TokenDetails: Codable {
            let priceUSD: Double
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("PulseChain Ticker")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                
                HStack {
                    Text("Refresh Interval: 30s")
                        .font(.footnote)
                        .padding(.leading, 20)
                    Spacer()
                    Button(action: {
                        fetchData()
                    }) {
                        Label("Refresh Now", systemImage: "arrow.clockwise.circle.fill")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 10)
                
                List(tokens) { token in
                    HStack {
                        Image(token.name) // Use the token name to load the image
                            .resizable()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading) {
                            Text(token.name)
                            Text("\(token.priceUSD)")
                        }
                    }
                }
                
                Spacer() // Pushes the link to the bottom
                
                Link("About", destination: URL(string: "https://raw.githubusercontent.com/PulseTick/PulseTickIOS/main/About")!)
                    .padding(.bottom, 10)
            }
            .padding(.top)
        }
        .onAppear {
            fetchData()
        }
        .onReceive(timer) { _ in
            fetchData()
        }
    }

    func fetchData() {
        guard let url = URL(string: "https://plsburn.com/api") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            print(String(data: data, encoding: .utf8) ?? "")

            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    // Order the tokens based on the orderedTokenSymbols array
                    self.tokens = self.orderedTokenSymbols.compactMap { symbol in
                        guard let details = decodedData.tokens[symbol] else { return nil }
                        return Token(name: symbol, priceUSD: details.priceUSD)
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
