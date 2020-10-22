SELECT 
	DimTempo.Ano
	,DimCity.`State`
    ,DimCity.`Region`
	,SUM(FatPIB.PIB) AS 'PIB'
	,0 AS 'PIB Y-1'
	,0 AS 'Growing Tax'
FROM FatPIB, DimTempo, DimCity
WHERE
	FatPIB.Ano = DimTempo.Ano
    AND DimTempo.Ano = 2002
	AND DimCity.CityID = FatPIB.CityID
GROUP BY
	DimTempo.Ano
	,DimCity.`State`
    ,DimCity.`Region`
    
UNION    
    
SELECT 
	DimTempo.Ano
	,DimCity.`State`
    ,DimCity.`Region`
	,SUM(FatPIB.PIB) AS 'PIB'
	,SUM(FatPIB_Y_1.PIB) AS 'PIB Y-1'
	,SUM(FatPIB.PIB) / SUM(FatPIB_Y_1.PIB) - 1 AS 'Growing Tax'
FROM FatPIB, FatPIB AS FatPIB_Y_1, DimTempo, DimCity
WHERE
	FatPIB.Ano = DimTempo.Ano
	AND FatPIB_Y_1.Ano = DimTempo.Ano - 1
	AND DimCity.CityID = FatPIB.CityID
	AND FatPIB.CityID = FatPIB_Y_1.CityID
GROUP BY
	DimTempo.Ano
	,DimCity.`State`
    ,DimCity.`Region`