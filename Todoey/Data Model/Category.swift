//
//  Category.swift
//  Todoey
//
//  Created by Matej Taborsky on 16/05/2018.
//  Copyright © 2018 Matej Taborsky. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var bgColor: String = "#000000"
    
    let items = List<TodoListItem>()
}
