//
//  SecondViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 2/21/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    var selectedImage = UIImage(named: "tabbar-reports-selected")
    selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
    var image = UIImage(named: "tabbar-reports")
    image = image?.imageWithRenderingMode(.AlwaysOriginal)
    tabBarItem = UITabBarItem(title: nil, image: nil, tag: 0)
    tabBarItem.image = image
    tabBarItem.selectedImage = selectedImage
    tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

    tabBarController?.tabBar.tintColor = UIColor.grayColor()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

