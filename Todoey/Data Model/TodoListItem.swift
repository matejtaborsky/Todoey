//
//  Item.swift
//  Todoey
//
//  Created by Matej Taborsky on 16/05/2018.
//  Copyright © 2018 Matej Taborsky. All rights reserved.
//

import Foundation
import RealmSwift

class TodoListItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var status: Bool = false
    @objc dynamic var date: Date = Date()
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
