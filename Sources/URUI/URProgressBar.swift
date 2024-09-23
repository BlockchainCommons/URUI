//
//  URProgressBar.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import SwiftUI

// Displays a linear progress bar.
public struct URProgressBar: View {
    @Binding var value: Double

    public init(value: Binding<Double>) {
        self._value = value
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))

                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.linear, value: value)
            }
            .cornerRadius(45.0)
        }
        .frame(height: 10)
    }
}
