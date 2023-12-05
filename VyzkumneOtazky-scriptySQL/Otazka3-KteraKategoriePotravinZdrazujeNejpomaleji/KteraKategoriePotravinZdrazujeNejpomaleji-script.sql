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
 * 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 * */

WITH czechia_price_growth_per_year AS ( /*Růst cen potravin meziročně - za roky a srovnatelný první kvartál*/
	SELECT 	DISTINCT
			category_code,
			category_name,
	   		price, 
	   		price_year_prev AS year_prev, 
	   		price_year AS year, 
	   		price_quarter AS quarter,
       		price_growth,
       		'%' AS price_growth_unit 
	FROM 	t_lucie_navratilova_project_sql_primary_final
	WHERE 	price_growth IS NOT NULL 
			AND price_quarter = '1'
),
czechia_price_growth_avg AS ( /*Průměrná cena potravin meziročně dle kategorie potravin*/
	SELECT 	category_code,
			category_name,
	   		AVG(price_growth) AS avg_price_growth_per_years
	FROM    czechia_price_growth_per_year
	WHERE price_growth > 0
	GROUP BY category_code, category_name     
),
czechia_price_min_growth AS ( /*Určena potravina, která měla nejmenší průměrný růst.*/
	SELECT category_code 
	FROM czechia_price_growth_avg cpga
	WHERE avg_price_growth_per_years IN (
			SELECT MIN(avg_price_growth_per_years) FROM  czechia_price_growth_avg cpga2)
)
SELECT  cpga.category_name,
		avg_price_growth_per_years,
		'%' AS price_growth_unit 
		FROM czechia_price_growth_avg cpga
		WHERE category_code IN (
			SELECT category_code FROM czechia_price_min_growth
		)
GROUP BY category_name;		


