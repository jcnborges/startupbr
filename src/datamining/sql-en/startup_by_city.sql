USE startupbr_dw;

SELECT
	DimCity.`Name` AS `City`
	,DimCity.`IsCapital`
    ,DimCity.`State`
    ,DimCity.`StateAbbrev`
    ,DimCity.`Region`
    ,ROUND(FatIDHM.`IDHM`, 3) AS `IDHM` 
    ,ROUND(FatIDHM.`IDHM Educacao`, 3) AS `IDHMEducacao`
    ,ROUND(FatIDHM.`IDHM Longividade`, 3) AS `IDHMLongividade`
    ,ROUND(FatIDHM.`IDHM Renda`, 3) AS `IDHMRenda`
    ,FatPIB.`PIB` AS `PIB`
    ,FatPIB.`PIB per Capita` AS `PIBperCapita`
    ,FatPopulation.`Population`
    ,FatPIB.`Atividade 1` AS `Atividade1`
    ,FatPIB.`Atividade 2` AS `Atividade2`
    ,FatPIB.`Atividade 3` AS `Atividade3`
    ,IF(FatStartups.`Quantity (in startups)` IS NOT NULL, FatStartups.`Quantity (in startups)`, 0) AS `QuantityStartups`
    ,IF(FatStartups.`Cumulative Total Funding Amount (in USD)` IS NOT NULL, FatStartups.`Cumulative Total Funding Amount (in USD)`, 0) AS `TotalFundingAmount`
FROM FatIDHM, FatPIB, FatPopulation, DimCity
LEFT JOIN FatStartups ON FatStartups.CityID = DimCity.CityID
WHERE
	DimCity.CityID = FatIDHM.CityID
    AND DimCity.CityID = FatPIB.CityID
    AND DimCity.CityID = FatPopulation.CityID
    AND FatIDHM.Ano = 2010
    AND FatPIB.Ano = 2017
	AND (FatStartups.Ano = 2019 OR FatStartups.Ano IS NULL)
    #AND FatStartups.Ano = 2019
    AND FatPopulation.Ano = 2019