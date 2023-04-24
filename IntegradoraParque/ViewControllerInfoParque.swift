//
//  ViewControllerInfoParque.swift
//  IntegradoraParque
//
//  Created by Kobeni Higashiyama on 21/04/23.
//

import UIKit

class ViewControllerInfoParque: UIViewController {

    @IBOutlet weak var txtNombre: UILabel!
    @IBOutlet weak var txtMedidas: UILabel!
    @IBOutlet weak var txtDireccion: UILabel!
    @IBOutlet weak var txtStatus: UILabel!
    
    var parqueSeleccionado:Parque?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtNombre.text = parqueSeleccionado!.nombre
        txtMedidas.text = parqueSeleccionado!.medidas
        txtDireccion.text = parqueSeleccionado!.ubicacion
        if(parqueSeleccionado!.status == 1){
            txtStatus.text = "Activo"
        } else{
            txtStatus.text = "Inactivo"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if(segue.identifier == "sgDelete"){
            
        } else if (segue.identifier == "sgEdit"){
            let vc = segue.destination as! ViewControllerEditParque
            vc.parqueSeleccionado = parqueSeleccionado
        }
    }
    
    @IBAction func borrarParque(_ sender: Any) {
        let urlDelete = URL(string: "http://3.93.149.143:3333/parque/delete/" + String(parqueSeleccionado!.id))
        var registro = URLRequest(url: urlDelete!)
            
        registro.httpMethod = "DELETE"
        registro.setValue("application/json", forHTTPHeaderField: "Content-Type")
        registro.setValue("Bearer " + getToken(), forHTTPHeaderField: "Authorization")
        
        let alerta = UIAlertController(title: "Confirmación", message: "¿Estás seguro de que deseas realizar esta acción?", preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Sí", style: .default, handler: { (_) in
            let _ = URLSession.shared.dataTask(with: registro) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "sgDelete", sender: sender)
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
    
    @IBAction func edittar(_ sender: Any) {
        performSegue(withIdentifier: "sgEdit", sender: nil)
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
    
    
    @IBAction func rueda(_ sender: Any) {
        let urlDelete = URL(string: "http://3.93.149.143:3333/led/update/1")
        var registro = URLRequest(url: urlDelete!)
            
        registro.httpMethod = "PUT"
        registro.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let _ = URLSession.shared.dataTask(with: registro) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let status = json["status"] as? Bool {
                    if status{
                        DispatchQueue.main.async {
                            self.mostrar(mensaje: "Rueda prendida")
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.mostrar(mensaje: "Rueda apagada")
                        }
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.mostrarAlerta(mensaje: "Algo salio mal, intente mas tarde")
                }
            }
        }.resume()
    }
    
    func mostrar(mensaje: String) {
        let alerta = UIAlertController(title: "CAMBIO!", message: mensaje, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default,handler: nil)
        alerta.addAction(ok)
        present(alerta, animated: true, completion: nil)
    }
    
}
