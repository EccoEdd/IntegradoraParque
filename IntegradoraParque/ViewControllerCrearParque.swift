//
//  ViewControllerCrearParque.swift
//  IntegradoraParque
//
//  Created by Kobeni Higashiyama on 20/04/23.
//

import UIKit

class ViewControllerCrearParque: UIViewController {

    @IBOutlet weak var txfNombre: UITextField!
    @IBOutlet weak var txfMedidas: UITextField!
    @IBOutlet weak var txfDireccion: UITextField!
    @IBOutlet weak var txfTelefono: UITextField!
    
    let url = URL(string: "http://3.93.149.143:3333/parque/create")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func crearParque(_ sender: Any) {
        guard let nombre = txfNombre.text, !nombre.isEmpty else{
            mostrarAlerta(mensaje: "El campo nombre no puede estar vacio")
            return
        }
        guard let medidas = txfMedidas.text, !medidas.isEmpty else{
            mostrarAlerta(mensaje: "El campo medidas no puede estar vacio")
            return
        }
        guard let direccion = txfDireccion.text, !direccion.isEmpty else{
            mostrarAlerta(mensaje: "El campo direccion no puede estar vacio")
            return
        }
        guard let telefono = txfTelefono.text, !telefono.isEmpty else{
            mostrarAlerta(mensaje: "El campo telefono no puede estar vacio")
            return
        }
        guard let _ = Int(telefono) else {
            mostrarAlerta(mensaje: "El numero no debe contener letras o algun otro simbolo")
            return
        }
        guard telefono.count == 10 else{
            mostrarAlerta(mensaje: "El codigo debe ser de exactos 10 digitos")
            return
        }
        
        let parque:[String:Any] = ["nombre": nombre, "medidas":medidas, "ubicacion":direccion, "telefono":telefono]
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: parque, options: [])
            
            print(type(of: jsonData))
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
            consumoServicio(jsonData)
        } catch {
            print("XD")
        }
    }
    
    func consumoServicio(_ parque: Data) -> Void{
        var registro = URLRequest(url: url!)
        
        registro.httpMethod = "POST"
        registro.setValue("application/json", forHTTPHeaderField: "Content-Type")
        registro.httpBody = parque
        
        let token = "Bearer " + getToken()
        registro.setValue(token, forHTTPHeaderField: "Authorization")
        
        let _ = URLSession.shared.dataTask(with: registro) { (data, response, error) in
            if let error = error {
                print("Error en la solicitud HTTP: \(error.localizedDescription)")
            } else if let respuesta = response as? HTTPURLResponse, let _ = data {
                print("Código de estado HTTP: \(respuesta.statusCode)")
                
                if respuesta.statusCode == 200{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "sgReturnHome", sender: nil)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.mostrarAlerta(mensaje: "Algo salio mal")
                }

            }
        }.resume()
    }
    
    func getToken() -> String{
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "auth@token") ?? "nil"
    }
    
    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "ALERTA!", message: mensaje, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default,handler: nil)
        alerta.addAction(ok)
        present(alerta, animated: true, completion: nil)
    }
    
}
