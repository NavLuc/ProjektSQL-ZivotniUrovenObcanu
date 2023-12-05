/*
 * Primární tabulky:

czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.


* Číselníky sdílených informací o ČR:

czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
czechia_district – Číselník okresů České republiky dle normy LAU.


* Dodatečné tabulky:

countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.


* Výzkumné otázky

1.Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2.Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3.Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4.Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5.Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?


/*
 * 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
 */			

WITH common_years AS ( /*společné období cen potravin a HDP pro případ porovnání*/
	SELECT DISTINCT
			av_wages_year_prev AS year 
	FROM t_lucie_navratilova_project_sql_primary_final  
	WHERE 	average_wages_value_prev IS NOT NULL
	GROUP BY year
),
year_for_highest_GDP AS ( /*nalezení roku s výrazně vysokým nárůstem HDP*/
	SELECT DISTINCT sf.year
	FROM t_lucie_navratilova_project_sql_secondary_final sf
	WHERE GDP_growth IN (
							SELECT 	MAX(GDP_growth) FROM t_lucie_navratilova_project_sql_secondary_final sf2
								 	WHERE  year_prev IN (SELECT * FROM common_years)	
						)
),
average_average_wages_czechia_price_per_year AS ( /*v datech z tabulky economies nemáme dostupná data za kvartál pouze za rok, tedy proto jsou hodnoty mezd za kvartály zprůměrovány za rok*/
	SELECT DISTINCT 
					av_wages_year_prev,
					av_wages_year,
					av_wages_quarter,
					industry,
					calculation_code,
					average_wages_growth
	FROM 	t_lucie_navratilova_project_sql_primary_final
	WHERE 	average_wages_growth IS NOT NULL
			AND calculation_code = 200	
	GROUP BY industry, calculation_code, av_wages_year_prev, av_wages_year
),
average_wages_per_year_of_highest_GDP AS ( /*průměrné mzdy pro rok s výrazným nárůstem HDP a rok následující*/
	SELECT DISTINCT 
					av_wages_year_prev,
					av_wages_year,
					av_wages_quarter,
					calculation_code,
					industry,
					average_wages_growth
	FROM 	average_average_wages_czechia_price_per_year
	WHERE av_wages_year IN (SELECT year FROM year_for_highest_GDP UNION SELECT year+1 FROM year_for_highest_GDP)
			AND calculation_code = '200'	
)

SELECT 	DISTINCT
				egdpgpy.country,
				egdpgpy.year_prev,
				egdpgpy.year,
				awgpy.industry,
				awgpy.average_wages_growth,
				'%' AS average_wages_growth_unit,
				egdpgpy.GDP_growth,
				'%' AS GDP_growth
FROM  average_wages_per_year_of_highest_GDP awgpy
	  JOIN t_lucie_navratilova_project_sql_secondary_final egdpgpy
		ON awgpy.av_wages_year_prev = egdpgpy.year_prev
		AND awgpy.av_wages_year = egdpgpy.year
		AND egdpgpy.country = 'Czech Republic'
ORDER BY industry	
; 




