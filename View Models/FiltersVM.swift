//
//  FiltersVM.swift
//  BygApp
//
//  Created by Manish on 21/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import UIKit

class FiltersVM {
    
    var selectedCategories = [String: String]()
    var unselectedCategories = [String: String]()
    
    var appliedFilter: Filter? {
        get {
            return GymDetailDataModel.appliedFilter
        }
        
        set {
            GymDetailDataModel.appliedFilter = newValue
        }
    }
    
    init() {
        resetCategoryLists()
    }
    
    func removeCategory(index: Int) {
        let key = Array(selectedCategories.keys)[index]
        unselectedCategories.updateValue(selectedCategories[key]!, forKey: key)
        selectedCategories.removeValueForKey(key)
    }
    
    func selectCategory(index: Int) {
        let key = Array(unselectedCategories.keys)[index]
        selectedCategories.updateValue(unselectedCategories[key]!, forKey: key)
        unselectedCategories.removeValueForKey(key)
    }
    
    func resetAllFilters() {
        appliedFilter = nil
        resetCategoryLists()
    }
    
    func selectedCategoryArray() ->[Category] {
        var categoryArray = [Category]()
        for category in GymDetailDataModel.categories {
            if selectedCategories[category.categoryID] != nil {
                categoryArray.append(category)
            }
        }
        return categoryArray
    } 
    
    private func resetCategoryLists() {
        selectedCategories.removeAll()
        unselectedCategories.removeAll()
        if let filter = appliedFilter {
            for category in filter.categories ?? [] {
                selectedCategories[category.categoryID] = category.name
            }
            
            for category in GymDetailDataModel.categories {
                if selectedCategories[category.categoryID] == nil && category.name != "All" {
                    unselectedCategories[category.categoryID] = category.name
                }
            }
        }
        else {
            for category in GymDetailDataModel.categories {
                if category.name != "All" {
                    unselectedCategories[category.categoryID] = category.name
                }
            }
        }
    }
}
