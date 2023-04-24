//
//  ViewControllerPerfil.swift
//  IntegradoraParque
//
//  Created by Kobeni Higashiyama on 22/04/23.
//

import UIKit

class ViewControllerPerfil: UIViewController {

    @IBOutlet weak var txtNombre: UILabel!
    @IBOutlet weak var txtCorreo: UILabel!
    @IBOutlet weak var txtTelefono: UILabel!
    
    let urlInfo = URL(string: "http://3.93.149.143:3333/users/info")
    let urlLogOut = URL(string: "http://3.93.149.143:3333/user/logout")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        consultaInfo()
    }
    
    @IBAction func cerrarSecion(_ sender: Any) {
        var registro = URLRequest(url: urlLogOut!)
            
        registro.httpMethod = "DELETE"
        registro.setValue("application/json", forHTTPHeaderField: "Content-Type")
        registro.setValue("Bearer " + getToken(), forHTTPHeaderField: "Authorization")
            
        let _ = URLSession.shared.dataTask(with: registro) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.saveRefresh(refreshToken: "nil")
                    self.performSegue(withIdentifier: "sgLogout", sender: nil)
                }
            }else{
                DispatchQueue.main.async {
                    self.mostrarAlerta(mensaje: "Algo salio mal, intente mas tarde")
                }
            }
        }.resume()
    }
    
    func consultaInfo() -> Void{
        var registro = URLRequest(url: urlInfo!)
        
        registro.httpMethod = "GET"
        registro.setValue("application/json", forHTTPHeaderField: "Content-Type")
        registro.setValue("Bearer " + getToken(), forHTTPHeaderField: "Authorization")
        
        let _ = URLSession.shared.dataTask(with: registro) { (data, response, error) in
            if let error = error {
                print("Error en la solicitud HTTP: \(error.localizedDescription)")
            } else if let respuesta = response as? HTTPURLResponse, let data = data {
                print("Código de estado HTTP: \(respuesta.statusCode)")
                do {
                    let usuario = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    DispatchQueue.main.async {
                        self.txtCorreo.text = usuario["correo"] as! String
                        self.txtNombre.text = usuario["nombre"] as! String
                        self.txtTelefono.text = usuario["telefono"] as! String
                    }
                } catch {
                    print("Error al convertir la respuesta a JSON: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func getToken() -> String{
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "auth@token") ?? "nil"
    }
    
    func saveRefresh(refreshToken: String){
        let defaults = UserDefaults.standard
        defaults.set(refreshToken, forKey: "auth@token")
        defaults.synchronize()
    }
    
    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "ALERTA!", message: mensaje, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default,handler: nil)
        alerta.addAction(ok)
        present(alerta, animated: true, completion: nil)
    }
}
