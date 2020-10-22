USE startupbr_etl;

SELECT 
	estados.`State`
	,estados.`Region_PT` AS `Region`
	,SUM(pop) AS `Population` 
FROM etl_ibge2019_populacao_cidades AS cidades
INNER JOIN etl_estados_brasileiros AS estados ON estados.`State_Abbrev` = cidades.`uf`
GROUP BY
	estados.`State`
	,estados.`Region_PT`;
	
USE startupbr_dw;    
SELECT 
	DimTempo.Ano
    ,DimCity.`Region`
	,SUM(FatPIB.PIB) AS 'PIB'
FROM FatPIB, DimTempo, DimCity
WHERE
	FatPIB.Ano = DimTempo.Ano
    AND DimTempo.Ano = 2017
	AND DimCity.CityID = FatPIB.CityID
    AND DimCity.`Region` = 'Sul'
GROUP BY
	DimTempo.Ano
    ,DimCity.`Region`
