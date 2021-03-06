IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[msn].[AcEnvioCorreoPersonas]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [msn].[AcEnvioCorreoPersonas]
END
go
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	autocomple para envios de correos
-- =============================================
CREATE PROCEDURE [msn].[AcEnvioCorreoPersonas]
	@filter varchar(50),@idusuario VARCHAR(50), @Temporada VARCHAR(5)=1, @Emp VARCHAR(5)=1
AS
BEGIN
	DECLARE @tipo_perfil VARCHAR(2),@sql VARCHAR(MAX)
	CREATE TABLE msn.#TblCursos(idcurso INT)

	SET @tipo_perfil=ISNULL((SELECT CAST(PerTipoPerfil AS VARCHAR) FROM	DP.Personas WHERE PerId=@idusuario),0)

	--	PROFESOR
	IF(@tipo_perfil=1)BEGIN
		SET @sql='
		SELECT	--TOP(5)				
				PerId,PerApellidos,PerNombres
				,GraDescripcion,CurDescripcion,
				' + @tipo_perfil + ' AS tipo, 0 AS Orden,
				gc.GrEnColorRGB,gc.GrEnColorBurbuja,GrEnColorObs
		INTO	MSN.#TBLDatos
		FROM	Clases
				INNER JOIN	Cursos ON ClaCursoId=curid
				INNER JOIN	CursoEstudiantes ON CurEstCursoId=CurId
				INNER JOIN	DP.Personas ON PerId=CurEstEstudianteId AND PerTipoPerfil=2
				INNER JOIN Grados ON GraId=CurGrado
				INNER JOIN [msn].[GruposEnvioColores] GC on  gc.GrEnColorTipo=' + @tipo_perfil + '
		WHERE	ClaProfesor='+CONVERT(VARCHAR,@idusuario)
		
		IF @filter<>'' BEGIN
			IF ISNUMERIC(@filter)=1 BEGIN
				SET @sql +=' AND PerDocumento LIKE  ''%'+@filter+'%'''
			END
			ELSE BEGIN 
				SET @sql +=' AND PerNombres LIKE  ''%'+@filter+'%'''
				SET @sql +=' OR PerApellidos LIKE  ''%'+@filter+'%'''
			END
			
		END
		SET @sql +=' GROUP BY PerId,PerNombres,PerApellidos,GraDescripcion,CurDescripcion,
							  gc.GrEnColorRGB,gc.GrEnColorBurbuja,GrEnColorObs'
		--set @sql +=' ORDER BY PerApellidos,PerNombres'

	END
	--	ESTUDIANTE
	ELSE BEGIN
		SET @sql='
		SELECT	--TOP (5)
				PerId, PerApellidos, PerNombres
				,'''' GraDescripcion,
				 MatDescripcion CurDescripcion,
				' + @tipo_perfil + ' AS tipo, 0 AS Orden,
				gc.GrEnColorRGB,gc.GrEnColorBurbuja,GrEnColorObs
		INTO	MSN.#TBLDatos
		FROM	CursoEstudiantes				
				INNER JOIN	Clases ON ClaCursoId=CurEstCursoId				
				INNER JOIN	DP.Personas ON PerId=ClaProfesor
				INNER JOIN	Materias ON MatID=ClaMateriaId
				INNER JOIN [msn].[GruposEnvioColores] GC on  gc.GrEnColorTipo=' + @tipo_perfil + '
		WHERE	CurEstEstudianteId='+CONVERT(VARCHAR,@idusuario)
		
		IF @filter<>'' BEGIN
			IF ISNUMERIC(@filter)=1 BEGIN
				SET @sql +=' AND PerDocumento LIKE  ''%'+@filter+'%'''
			END
			ELSE BEGIN 
				SET @sql +=' AND PerNombres LIKE  ''%'+@filter+'%'''
				SET @sql +=' OR PerApellidos LIKE  ''%'+@filter+'%'''
				SET @sql +=' OR MatDescripcion LIKE  ''%'+@filter+'%'''
			END
			
		END
		
		SET @SQL +=' GROUP BY PerId,PerNombres,PerApellidos,MatDescripcion,
							  gc.GrEnColorRGB,gc.GrEnColorBurbuja,GrEnColorObs'
	END

	SET @SQL = @SQL + '
	UNION ALL
	SELECT	GruEnvId, G.GruEnvDescripcion, '''', '''', '''', 0, -5,
			gc.GrEnColorRGB,gc.GrEnColorBurbuja,GrEnColorObs
	FROM	msn.GruposEnvio AS G INNER JOIN
			msn.GruposEnvioAutorizado AS P ON G.GruEnvId = P.GruPerGrupoId INNER JOIN 
			[msn].[GruposEnvioColores] GC on  gc.GrEnColorTipo=0
	WHERE	(P.GruPerPersona = '+@idusuario+') AND (G.GruEnvEmpId = '+@Emp+') AND (G.GruEnvTemporada= '+@Temporada+')
	'

	SET @SQL = @SQL + '
	UNION ALL
	SELECT	Cla.Claid, ''Clase'', Cur.CurDescripcion, '''', Mat.MatDescripcion, -10, GraOrden,
			gc.GrEnColorRGB,gc.GrEnColorBurbuja,GrEnColorObs
	FROM	dbo.Clases AS Cla INNER JOIN
			dbo.Materias AS Mat ON Cla.ClaMateriaId = Mat.MatID INNER JOIN
			dbo.Cursos AS Cur ON Cla.ClaCursoId = Cur.CurId INNER JOIN
			dbo.Grados AS G ON Cur.CurGrado = G.GraId INNER JOIN 
			[msn].[GruposEnvioColores] GC on  gc.GrEnColorTipo=-10
	WHERE	(Cla.ClaEmpId = '+@Emp+') AND (Cla.ClaTemporada = '+@Temporada+') AND (Cla.ClaProfesor = '+@idusuario+')
