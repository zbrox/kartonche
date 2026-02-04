//
//  BarcodeImageView.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-02-05.
//

import SwiftUI

struct BarcodeImageView: View {
    let data: String
    let type: BarcodeType
    let scale: CGFloat
    
    init(data: String, type: BarcodeType, scale: CGFloat = 10.0) {
        self.data = data
        self.type = type
        self.scale = scale
    }
    
    var body: some View {
        Group {
            switch BarcodeGenerator.generate(from: data, type: type, scale: scale) {
            case .success(let image):
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        BarcodeImageView(data: "1234567890", type: .qr)
            .frame(width: 200, height: 200)
        
        BarcodeImageView(data: "1234567890", type: .code128)
            .frame(height: 100)
        
        BarcodeImageView(data: "1234567890123", type: .ean13)
            .frame(height: 100)
    }
    .padding()
}
