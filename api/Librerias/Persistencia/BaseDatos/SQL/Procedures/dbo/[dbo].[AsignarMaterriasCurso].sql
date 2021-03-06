IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[dbo].[AsignarMaterriasCurso]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[AsignarMaterriasCurso]
END
go
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[AsignarMaterriasCurso]
	@empresa int,@temporada int,@codigo varchar(20),
	@MateriaId int,@SalonId int,@CursoId int,
	@ProfesorId int,@Observaciones VARCHAR(MAX)
	
AS
BEGIN
INSERT INTO [dbo].[Clases]
           ([ClaEmpId]
           ,[ClaTemporada]
           ,[ClaCodigo]
           ,[ClaMateriaId]
           ,[ClaSalonId]
           ,[ClaCursoId]
           ,[ClaProfesor]
           ,[ClaObservacion])
     VALUES
           (@empresa,@temporada,@codigo,@MateriaId,
		   @SalonId,@CursoId,@ProfesorId,@Observaciones
		   )

END
