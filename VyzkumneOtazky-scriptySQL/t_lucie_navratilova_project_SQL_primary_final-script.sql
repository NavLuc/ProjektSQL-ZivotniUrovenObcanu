/*
(pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky (a společné kvartály))
*/
CREATE OR REPLACE VIEW t_lucie_navratilova_project_SQL_primary_final AS

WITH average_wage_per_year_and_quarter AS ( /*průměrné mzdy v různých odvětvích za roky a kvartály*/ 
	SELECT 	DISTINCT
			cpc.code AS calculation_code,
	   		cpc.name AS calculation_type,
       		cpib.name AS industry, 
       		cpay.value AS average_wages,
       		cpay.payroll_year,
       		cpay.payroll_quarter
	FROM czechia_payroll AS cpay
	JOIN czechia_payroll_industry_branch cpib
    	ON cpay.industry_branch_code = cpib.code
	JOIN czechia_payroll_calculation cpc
    	ON cpay.calculation_code  = cpc.code
	WHERE cpay.value_type_code = 5958 
	AND cpay.unit_code = '200' 
),
average_wage_growth_per_year_and_quarter AS ( /*nárůsty mezd v různých odvětvích za totožné porovnatelné období – společné roky (a společné kvartály)*/ 
	SELECT 	DISTINCT
			awpy2.payroll_year AS av_wages_year_prev,
	   		awpy.payroll_year AS av_wages_year, 
	   		awpy.payroll_quarter AS av_wages_quarter,
	   		awpy.calculation_type,
	   		awpy.calculation_code,
	   		awpy.industry,
    		round( ( awpy.average_wages - awpy2.average_wages ) / awpy2.average_wages * 100, 2 ) as average_wages_growth,
    		awpy2.average_wages AS average_wages_value_prev,
    		awpy.average_wages AS average_wages_value
	FROM average_wage_per_year_and_quarter awpy
	LEFT JOIN average_wage_per_year_and_quarter awpy2
    	ON awpy.industry = awpy2.industry
    	AND awpy.calculation_code = awpy2.calculation_code
    	AND awpy.payroll_year = awpy2.payroll_year + 1
    	AND awpy.payroll_quarter = awpy2.payroll_quarter
),
czechia_price_per_quarter AS ( /*průměrné ceny potravin v různých regionech za kvartály*/ 
	SELECT 	DISTINCT
			QUARTER(date_from) AS quarter,
    		YEAR(date_from) AS year,
    		round(AVG(value),2) AS czechia_price_value,
    		region_code,
    		category_code
	FROM czechia_price
	WHERE region_code IS NULL
	GROUP BY region_code, category_code, year, quarter
),
czechia_price_per_year_and_quarter AS ( /*průměrné ceny potravin v různých skupinách potravin a regionech za roky a kvartály*/ 
	SELECT 	DISTINCT
			cp.region_code,
			cp.category_code,
			cpc.name AS category_name,
			cpc.price_value,
			cpc.price_unit,
			czechia_price_value,
			year,
			quarter
	FROM czechia_price_per_quarter cp
		JOIN czechia_price_category cpc
    		ON cp.category_code = cpc.code
),
czechia_price_growth_per_year_and_quarter AS ( /*nárůsty cen potravin za různé skupiny potravin v různých regionech za totožné porovnatelné období – společné roky (a společné kvartály)*/ 
	SELECT 	DISTINCT
			cppy.category_code,
			cppy.category_name,
	   		REPLACE(CONCAT(' Kč / ', cppy.price_value, ' ', cppy.price_unit), '.', ',') AS price, 
	   		cppy2.year AS price_year_prev, 
	   		cppy.year AS price_year, 
	   		cppy.quarter AS price_quarter,
       		round( ( cppy.czechia_price_value - cppy2.czechia_price_value ) / cppy2.czechia_price_value * 100, 2 ) as price_growth,
       		'%' AS price_growth_unit,
       		cppy2.czechia_price_value AS czechia_price_value_prev,
       		cppy.czechia_price_value
	FROM czechia_price_per_year_and_quarter cppy
	LEFT JOIN czechia_price_per_year_and_quarter cppy2 
    ON cppy.category_code = cppy2.category_code 
    AND cppy.year = cppy2.year + 1
    AND cppy.quarter = cppy2.quarter
)/*přidána kupní síla dle průměrných mezd vůči cenám potravin v různých skupinách potravin*/

SELECT 	DISTINCT
		*,
		floor (average_wages_value_prev / czechia_price_value_prev) AS  amount_of_food_per_av_wages_prev,
		floor (average_wages_value / czechia_price_value) AS  amount_of_food_per_av_wages
FROM average_wage_growth_per_year_and_quarter awgpy
	LEFT JOIN czechia_price_growth_per_year_and_quarter cpgpy
	ON 	awgpy.av_wages_year_prev = cpgpy.price_year_prev
	AND awgpy.av_wages_year = cpgpy.price_year
	AND awgpy.av_wages_quarter = cpgpy.price_quarter
	
UNION ALL

SELECT DISTINCT -- doplněny údaje cen potravin, které nemají společné roky s hrubými mzdami 
		*,
		floor (average_wages_value_prev / czechia_price_value_prev) AS  amount_of_food_per_av_wages_prev,
		floor (average_wages_value / czechia_price_value) AS  amount_of_food_per_av_wages
FROM
		(
			SELECT *
			FROM average_wage_growth_per_year_and_quarter
			WHERE av_wages_year_prev IS NULL
		) AS avpn
		
RIGHT JOIN

		(
			SELECT *
			FROM czechia_price_growth_per_year_and_quarter
			WHERE price_year_prev IS NULL
		) AS cpn
		
ON 	avpn.av_wages_year_prev = cpn.price_year_prev
	AND avpn.av_wages_year = cpn.price_year
	AND avpn.av_wages_quarter = cpn.price_quarter 
	
UNION ALL


SELECT DISTINCT  -- doplněny údaje hrubých mezd, které nemají společné roky s cenami potravin
		*,
		floor (average_wages_value_prev / czechia_price_value_prev) AS  amount_of_food_per_av_wages_prev,
		floor (average_wages_value / czechia_price_value) AS  amount_of_food_per_av_wages
FROM
		(
			SELECT *
			FROM average_wage_growth_per_year_and_quarter
			WHERE av_wages_year_prev IS NULL
		) AS avpn
		
LEFT JOIN

		(
			SELECT *
			FROM czechia_price_growth_per_year_and_quarter
			WHERE price_year_prev IS NULL
		) AS cpn
		
ON 	avpn.av_wages_year_prev = cpn.price_year_prev
	AND avpn.av_wages_year = cpn.price_year
	AND avpn.av_wages_quarter = cpn.price_quarter
;

