USE startupbr_dw;
SELECT	
    DimTempo.Ano
    ,DimCity.`State`
    ,DimCity.`Region`
	,SUM(fat.`Cumulative Founded Startups`) AS `CumulativeFoundedStartups`
	,SUM(fat.`Cumulative Founded Startups Y-1`) AS `CumulativeFoundedStartupsY1`
    ,SUM(fat.`Cumulative Closed Startups`) AS `CumulativeClosedStartups`
    ,SUM(fat.`Cumulative Closed Startups Y-1`) AS `CumulativeClosedStartupsY1`    
    ,SUM(fat.`Cumulative Founded Startups`) - SUM(fat.`Cumulative Closed Startups`) AS `QuantityStartups`
    ,IFNULL((SUM(fat.`Cumulative Founded Startups`) - SUM(fat.`Cumulative Closed Startups`)) / (SUM(fat.`Cumulative Founded Startups Y-1`) - SUM(fat.`Cumulative Closed Startups Y-1`)) - 1, 0) AS `GrowingTaxStartups`    
	,SUM(fat.`Cumulative Total Funding Amount (in USD)`) AS `CumulativeTotalFundingAmountUSD`
	,SUM(fat.`Cumulative Total Funding Amount (in USD) Y-1`) AS `CumulativeTotalFundingAmountUSDY1`
    ,IFNULL(SUM(fat.`Cumulative Total Funding Amount (in USD)`) / SUM(fat.`Cumulative Total Funding Amount (in USD) Y-1`) - 1, 0) AS `GrowingTaxUSD`    
FROM FatStartups AS fat, DimCity, DimTempo
WHERE
	fat.CityID = DimCity.CityID
    AND fat.Ano = DimTempo.Ano
    #AND DimTempo.Ano = 2019
GROUP BY
    DimTempo.Ano
    ,DimCity.`State`
    ,DimCity.`Region`