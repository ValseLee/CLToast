//
//  CLToastViewModifier.swift
//
//
//  Created by Celan on 2/12/24.
//

import SwiftUI

public struct CLToastViewModifier: ViewModifier {
  @Binding var isPresented: Bool
  @State private var isPresenting: Bool = false
  
  let animationManager: any CLToastAnimation
  let onDismiss: (() -> Void)?
  let style: CLToastStyle
  
  var toastPresentSection: Alignment {
    switch style.displayFrom {
    case .top: return .top
    case .bottom: return .bottom
    case .center: return .center
    }
  }
  
  // MARK: Initailizer
  public init(
    isPresented: Binding<Bool>,
    style: CLToastStyle,
    onDismiss: (() -> Void)? = nil
  ) {
    self.style = style
    self.animationManager = CLToastTransitionClient()
    self._isPresented = isPresented
    self.onDismiss = onDismiss
  }
  
  // MARK: - Body
  public func body(content: Content) -> some View {
    content
      .onChange(of: isPresented) { newValue in
        if style.isAnimationEnabled {
          let animation = Animation.easeInOut(duration: style.animateSpeed)
          withAnimation(animation) {
            isPresenting = newValue
          }
        } else {
          isPresenting = newValue
        }
      }
      .overlay(alignment: toastPresentSection) {
        if isPresenting {
          buildToastView()
        }
      }
  }
  
  private func dismissToast() {
    if style.isAnimationEnabled {
      let animation = Animation.easeInOut(duration: style.animateSpeed)
      withAnimation(animation) {
        isPresented = false
        isPresenting = false
      }
    } else {
      isPresented = false
      isPresenting = false
    }
  }
}

// MARK: - ViewModifier as ViewBuilder
extension CLToastViewModifier: CLToastViewBuildable {
  private var titleView: some View {
    Text(style.title)
      .foregroundColor(Color(uiColor: .label))
      .font(.title2)
  }
  
  private var descriptionView: (some View)? {
    if let description = style.description {
      Text(description)
        .foregroundColor(Color(uiColor: .label))
        .font(.footnote)
      
    } else { nil }
  }
  
  private var timelineView: (some View)? {
    if let timeline = style.timeline {
      Text(timeline)
        .foregroundColor(Color(uiColor: .secondaryLabel))
        .font(.caption)
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .bottomTrailing
        )
        .padding([.trailing, .bottom], 16)
      
    } else { nil }
  }
  
  private var imageView: (some View)? {
    if let image = style.image {
      Image(uiImage: image)
        .resizable()
      
    } else { nil }
  }
  
  @ViewBuilder
  public func buildToastView() -> (some View)? {
      ZStack {
        RoundedRectangle(cornerRadius: style.layerCornerRadius)
          .fill(Color(uiColor: style.backgroundColor))
        
        if let imageView {
          HStack(
            alignment: .center,
            spacing: 0
          ) {
            imageView
              .frame(
                width: style.imageSize.width,
                height: style.imageSize.height
              )
              .aspectRatio(contentMode: .fit)
              .padding(.leading, 16)
            
            VStack(spacing: 0) {
              titleView
              
              descriptionView
            }
            .padding(.horizontal, 16)
            
            Spacer()
          }
          
          timelineView
          
        } else {
          VStack(spacing: 0) {
            titleView
            
            descriptionView
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)
          
          timelineView
        }
      }
      .frame(height: style.height)
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 16)
      .transition(animationManager.makeAnimation(with: style) as! AnyTransition)
      .task {
        let displayTime = style.displayTimeInterval + style.animateSpeed
        try? await Task.sleep(nanoseconds: UInt64(displayTime * 1_000_000_000))
        dismissToast()
      }
      .onDisappear {
        if let onDismiss { onDismiss() }
      }
  }
}