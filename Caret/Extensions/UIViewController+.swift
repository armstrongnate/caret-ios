//
//  UIViewController+.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation

extension UIViewController {

  func setupTabBarItem(imageName: String) {
    var selectedImage = UIImage(named: "tabbar-\(imageName)-selected")
    selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
    var image = UIImage(named: "tabbar-\(imageName)")
    image = image?.imageWithRenderingMode(.AlwaysOriginal)
    tabBarItem = UITabBarItem(title: nil, image: nil, tag: 0)
    tabBarItem.image = image
    tabBarItem.selectedImage = selectedImage
    tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    tabBarController?.tabBar.tintColor = UIColor.grayColor()
  }
  
}
