﻿using BaseDatos.Contexto;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using Trasversales.Modelo;
using Menu.Modelos;

namespace Menu.Servicios
{
    public class MenuBI
    {

        public Empresas GetEmpresa(int id)
        {
            return new ColegioContext().empresas.Find(id);
        }
        public IEnumerable<SeccionCustom> Get()
        {
            IEnumerable<SeccionCustom> objSeccion = new List<SeccionCustom>();
            ColegioContext objCnn = new ColegioContext();

            objSeccion = (from data in objCnn.seccion
                          select new SeccionCustom()
                          {
                              SeccionId = data.SeccionId,
                              SecDescripcion = data.SecDescripcion,
                              SecIcono = data.SecIcono,
                              SecRuta = data.SecRuta,
                              opcion = (from query in objCnn.opcion where query.OpSeccionId == data.SeccionId select query)
                          });
            return objSeccion;
        }
    }
}
