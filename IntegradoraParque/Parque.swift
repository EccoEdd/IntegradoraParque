//
//  Parque.swift
//  IntegradoraParque
//
//  Created by Kobeni Higashiyama on 21/04/23.
//

import UIKit

import UIKit

class Parque: NSObject {

    var id = 1
    var nombre = ""
    var medidas = ""
    var ubicacion = ""
    var telefono = ""
    var status = 0
    var f_agregado = ""

    init(nombre: String, medidas: String, ubicacion: String, telefono: String, status: Int, f_agregado: String, id: Int){
        self.id = id
        self.nombre = nombre
        self.medidas = medidas
        self.ubicacion = ubicacion
        self.telefono = telefono
        self.status = status
        self.f_agregado = f_agregado
    }
}

