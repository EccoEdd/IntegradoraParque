//
//  SplashViewController.swift
//  IntegradoraParque
//
//  Created by imac on 10/04/23.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet weak var imgSplash: UIImageView!
    let datos = Usuario.sharedDatos()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(getToken())
        imgSplash.frame.origin.y = view.frame.height
        imgSplash.frame.origin.x = (view.frame.width - imgSplash.frame.width)/2
    }
    
    override func viewDidAppear(_ animated: Bool){
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveLinear) {
            self.imgSplash.frame.origin.y = (self.view.frame.height - self.imgSplash.frame.height)/2
        } completion: { (res) in
            
            UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseInOut) {
                self.imgSplash.frame.origin.y = (self.view.frame.height - self.imgSplash.frame.height)*2
            } completion: { (rest) in
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timert) in
                    if(self.getToken() == "nil"){
                        self.performSegue(withIdentifier: "sgSplash", sender: nil)
                    } else {
                        self.performSegue(withIdentifier: "sgHome", sender: nil)
                    }
                }
            }
        }
    }

    func getToken() -> String{
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "auth@token") ?? "nil"
    }
    
    
}
