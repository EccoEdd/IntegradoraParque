//
//  ViewControllerHome.swift
//  IntegradoraParque
//
//  Created by Kobeni Higashiyama on 21/04/23.
//

import UIKit

class ViewControllerHome: UIViewController {

    @IBOutlet weak var scrParques: UIScrollView!
    var parques:[Parque] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        consultarSetvicio()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == "sgInfo"){
            let boton = sender as! UIButton
            let parque = parques[boton.tag]
            let vc = segue.destination as! ViewControllerInfoParque
            vc.parqueSeleccionado = parque
        }
    }

    func consultarSetvicio(){
        let url = URL(string: "http://3.93.149.143:3333/parques")!
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(getToken())", forHTTPHeaderField: "Authorization")
        
        let conexion = URLSession(configuration: .default)
        conexion.dataTask(with: request) {datos, respuesta, error in
            do{
                
                let json = try JSONSerialization.jsonObject(with: datos!, options: []) as! [String:Any]
                //print(json)
                
                if let resultados = json["data"] as? [[String:Any]]{
                    for parque in resultados{
                        print(parque)
                        self.parques.append(
                            Parque(
                                nombre: parque["nombre"] as! String, medidas: parque["medidas"] as! String, ubicacion:
                                    parque["ubicacion"] as! String, telefono: parque["telefono"] as! String, status:
                                        parque["status"] as! Int, f_agregado:parque["created_at"] as! String, id: parque["id"] as! Int
                            )
                        )
                    }
                    DispatchQueue.main.async {
                        self.dibujarParques()
                    }
                
                }else{
                    print("XD")
                }
            }catch{
                print("Error al parsear el Json")
            }
        }.resume()
 
        print(parques.count)
    }

    func getToken() -> String{
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "auth@token") ?? "nil"
    }
    
    func dibujarParques(){
        var y = 10
        for i in 0..<parques.count{
            let vista = UIView(frame: CGRect(x: 10, y: y, width: Int(scrParques.frame.width) - 20, height: 100))
            vista.backgroundColor = .lightGray
            
            let id = UILabel(frame: CGRect(x: 10, y: 5, width: Int(vista.frame.width) - 105, height: 35))
            id.text = String(describing: parques[i].id)
            id.font = UIFont(name: "Helvetica Neue", size: 20.0)
            id.adjustsFontSizeToFitWidth = true
            id.minimumScaleFactor = 0.5
            
            let nombre = UILabel(frame: CGRect(x: 0, y: 35, width: Int(vista.frame.width), height: 35))
            nombre.text = parques[i].nombre
            nombre.font = UIFont(name: "Helvetica Neue", size: 40.0)
            nombre.textAlignment = .center
            nombre.adjustsFontSizeToFitWidth = true
            nombre.minimumScaleFactor = 0.5
            
            let boton = UIButton(frame: CGRect(x: 0, y: 0, width: vista.frame.width, height: vista.frame.height))
            boton.tag = i
            boton.addTarget(self, action: #selector(seleccionarParque(sender:)), for: .touchDown)
            
            vista.addSubview(id)
            vista.addSubview(nombre)
            vista.addSubview(boton)
            
            scrParques.addSubview(vista)
            y += 110
        }
        
        scrParques.contentSize = CGSize(width: 0, height: y)
    }
    @objc func seleccionarParque(sender: UIButton){
        self.performSegue(withIdentifier: "sgInfo", sender: sender)
    }
}
