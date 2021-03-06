IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[dbo].[ConsultarClasesMateria]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[ConsultarClasesMateria]
END
go
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec [dbo].[ConsultarClasesMateria] 1,2
-- =============================================
create  PROCEDURE [dbo].[ConsultarClasesMateria]
@empresa int,@cursoid int
AS
BEGIN

DECLARE @temporada_activa int

SET @temporada_activa =(SELECT  TempId FROM Temporada where TempEstado=1 and TempAno=CONVERT(VARCHAR,YEAR(GETDATE())))


SELECT        Claid,Grados.GraId, Grados.GraCodigo, Grados.GraDescripcion, Cursos.CurDescripcion, Cursos.CurCodigo, 
			  Materias.MatID,Materias.MatCodigo, Materias.MatDescripcion, Clases.ClaCodigo, Clases.ClaProfesor, DP.Personas.PerNombres, 
              DP.Personas.PerId,DP.Personas.PerApellidos, Salones.SalId,Salones.SalCodigo, Salones.SalDescripcion
FROM          Clases 
			  INNER JOIN Materias on MatID=ClaMateriaId
			  INNER JOIN Grados on GraId=MatGradoId
			  inner join Cursos on CurId=GraId
			  LEFT JOIN DP.Personas on PerId=ClaProfesor
			  LEFT JOIN Salones on SalId=ClaSalonId
WHERE        (Materias.MatTemporadaId = @temporada_activa) and CurEmpId=@empresa and ClaCursoId=@cursoid
END
