//
//  ViewController.swift
//  Pushdy
//
//  Created by dangthequan on 06/27/2019.
//  Copyright (c) 2019 dangthequan. All rights reserved.
//

import UIKit
import PushdySDK
//struct ResponseData: Decodable {
//   let id: Int
//   let success: Bool
//   var banners: [Any: Decodable]
//}

class ViewController: UIViewController {
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setTitle("Subcibes", for: .normal)
        button.layer.cornerRadius = 7
        return button
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupUI(){
        self.view.backgroundColor = .systemBlue
        
        self.view.addSubview(button)
        self.button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func didTapButton(){
        print("TapButton");
        //Pushdy.subscribe();
        Pushdy.trackBanner(bannerId: "a506b0ce-1b8b-440f-b415-1acc3ade855d", type: "impression");
    }
}

