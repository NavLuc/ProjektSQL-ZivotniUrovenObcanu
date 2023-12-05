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
    1.Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
*/
/*
 * typ kalkulace fyzický - pokles růstu mezd
 */
SELECT 	DISTINCT
				av_wages_year_prev AS year_prev, 
				av_wages_year AS year, 
				av_wages_quarter AS quarter, 
				calculation_type, 
				industry, 
				average_wages_growth,
				'%' AS growth_unit 
FROM t_lucie_navratilova_project_sql_primary_final
WHERE 	average_wages_growth < 0 
		AND calculation_code = 100 /*fyzický*/
		AND av_wages_quarter = '1'
ORDER BY year_prev, year, quarter, calculation_type, industry  
;

/*
 * typ kalkulace přepočtený - pokles růstu mezd
 */
SELECT 	DISTINCT
				av_wages_year_prev AS year_prev, 
				av_wages_year AS year, 
				av_wages_quarter AS quarter, 
				calculation_type, 
				industry, 
				average_wages_growth,
				'%' AS growth_unit 
FROM t_lucie_navratilova_project_sql_primary_final
WHERE 	average_wages_growth < 0 
		AND calculation_code = 200 /*přepočtený*/
		AND av_wages_quarter = '1'
;



