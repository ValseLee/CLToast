//
//  CLToastUIKitData.swift
//
//
//  Created by Celan on 3/2/24.
//

struct CLToastUIKitData {
  var style: CLToastStyle
  var animation: any CLToastUIKitAnimation
  var display: CLToastDisplaySection = .bottom
  var completion: (() -> Void)?
  
  init(
    style: CLToastStyle,
    animation: any CLToastUIKitAnimation = CLToastUIKitAnimationClient(toastAnimations: CLToastAnimations()),
    display: CLToastDisplaySection,
    completion: (() -> Void)? = nil
  ) {
    self.style = style
    self.animation = animation
    self.display = display
    self.completion = completion
  }
}

extension CLToastUIKitData: Comparable {
  static func < (lhs: CLToastUIKitData, rhs: CLToastUIKitData) -> Bool {
    lhs.style.presentPriority.rawValue < rhs.style.presentPriority.rawValue
  }
  
  static func == (lhs: CLToastUIKitData, rhs: CLToastUIKitData) -> Bool {
    lhs.style.presentPriority.rawValue == rhs.style.presentPriority.rawValue
  }
}
