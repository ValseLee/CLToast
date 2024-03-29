//
//  CLToastStyle.swift
//
//
//  Created by Celan on 1/22/24.
//

import UIKit

/**
 Initialize ``CLToastStyle`` when you want to customize your toast message and toastView's detail information
 Only Required property is ``title``.
 
 Though You can initialize ``CLToastStyle`` and assign properties from outside, you can make a style with ``CLToastStyleBuilder``.
 */
public struct CLToastStyle {
  /**
   Display ToastView from given section value.
   Default value is ``.bottom``.
   */
  public var section: CLToastDisplaySection = .bottom
  
  /**
   - Properties: ToastView's Layer & Background
   */
  
  public var horizontalPadding: CGFloat = 16
  public var verticalPadding: CGFloat = 8
  
  public var layerCornerRadius: CGFloat = 16
  public var height: CGFloat = 100
  public var backgroundColor: UIColor = .systemGray2
  
  public var presentPriority: CLToastPriority = .default
  
  /**
   - Properties: ToastView
   */
  
  public var title: String
  public var description: String?
  public var timeline: String?
  public var image: UIImage?
  public var imageSize: CGSize = CGSize(width: 50, height: 50)
  
  /**
   Initialize ``CLToastStyle`` with given title.
   You can assign values to properties with your own taste.
   ToastView will be composed with ``CLToastStyle``'s own properties.
   
   - Parameter title: Toast Message's main title.
   */
  public init(title: String) {
    self.title = title
  }
}

public enum CLToastPriority: Int {
  case urgent = 3
  case `default` = 2
  case `lazy` = 1
}
