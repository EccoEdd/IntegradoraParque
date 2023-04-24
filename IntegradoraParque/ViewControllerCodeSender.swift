//
//  ViewControllerCodeSender.swift
//  IntegradoraParque
//
//  Created by Kobeni Higashiyama on 19/04/23.
//

import UIKit

class ViewControllerCodeSender: UIViewController {

    @IBOutlet weak var txfCodigo: UITextField!
    
    let url = URL(string: "http://3.93.149.143:3333/validaCode")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("CODE SENDER")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "ALERTA!", message: mensaje, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default,handler: nil)
        alerta.addAction(ok)
        present(alerta, animated: true, completion: nil)
    }
    @IBAction func sendCode(_ sender: Any) {
        guard let codigo = txfCodigo.text, !codigo.isEmpty else{
            mostrarAlerta(mensaje: "El campo codigo no puede estar vacio")
            return
        }
        guard let _ = Int(codigo) else {
            mostrarAlerta(mensaje: "El numero no debe contener letras o algun otro simbolo")
            return
        }
        guard codigo.count == 4 else{
            mostrarAlerta(mensaje: "El codigo debe ser de exactos 4 digito")
            return
        }
        
        let code:[String:Any] = ["codigo":codigo]
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: code, options: [])
            
            print(type(of: jsonData))
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
            consumoServicio(jsonData)
        } catch {
            print("XD")
        }
    }
    
    func consumoServicio(_ codigo: Data) -> Void{
        var registro = URLRequest(url: url!)
        
        registro.httpMethod = "POST"
        registro.setValue("application/json", forHTTPHeaderField: "Content-Type")
        registro.httpBody = codigo
        
        let _ = URLSession.shared.dataTask(with: registro) { (data, response, error) in
            if let error = error {
                print("Error en la solicitud HTTP: \(error.localizedDescription)")
            } else if let respuesta = response as? HTTPURLResponse, let _ = data {
                print("Código de estado HTTP: \(respuesta.statusCode)")
                
                if respuesta.statusCode == 200{
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "sgRegistro", sender: nil)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.mostrarAlerta(mensaje: "Codigo incorrecto!")
                }

            }
        }.resume()
    }
}
