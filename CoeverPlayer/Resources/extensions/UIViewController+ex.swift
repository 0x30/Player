//
//  UIViewController+ex.swift
//  CoeverPlayer
//
//  Created by 荆文征 on 2020/7/8.
//  Copyright © 2020 demo. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    
    var dismiss: Binder<Bool> {
        return Binder(self.base) { vc, animated in
            vc.dismiss(animated: animated, completion: nil)
        }
    }
    
    var present: Binder<UIViewController> {
        return Binder(self.base) { vc, viewController in
            vc.present(viewController, animated: true, completion: nil)
        }
    }
}
