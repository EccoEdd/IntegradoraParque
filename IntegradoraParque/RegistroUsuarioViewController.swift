//
//  RegistroUsuarioViewController.swift
//  IntegradoraParque
//
//  Created by imac on 10/04/23.
//

import UIKit

class RegistroUsuarioViewController: UIViewController {
    
    
    @IBOutlet weak var txfName: UITextField!
    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var txfPassword: UITextField!
    @IBOutlet weak var txfSecondPassword: UITextField!
    @IBOutlet weak var txfPhone: UITextField!
    
    let url = URL(string: "http://3.93.149.143:3333/registrar")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func validarCorreo(_ email:String)->Bool{
        let expReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPred = NSPredicate(format:"SELF MATCHES%@", expReg)
        return emailPred.evaluate(with: email)
    }

    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "ALERTA!", message: mensaje, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default,handler: nil)
        alerta.addAction(ok)
        present(alerta, animated: true, completion: nil)
    }
    
    @IBAction func registro(_ sender: UIButton){
        
        print("Registro Debug")
        guard let nombre = txfName.text, !nombre.isEmpty else{
            mostrarAlerta(mensaje: "El campo nombre no puede estar vacio")
            return
        }
        guard let correo = txfEmail.text, !correo.isEmpty else{
            mostrarAlerta(mensaje: "El campo correo no puede estar vacio")
            return
        }
        if validarCorreo(correo) == false{
            mostrarAlerta(mensaje: "El campo correo no es valido")
        }
        guard let contraseña = txfPassword.text, contraseña.count >= 8 else{
            mostrarAlerta(mensaje: "El campo contraseña debe tener al menos 4 caracteres")
            return
        }
        guard let spass = txfSecondPassword.text, contraseña == spass else {
            mostrarAlerta(mensaje: "Contrasenas no identicas")
            return
        }
        guard let numeroTelefono = txfPhone.text, !numeroTelefono.isEmpty, numeroTelefono.count == 10 else{
            mostrarAlerta(mensaje: "Revise el campo en numero de telefono. \n\n Ej: 9990009999")
            return
        }
        guard let _ = Int(numeroTelefono) else {
            mostrarAlerta(mensaje: "El numero no debe contener letras o algun otro simbolo")
            return
        }

        let usuario:[String:Any] = ["nombre_completo": nombre, "correo": correo, "password": contraseña, "telefono": numeroTelefono]
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: usuario, options: [])
            
            print(type(of: jsonData))
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
            consumoDelServicio(jsonData)
        } catch {
            print("XD")
        }
        
    }
    
    func consumoDelServicio(_ usuario: Data) -> Void{
        var registro = URLRequest(url: url!)
        
        registro.httpMethod = "POST"
        registro.setValue("application/json", forHTTPHeaderField: "Content-Type")
        registro.httpBody = usuario
        
        let _ = URLSession.shared.dataTask(with: registro) { (data, response, error) in
            if let error = error {
                print("Error en la solicitud HTTP: \(error.localizedDescription)")
            } else if let respuesta = response as? HTTPURLResponse, let datos = data {
                print("Código de estado HTTP: \(respuesta.statusCode)")
                
                if respuesta.statusCode == 201{
                    DispatchQueue.main.async {
                        //self.mostrarAlerta(mensaje: "Revisa tu Correo!, te enviamos un codigo")
                        self.performSegue(withIdentifier: "sgCode", sender: nil)
                    }
                    return
                }
                
                let respuesta = String(data: datos, encoding: .utf8)!
                do {
                    if let dictionary = try JSONSerialization.jsonObject(with: respuesta.data(using: .utf8)!, options: []) as? [String: Any] {
                        if let data = dictionary["data"] as? [String: Any], let messages = data["messages"] as? [String: Any], let errors = messages["errors"] as? [[String: Any]], let message = errors.first?["message"] as? String {
                            DispatchQueue.main.async {
                                self.mostrarAlerta(mensaje: message)
                            }
                        }
                    }
                } catch {
                    print("Error al convertir el JSON a un diccionario: \(error.localizedDescription)")
                }

            }
        }.resume()
    }
}
