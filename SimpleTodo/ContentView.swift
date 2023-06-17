//
//  ContentView.swift
//  SimpleTodo
//
//  Created by Isini Bandara on 2023-06-05.
//

import SwiftUI
import CoreData

struct ContentView: View {


    var body: some View {
        NavigationStack{
            Home()
                .navigationTitle("To -Do")
        }
    }


}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
