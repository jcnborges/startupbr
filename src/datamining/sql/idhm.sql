USE startupbr_dw;
SELECT 
	DimCity.`Name`
	,DimCity.`State`
    ,DimCity.`Region`
    ,DimTempo.Ano
    ,ROUND(FatIDHM.IDHM, 3) AS `IDHM`
    ,ROUND(FatIDHM.`IDHM Educacao`, 3) AS `IDHM Educacao`
    ,ROUND(FatIDHM.`IDHM Longividade`, 3) AS `IDHM Longividade`
    ,ROUND(FatIDHM.`IDHM Renda`, 3) AS `IDHM Renda`
FROM FatIDHM
	INNER JOIN DimCity ON DimCity.CityID = FatIDHM.CityID
    INNER JOIN DimTempo ON DimTempo.Ano = FatIDHM.Ano
WHERE
	FatIDHM.IDHM IS NULL;
    
USE startupbr_etl;
SELECT
	Ano
    ,estados.`State`
    ,IF(estados.`Region_PT` = 'Centro-Oeste', 'Centro-oeste', estados.`Region_PT`) AS `Region`
	,IF(idhm.IDH IS NOT NULL, CAST(REPLACE(REPLACE(idhm.IDH, '.', ''), ',', '.') AS DECIMAL(32, 3)), NULL) AS `IDHM`
	,IF(idhm.E IS NOT NULL, CAST(REPLACE(REPLACE(idhm.E, '.', ''), ',', '.') AS DECIMAL(32, 3)), NULL) AS `IDHMEducacao`
	,IF(idhm.L IS NOT NULL, CAST(REPLACE(REPLACE(idhm.L, '.', ''), ',', '.') AS DECIMAL(32, 3)), NULL) AS `IDHMLongividade`
	,IF(idhm.R IS NOT NULL, CAST(REPLACE(REPLACE(idhm.R, '.', ''), ',', '.') AS DECIMAL(32, 3)), NULL) AS `IDHMRenda`	
FROM etl_ibge1991_2000_2010_2017_idhm_estados_brasileiros AS idhm
INNER JOIN etl_estados_brasileiros AS estados ON estados.`State` = idhm.`Unidade Federativa`