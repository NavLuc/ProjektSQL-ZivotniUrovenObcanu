/*
(pro dodatečná data o dalších evropských státech - HDP, GINI, daňová zátěž)
*/

CREATE OR REPLACE VIEW t_lucie_navratilova_project_SQL_secondary_final AS
SELECT 	    e.country, 
			e2.year as year_prev, 
	   		e.year, 
    		round( ( e.GDP - e2.GDP ) / e2.GDP * 100, 2 ) as GDP_growth,
    		round( ( e.population - e2.population ) / e2.population * 100, 2) as pop_growth_percent,
    		'%' AS growth_unit,
    		e.GDP,
    		e2.GDP AS GDP_prev,
    		e.gini AS gini,
    		e2.gini AS gini_prev,
    		e.population AS population,
    		e2.population AS population_prev
	FROM economies e
		JOIN countries c 
			ON e.country = c.country
			AND c.continent = 'Europe'
		JOIN economies e2 
    		ON e.country = e2.country 
    		AND e.year = e2.year + 1
    		AND e2.year + 1 IS NOT NULL
    WHERE 	
    	e.country = e2.country
    	AND e.GDP IS NOT NULL
    	AND e2.GDP IS NOT NULL
    	AND e.population IS NOT NULL
    	AND e2.population IS NOT NULL
    	AND e.gini IS NOT NULL 
    	AND e2.gini IS NOT NULL 
    ORDER BY e.country, e2.YEAR, e.year
;
