﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Trasversales.Modelo;

namespace Colegio.Controllers
{
    public class SalonesController : ApiController
    {
        // GET: api/Salones
        public IEnumerable<Salones> Get()
        {
            return new Salon.Servicios.SalonesBI().Get();
        }

        public Salones Post(Salones value)
        {
            return new Salon.Servicios.SalonesBI().Save(value);
        }

        // PUT: api/Salones/5
        public ResponseDTO Put(Salones value)
        {
            return new Salon.Servicios.SalonesBI().Update(value);
        }

        // DELETE: api/Temporada/5
        public ResponseDTO Delete(int id)
        {
            return new Salon.Servicios.SalonesBI().Remove(id);
        }
    }
}