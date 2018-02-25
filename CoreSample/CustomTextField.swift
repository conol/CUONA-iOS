//
//  CustomFields.swift
//  CoreSample
//
//  Created by mizota takaaki on 2018/02/25.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

import UIKit

class CustomTextField: UITextField
{
    //入力したテキストの余白
    override func textRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.insetBy(dx: 10.0, dy: 0.0)
    }
    
    //編集中のテキストの余白
    override func editingRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.insetBy(dx: 10.0, dy: 0.0)
    }
    
    //プレースホルダーの余白
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.insetBy(dx: 10.0, dy: 0.0)
    }
    
}
