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
 



/*Kontroly dat
 * */  
 /*
  * U sloupcu tabulek, kde je povolena hodnota NULL - zjisteni, kde je nevyplneno
  * */
SELECT *
FROM 
(
	SELECT  id,
        	IF (industry_branch_code IS NULL, 'Unknown industry branch', industry_branch_code) AS industry_branch_code,
			IF (industry_branch_code IS NULL, 1, 0) AS is_unknown_industry		
	FROM czechia_payroll cp 
	WHERE 	cp.value_type_code = 5958 
			AND cp.unit_code = '200'

) AS unknown_industry_code
WHERE is_unknown_industry = '1';

SELECT *
FROM 
(
	SELECT  id,
        	IF (payroll_year IS NULL, 'Unknown payroll year', payroll_year) AS payroll_year,
			IF (payroll_year IS NULL, 1, 0) AS is_unknown_payroll_year	
	FROM czechia_payroll cp 
	WHERE 	cp.value_type_code = 5958 
			AND cp.unit_code = '200'

) AS unknown_payroll_year
WHERE is_unknown_payroll_year = '1';

SELECT *
FROM 
(
	SELECT  id,
        	IF (payroll_quarter IS NULL, 'Unknown payroll quarter', payroll_quarter) AS payroll_quarter,
			IF (payroll_quarter IS NULL, 1, 0) AS is_unknown_payroll_quarter
	FROM czechia_payroll cp 
	WHERE 	cp.value_type_code = 5958 
			AND cp.unit_code = '200'

) AS unknown_payroll_quarter
WHERE is_unknown_payroll_quarter = '1';

SELECT *
FROM 
(
	SELECT  id,
        	IF (value IS NULL OR value = '0', 'Unknown or 0 value', value) AS payroll_value,
			IF (value IS NULL OR value = '0', 1, 0) AS is_unknown_or0_payroll_value
	FROM czechia_payroll cp 
	WHERE 	cp.value_type_code = 5958 
			AND cp.unit_code = '200'

) AS unknownOr0_payroll_value
WHERE is_unknown_or0_payroll_value = '1';

SELECT *
FROM 
(
	SELECT  id,
        	IF (region_code IS NULL, 'Unknown region code', region_code) AS region_code,
			IF (region_code IS NULL, 1, 0) AS is_unknown_region_code
	FROM czechia_price cp 

) AS unknown_region_code
WHERE is_unknown_region_code = '1';

SELECT *
FROM 
(
	SELECT  id,
        	IF (value IS NULL OR value = '0', 'Unknown or 0 value', value) AS czechia_price_value,
			IF (value IS NULL OR value = '0', 1, 0) AS is_unknown_or0_czechia_price_value
	FROM czechia_price cp 

) AS unknownOr0_czechia_price_value
WHERE is_unknown_or0_czechia_price_value = '1';

SELECT *
FROM 
(
	SELECT  year,
        	IF (country IS NULL, 'Unknown country', country) AS country,
			IF (country IS NULL, 1, 0) AS is_unknown_country
	FROM economies e 
	WHERE country = 'Czech Republic'

) AS unknown_country
WHERE is_unknown_country = '1';

SELECT *
FROM 
(
	SELECT  year,
			IF (country IS NULL, 'Unknown country', country) AS country,
        	IF (GDP IS NULL OR GDP = '0', 'Unknown or 0 GDP', GDP) AS GDP,
			IF (GDP IS NULL OR GDP = '0', 'Unknown or 0 GDP', GDP) AS is_unknown_or0_GDP
	FROM economies e 

) AS unknownOr0_GDP
WHERE is_unknown_or0_GDP = '1';


SELECT *
FROM 
(
	SELECT  year,
			IF (country IS NULL, 'Unknown country', country) AS country,
        	IF (population IS NULL OR population = '0', 'Unknown or 0 population', population) AS population,
			IF (population IS NULL OR population = '0', 'Unknown or 0 population', population) AS is_unknown_or0_population
	FROM economies e 

) AS unknownOr0_population
WHERE is_unknown_or0_population = '1';


SELECT *
FROM 
(
	SELECT  year,
			IF (country IS NULL, 'Unknown country', country) AS country,
        	IF (gini IS NULL OR gini = '0', 'Unknown or 0 gini', gini) AS gini,
			IF (gini IS NULL OR gini = '0', 'Unknown or 0 gini', gini) AS is_unknown_or0_gini
	FROM economies e 

) AS unknownOr0_gini
WHERE is_unknown_or0_gini = '1';

 /*
  * U sloupcu, kde se pocita porovnavaci index - osetrit hodnoty = '0'
  * */

    
 /*
  * Vyresit duplicity, ktere jsou v ciselnicich - jestli neexistuje jen mirne modifikovany nazev pro totez - zjisteno, ze se naseho projektu netyka
  * */  
    
/*Pozor na duplicitni hodnoty - jako prepoctene a fyzicke u  czechia_payroll
   * */  
    
/*mame DATA za vsechny kvartaly v roce? Pro mezirocni srovnani za srovnatelne obdobi
 * 
 * - za 1 kvartal ano
 * V poslednim roce chybi data za kvartaly
 * */




