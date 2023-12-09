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
    2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
*/
WITH common_years AS ( /*společné období cen potravin a mezd pro případ porovnání*/
	SELECT DISTINCT
			av_wages_year_prev AS year 
	FROM t_lucie_navratilova_project_sql_primary_final  
	WHERE 	category_code IN ('111301','114201')
			AND czechia_price_value_prev IS NOT NULL 
			AND average_wages_value_prev IS NOT NULL
	GROUP BY year
),
prices_and_average_wages_per_min_period AS ( /*ceny potravin a mzdy za první dostupné období a zároveň první kvartál (aby meziroční období bylo srovnatelné)*/
	SELECT DISTINCT
    				category_name AS food_category,
    				calculation_code,
    				czechia_price_value_prev AS price_per_min_period,
    				price AS price_list,
    				industry, 
    				industry_code, 
    				average_wages_value_prev AS average_wages_per_min_period,
    				amount_of_food_per_av_wages_prev AS  amount_of_food_per_av_wages_min_period,
    				av_wages_year_prev AS min_period_year,
    				av_wages_quarter AS min_period_quarter
	FROM t_lucie_navratilova_project_sql_primary_final 
	WHERE 	category_code IN ('111301','114201')
		AND av_wages_year_prev IN (SELECT MIN(year) FROM common_years cy)
		AND calculation_code = '200'
		AND av_wages_quarter = '1'
	ORDER BY category_name, min_period_year DESC
),
prices_and_average_wages_per_max_period AS ( /*ceny potravin a mzdy za poslední dostupné období a zároveň první kvartál (aby meziroční období bylo srovnatelné)*/
	SELECT DISTINCT
    				category_name AS food_category,
    				calculation_code,
    				czechia_price_value_prev AS price_per_max_period,
    				price AS price_list,
    				industry, 
    				industry_code,
    				average_wages_value_prev AS average_wages_per_max_period,
    				amount_of_food_per_av_wages_prev AS  amount_of_food_per_av_wages_max_period,
    				av_wages_year_prev AS max_period_year,
    				av_wages_quarter AS max_period_quarter
	FROM t_lucie_navratilova_project_sql_primary_final 
	WHERE 	category_code IN ('111301','114201')
		AND av_wages_year_prev IN (SELECT MAX(year) FROM common_years cy)
		AND calculation_code = '200'
		AND av_wages_quarter = '1'
	ORDER BY category_name, max_period_year DESC
)
SELECT 
	   pawmin.industry,
	   pawmin.industry_code,
	   amount_of_food_per_av_wages_max_period,
	   amount_of_food_per_av_wages_min_period,
	   average_wages_per_max_period, 
	   average_wages_per_min_period, 
	   pawmin.food_category,  
	   CONCAT(price_per_min_period, ' ', pawmin.price_list) AS price_per_min_period,
	   CONCAT(price_per_max_period, ' ', pawmax.price_list) AS price_per_max_period, 
	   min_period_year,
	   max_period_year,
	   max_period_quarter
FROM prices_and_average_wages_per_max_period pawmax
	JOIN prices_and_average_wages_per_min_period pawmin 
		ON pawmax.food_category = pawmin.food_category
		AND pawmax.industry_code = pawmin.industry_code
		AND pawmax.max_period_quarter = pawmin.min_period_quarter
ORDER BY amount_of_food_per_av_wages_max_period DESC;



