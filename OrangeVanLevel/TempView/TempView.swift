//
//  TempView.swift
//  OrangeVanLevel
//
//  Created by Roger Nolan on 05/10/2022.
//

import SwiftUI

struct TempView: View {
    var body: some View {
        Text("55C")
            .font(.system(size: 100, weight: .light, design: .none))
    }
}

struct TempView_Previews: PreviewProvider {
    static var previews: some View {
        TempView()
    }
}
