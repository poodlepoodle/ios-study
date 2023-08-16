//
//  UIViewCaptureView.swift
//  SwiftUIPlayground
//
//  Created by Eojin Choi on 2023/08/02.
//

import SwiftUI

extension UIView {
    func asImage(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            layer.render(in: context.cgContext)
        }
    }
}

func convertViewToData<V>(view: V, size: CGSize, completion: @escaping (Data?) -> Void) where V: View {
    guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
        completion(nil)
        return
    }
    let imageVC = UIHostingController(rootView: view.edgesIgnoringSafeArea(.all))
    imageVC.view.frame = CGRect(origin: .zero, size: size)
    DispatchQueue.main.async {
        rootVC.view.insertSubview(imageVC.view, at: 0)
        let uiImage = imageVC.view.asImage(size: size)
        imageVC.view.removeFromSuperview()
        completion(uiImage.pngData())
    }
}

struct UIViewCaptureView: View {
    @State var imageData: Data?

    var body: some View {
        VStack {
            testView
                .frame(width: 50, height: 50)
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
            }
        }
        .onAppear {
            convertViewToData(view: testView, size: .init(width: 300, height: 300)) {
                imageData = $0
            }
        }
    }

    var testView: some View {
        ZStack {
            Color.blue
            Circle()
                .fill(Color.red)
        }
    }
}
