IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[msn].[ConsultarMensaje]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [msn].[ConsultarMensaje]
END 
go
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec MSN.[ConsultarMensaje] @tipo=0
-- @tipo=0=bandeja de entrada
-- @tipo=1=Enviado
-- @tipo=2=No leidos
-- =============================================
create PROCEDURE [msn].[ConsultarMensaje]
@usuario varchar(10)=15,@tipo int=0
AS
BEGIN
DECLARE @SQL VARCHAR(MAX)
IF @tipo=0 BEGIN
SET @SQL ='SELECT	MenId,BanId,MenAsunto,MenMensaje,					
					BanOkRecibido,
					ISNULL(MenCategoriaId,0) MenCategoriaId,
					isnull(BanClaseId,0) BanClaseId,
					ISNULL(BanDestacado,0) BanDestacado,
					CONVERT(VARCHAR(15),MenFecha,103) +'' ''+ CONVERT(varchar(5),CAST(MenFecha AS TIME),108) MenFecha,					
					ISNULL(c.CatColor,'''') MenColor,
					MenOkRecibido,MenBloquearRespuesta,
					PerNombres,PerApellidos,BanHoraLeido BanHoraLeido
			FROM	MSN.BandejaEntrada
					INNER JOIN msn.Mensajes ON MENID=BanMsnId
					INNER JOIN DP.Personas on PerId=MenUsuario
					LEFT JOIN [msn].[Categorias] C ON C.CatId=MenCategoriaId
			WHERE	banusuario='+@usuario
			
END
ELSE IF @tipo=1  BEGIN
SET @SQL ='SELECT	MenId,0 BanId,MenAsunto,MenMensaje,
					cast(0 as tinyint) BanOkRecibido,
					0 BanClaseId,
					0 BanDestacado,
					ISNULL(MenCategoriaId,0) MenCategoriaId,
					CONVERT(VARCHAR(15),MenFecha,103) +'' ''+ CONVERT(varchar(5),CAST(MenFecha AS TIME),108) MenFecha,
					ISNULL(c.CatColor,'''') MenColor,
					MenOkRecibido,MenBloquearRespuesta,
					PerNombres,PerApellidos,getdate() as BanHoraLeido
			FROM	msn.Mensajes 
					INNER JOIN DP.Personas on PerId=MenUsuario
					LEFT JOIN [msn].[Categorias] C ON C.CatId=MenCategoriaId
			WHERE	MenUsuario='+@usuario
END
ELSE IF @tipo=2  BEGIN
SET @SQL ='SELECT	MenId,BanId as BanId,MenAsunto,MenMensaje,
					BanOkRecibido,
					isnull(BanClaseId,0) BanClaseId,
					ISNULL(MenCategoriaId,0) MenCategoriaId,
					ISNULL(BanDestacado,0) BanDestacado,
					CONVERT(VARCHAR(15),MenFecha,103) +'' ''+ CONVERT(varchar(5),CAST(MenFecha AS TIME),108) MenFecha,					
					ISNULL(c.CatColor,'''') MenColor,
					MenOkRecibido,MenBloquearRespuesta,
					PerNombres,PerApellidos,
					BanHoraLeido
			FROM	MSN.BandejaEntrada
					INNER JOIN msn.Mensajes ON MENID=BanMsnId
					INNER JOIN DP.Personas on PerId=MenUsuario
					LEFT JOIN [msn].[Categorias] C ON C.CatId=MenCategoriaId
			WHERE	BanHoraLeido is null and banusuario='+@usuario
			
END
SET @SQL +=' ORDER BY MenFecha DESC'
PRINT(@SQL)
EXEC (@SQL)
END
