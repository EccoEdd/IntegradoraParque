//
//  Usuario.swift
//  IntegradoraParque
//
//  Created by Kobeni Higashiyama on 10/04/23.
//

import UIKit

class Usuario: NSObject {
    
    var nombre: String
    var correo: String
    var telefono: String
    static var datos: Usuario!
    
    override init () {
        nombre = ""
        correo = ""
        telefono = ""
    }
    
    static func sharedDatos() -> Usuario{
        if datos == nil{
            datos = Usuario.init()
        }
        return datos
    }

}
