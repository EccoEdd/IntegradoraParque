//
//  ViewControllerSensores.swift
//  IntegradoraParque
//
//  Created by Kobeni Higashiyama on 23/04/23.
//

import UIKit
class ViewControllerSensores: UIViewController {

    @IBOutlet weak var scrSensores: UIScrollView!
    
    var count = 0
    
    var tipo: [String] = []
    var ubicacion = [String]()
    var valor = Array<String>()
    var fecha = [String]()
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        peticion()
        if(timer == nil){
            Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(peticionTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc func peticionTimer(){
        scrSensores.subviews.forEach({$0.removeFromSuperview()})
        
        print("Polling data...")
        peticion()
        print("Success")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("6. viewWillDisappear (self.description)")
        timer?.invalidate()
        timer = nil
    }
    
    func peticion(){
        let url = URL(string: "http://3.93.149.143:3333/sensores/info")!
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(getToken())", forHTTPHeaderField: "Authorization")
        
        let conexion = URLSession(configuration: .default)
        conexion.dataTask(with: request) {datos, respuesta, error in
            do{
                let json = try JSONSerialization.jsonObject(with: datos!, options: []) as! [String:Any]
                if let dataArray = json["data"] as? [[String:Any]] {
                    for dataObject in dataArray {
                        if let sensor = dataObject["sensor"] as? [String:Any],
                            let tipo = sensor["Tipo"] as? String,
                            let ubicacion = sensor["Ubicacion"] as? String{
                            print("Tipo de sensor: \(tipo), ubicado en: \(ubicacion)")
                            
                            self.tipo.append(tipo)
                            self.ubicacion.append(ubicacion)
                        }
                        if let vale = dataObject["value"] as? String {
                            let value = vale
                            print(value)
                            self.valor.append(value)
                        }
                        if let fecha = dataObject["fecha"] as? String{
                            self.fecha.append(fecha)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.dibujarSensores()
                }
            }catch{
                print("Error al parsear el Json")
            }
        }.resume()
    }
    
    func dibujarSensores(){
        var y = 10
        for i in 0..<ubicacion.count{
            let vista = UIView(frame: CGRect(x: 10, y: y, width: Int(scrSensores.frame.width) - 20, height: 100))
            vista.backgroundColor = .lightGray
            
            let ty = UILabel(frame: CGRect(x: 10, y: 5, width: Int(vista.frame.width) - 105, height: 35))
            ty.text = String(describing: tipo[i])
            ty.font = UIFont(name: "Helvetica Neue", size: 20.0)
            ty.adjustsFontSizeToFitWidth = true
            ty.minimumScaleFactor = 0.5
            
            let vale = UILabel(frame: CGRect(x: 10, y: 40, width: Int(vista.frame.width) - 105, height: 35))
            vale.text = String(describing: valor[i])
            vale.font = UIFont(name: "Helvetica Neue", size: 40.0)
            vale.adjustsFontSizeToFitWidth = true
            vale.minimumScaleFactor = 0.5
            
            let u = UILabel(frame: CGRect(x: 150, y: 55, width: Int(vista.frame.width) - 105, height: 35))
            u.text = String(describing: ubicacion[i])
            u.font = UIFont(name: "Helvetica Neue", size: 20.0)
            u.adjustsFontSizeToFitWidth = true
            u.minimumScaleFactor = 0.5
            
            let f = UILabel(frame: CGRect(x: 150, y: 10, width: Int(vista.frame.width) - 105, height: 35))
            f.text = String(describing: fecha[i])
            f.font = UIFont(name: "Helvetica Neue", size: 10.0)
            f.adjustsFontSizeToFitWidth = true
            f.minimumScaleFactor = 0.5
            
            vista.addSubview(ty)
            vista.addSubview(vale)
            vista.addSubview(u)
            vista.addSubview(f)
            
            scrSensores.addSubview(vista)
            y += 110
        }
        
        tipo = [String]()
        ubicacion = [String]()
        valor = [String]()
        fecha = [String]()
        
        scrSensores.contentSize = CGSize(width: 0, height: y)
    }
    
    @IBAction func back(_ sender: Any) {
        timer?.invalidate()
        timer = nil
        print("Exit")
    }
    
    func getToken() -> String{
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "auth@token") ?? "nil"
    }
}
