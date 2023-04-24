//
//  ViewControllerEditParque.swift
//  IntegradoraParque
//
//  Created by Kobeni Higashiyama on 23/04/23.
//

import UIKit

class ViewControllerEditParque: UIViewController {

    @IBOutlet weak var txfDireccion: UITextField!
    @IBOutlet weak var txfMedidas: UITextField!
    @IBOutlet weak var txfNombre: UITextField!
    @IBOutlet weak var txfTelefono: UITextField!
   
    var parqueSeleccionado:Parque?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txfNombre.text = parqueSeleccionado!.nombre
        txfMedidas.text = parqueSeleccionado!.medidas
        txfDireccion.text = parqueSeleccionado!.ubicacion
        txfTelefono.text = parqueSeleccionado!.telefono
        
    }

    @IBAction func guardarCambios(_ sender: Any) {
        
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
    
    func consumoServicio(_ parque: Data){
        let urlUpdate = URL(string: "http://3.93.149.143:3333/parque/update/" + String(parqueSeleccionado!.id))
        var registro = URLRequest(url: urlUpdate!)
            
        registro.httpMethod = "PUT"
        registro.setValue("application/json", forHTTPHeaderField: "Content-Type")
        registro.setValue("Bearer " + getToken(), forHTTPHeaderField: "Authorization")
        registro.httpBody = parque
        
        let alerta = UIAlertController(title: "Confirmación", message: "¿Estás seguro de que deseas realizar estos cambios?", preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Sí", style: .default, handler: { (_) in
            let _ = URLSession.shared.dataTask(with: registro) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "sgReturnInfo", sender: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.mostrarAlerta(mensaje: "Algo salio mal, intente mas tarde")
                    }
                }
            }.resume()
            
        }))
        alerta.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alerta, animated: true, completion: nil)
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
