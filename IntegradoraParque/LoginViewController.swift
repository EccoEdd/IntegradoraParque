//
//  LoginViewController.swift
//  IntegradoraParque
//
//  Created by imac on 10/04/23.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var txfPassword: UITextField!
    
    let datos = Usuario.sharedDatos()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    func validarCorreo(_ email:String) -> Bool {
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
        
    @IBAction func login(_ sender: UIButton){
        guard let correo = txfEmail.text, !correo.isEmpty else{
            mostrarAlerta(mensaje: "El campo correo no puede estar vacio")
            return
        }
        if validarCorreo(correo) == false{
            mostrarAlerta(mensaje: "El campo correo no es valido")
            return
        }
        guard let contraseña = txfPassword.text, contraseña.count >= 8 else{
            mostrarAlerta(mensaje: "El campo contraseña debe tener al menos 8 caracteres")
            return
        }
        let bodyLog = ["correo":correo,"password":contraseña]
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: bodyLog, options: [])
            print(type(of: jsonData))
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
            realizarLogin(jsonData)
        } catch {
            print("XD")
        }
    }
        
    func realizarLogin(_ data: Data){
        let url = URL(string: "http://3.93.149.143:3333/login")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let _ = URLSession.shared.dataTask(with: request) { datos, response, error in
            if let error = error {
                print("Error en la solicitud HTTP: \(error.localizedDescription)")
            } else if let respuesta = response as? HTTPURLResponse, let data = datos {
                print("Código de estado HTTP: \(respuesta.statusCode)")
                if respuesta.statusCode == 200{
                    do{
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let token = json["token"] as? String,
                           let user = json["user"] as? [String: Any] {
                            
                            self.datos.correo = user["correo"] as! String
                            self.datos.nombre = user["nombre_completo"] as! String
                            self.datos.telefono = user["correo"] as! String
        
                            self.saveRefresh(refreshToken: token)
                            
                        } else {
                            print("JSON inválido o sin token y/o objeto de usuario")
                        }
                    }catch{
                        print("XD")
                    }
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "sgHome0", sender: nil)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.mostrarAlerta(mensaje: "Usuario o Contrasena incorrecto")
                }

            }
        }.resume()
    }
    
    func saveRefresh(refreshToken: String){
        let defaults = UserDefaults.standard
        defaults.set(refreshToken, forKey: "auth@token")
        defaults.synchronize()
    }
    
}
