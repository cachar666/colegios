﻿using Curso.Modelos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Trasversales.Modelo;

namespace Colegio.Controllers
{
    [RoutePrefix("curso")]
    public class CursosController : ApiController
    {
        // GET: api/Cursos
        public IEnumerable<CursosCustom> Get()
        {
            return new Curso.Servicios.CursosBI().Get();
        }


        public IEnumerable<CursosCustom> Get(int id)
        {
            return new Curso.Servicios.CursosBI().Get(id);
        }

        [Route("grado")]
        public IEnumerable<Cursos> GetGradoCurso(int grado = 0)
        {
            return new Curso.Servicios.CursosBI().GetCursosGrados(grado);
        }

        [Route("asignar/estudiante")]
        public CursoEstudiantes PostAsignarEsteudiante(CursoEstudiantes request)
        {
            return new Curso.Servicios.CursosBI().AsignarEstudianteCurso(request);
        }
        [Route("eliminar/estudiante/")]
        [HttpPost]
        public ResponseDTO PostQuitarEstudianteCurso(CursoEstudiantes request)
        {

            return new Curso.Servicios.CursosBI().QuitarEstudianteCurso(request);
        }

        // POST: api/Cursos
        public CursosCustom Post(Cursos value)
        {
            return new Curso.Servicios.CursosBI().Save(value);
        }

        // PUT: api/Cursos/5
        public ResponseCursoCustom Put(Cursos value)
        {
            if (value.CurGrado == 0)
            {
                value.CurGrado = new Curso.Servicios.CursosBI().Get(value.CurId).FirstOrDefault().CurGrado;
            }
            return new Curso.Servicios.CursosBI().Update(value);
        }

        // DELETE: api/Cursos/5
        public ResponseDTO Delete(int id)
        {
            return new Curso.Servicios.CursosBI().Remove(id);
        }
    }
}
