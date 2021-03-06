IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[msn].[CrearMensaje_Bandeja_Entrada]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [msn].[CrearMensaje_Bandeja_Entrada]
END
go

-- =============================================
-- Description:	crea un registro en la taba msn.BandejaEntrada
--			    por cada destinatario enviado en el xml
-- =============================================
create PROCEDURE [msn].[CrearMensaje_Bandeja_Entrada]
	
	@idMensaje int,@destinatarios xml,@empresa int
AS
BEGIN
	CREATE TABLE msn.#TBL_Destinatarios(id int ,tipo int )
	CREATE TABLE msn.#TBL_final(usuario INT,claseid int)

	
	
	INSERT INTO msn.#TBL_Destinatarios
	SELECT  CAST(colx.query('data(id) ') as varchar) as id,  
			CAST(colx.query('data(tipo) ') as varchar)  as tipo   
	FROM	@destinatarios.nodes('ArrayOfDestinarario/Destinarario') AS Tabx(Colx)  

	--select * 
	--into msn.TBL_Destinatarios 
	--from msn.#TBL_Destinatarios 

	/*==========================================================|tipo=-40-->Colegio|=========================================================*/
	INSERT INTO msn.#TBL_final (usuario)
	SELECT	P.PerId
	FROM	[DP].[Personas] P 
			INNER JOIN [msn].[GruposEnvioAutorizadoAll] A ON  P.PerIdEmpresa=A.GrEnAuAllEmp 
						and p.PerEstado=1
			INNER JOIN [dbo].[Temporada] T ON T.TempId=A.GeEnAuAllTemporada and t.TempEstado=1
			INNER JOIN msn.#TBL_Destinatarios D ON D.ID=A.GrEnAuAllId AND D.TIPO=-40
	WHERE	P.PerIdEmpresa=@empresa



	/*==========================================================|tipo=-30-->Grados|==========================================================*/
	INSERT INTO msn.#TBL_final (usuario)
	SELECT	CE.CurEstEstudianteId
	FROM	[dbo].[CursoEstudiantes] CE 
			INNER JOIN	[dbo].[Cursos] C ON C.CurId=CE.CurEstCursoId 
			INNER JOIN msn.#TBL_Destinatarios D ON D.ID=C.CurGrado AND D.TIPO=-30
			INNER JOIN DP.Personas p on p.PerId=CE.CurEstEstudianteId and p.PerEstado=1
			INNER JOIN [dbo].[Temporada] T ON T.TempId=c.CurTemporada and t.TempEstado=1
	WHERE	P.PerIdEmpresa=@empresa	
	


	/*==========================================================|tipo=-20-->Cursos|==========================================================*/
	INSERT INTO msn.#TBL_final (usuario)
	SELECT	CE.CurEstEstudianteId
	FROM	[dbo].[CursoEstudiantes] CE 			
			INNER JOIN msn.#TBL_Destinatarios D ON D.ID=CE.CurEstCursoId AND D.TIPO=-20
			INNER JOIN DP.Personas p on p.PerId=CE.CurEstEstudianteId and p.PerEstado=1
			--INNER JOIN [dbo].[Temporada] T ON T.TempId=c.CurTemporada and t.TempEstado=1
	WHERE	P.PerIdEmpresa=@empresa


	/*==========================================================|tipo=-10-->Clases|==========================================================*/
	INSERT INTO msn.#TBL_final (usuario,claseid)
	SELECT	CE.CurEstEstudianteId,D.ID
	
	FROM	[dbo].[CursoEstudiantes] CE
			INNER JOIN [dbo].[Clases] C ON C.ClaCursoId=CE.CurEstCursoId
			INNER JOIN msn.#TBL_Destinatarios D ON D.ID=C.Claid AND D.TIPO=-10
			INNER JOIN DP.Personas p on p.PerId=CE.CurEstEstudianteId and p.PerEstado=1
			INNER JOIN [dbo].[Temporada] T ON T.TempId=c.ClaTemporada and t.TempEstado=1
	WHERE	P.PerIdEmpresa=@empresa
	
	

	/*==========================================================|tipo=-5-->Personalizados|===================================================*/
	INSERT INTO msn.#TBL_final (usuario)
	SELECT	A.GruPerPersona
	FROM	[msn].[GruposEnvioAutorizado] A
			INNER JOIN msn.#TBL_Destinatarios D ON D.ID=A.GruPerGrupoId AND D.TIPO=-5
			INNER JOIN DP.Personas p on p.PerId=a.GruPerPersona and p.PerEstado=1 
	WHERE	P.PerIdEmpresa=@empresa



	/*==========================================================|tipo=0-->Estudiantes|=======================================================*/
	/*==========================================================|tipo=1-->Profesores|==========================================================*/
	INSERT INTO msn.#TBL_final (usuario)
	SELECT	id
	FROM	msn.#TBL_Destinatarios D 
			INNER JOIN DP.Personas p on p.PerId=id and p.PerEstado=1
			--INNER JOIN Empresas on EmpId=PerIdEmpresa
	WHERE	D.TIPO in(0,1) and PerIdEmpresa=@empresa


	/*
	--TEST
	SELECT * 
	FROM  msn.#TBL_final 
	GROUP BY  usuario	
	return
	*/

	/*==========================================================|insert final|==========================================================*/
   INSERT INTO [msn].[BandejaEntrada]
           ([BanMsnId],[BanEstado],[BanUsuario],[BanOkRecibido],[BanOkRecibidoFecha],BanClaseId)
   SELECT	@idMensaje,1,usuario,0,GETDATE(),claseid
   FROM		msn.#TBL_final
   GROUP BY  usuario,claseid
           
END