'


	SET @SQL = @SQL + '
	UNION ALL
	SELECT	A.GrEnAuCurCursoId, ''Curso'', C.CurDescripcion, '''','''', -20, GraOrden,
			gc.GrEnColorRGB,gc.GrEnColorBurbuja,GrEnColorObs
	FROM	msn.GruposEnvioAutorizadoCursos AS A INNER JOIN
			dbo.Cursos C ON A.GrEnAuCurCursoId = C.CurId INNER JOIN
			dbo.Grados AS G ON C.CurGrado = G.GraId INNER JOIN 
			[msn].[GruposEnvioColores] GC on  gc.GrEnColorTipo=-20
	WHERE	(C.CurEmpId = '+@Emp+') AND (C.CurTemporada = '+@Temporada+') AND (A.GrEnAuCurPersonaId = '+@idusuario+')
'

	SET @SQL = @SQL + '
	UNION ALL
	SELECT	A.GrEnAuGraGradoId, ''Grado'', G.GraDescripcion,'''','''',-30, GraOrden,
			gc.GrEnColorRGB,gc.GrEnColorBurbuja,GrEnColorObs
	FROM	msn.GruposEnvioAutorizadoGrados AS A INNER JOIN
			Grados G ON A.GrEnAuGraGradoId = G.GraId INNER JOIN 
			[msn].[GruposEnvioColores] GC on  gc.GrEnColorTipo=-30
	WHERE	(G.GraEmpId = '+@Emp+') AND (A.GrEnAuGraPersonaId = '+@idusuario+')
'


	SET @SQL = @SQL + '
	UNION ALL
	SELECT	'+@Emp+', E.EmpNombre, '''','''','''',-40, 0,
			gc.GrEnColorRGB,gc.GrEnColorBurbuja,GrEnColorObs
	FROM	msn.GruposEnvioAutorizadoAll AS A INNER JOIN
			dbo.Empresas E ON E.EmpId = A.GrEnAuAllEmp INNER JOIN 
			[msn].[GruposEnvioColores] GC on  gc.GrEnColorTipo=-40
	WHERE	(A.GeEnAuAllTemporada = '+@Temporada+') AND (A.GrEnAuAllPersonaId = '+@idusuario+')
'

	
	SET @sql +='ORDER BY tipo, Orden, PerApellidos,PerNombres
	'
	SET @sql +=' SELECT * FROM MSN.#TBLDatos where 1=1 '

	IF @filter<>'' BEGIN		
		SET @sql +=' AND PerNombres LIKE  ''%'+@filter+'%'''
		SET @sql +=' OR PerApellidos LIKE  ''%'+@filter+'%'''			
	END

	PRINT @SQL
	EXEC (@sql)
END


--	Profesor
--	[msn].[AcEnvioCorreoPersonas] '',16

--	Estudiante
--	[msn].[AcEnvioCorreoPersonas] '',32

--

