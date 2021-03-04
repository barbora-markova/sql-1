--Task 1 

SELECT product_name, company_new_name.company_name, company.company_number, products.product_code
FROM products 
JOIN bridge ON
	products.product_code = bridge.product_code
    AND bridge.end_date IS NULL
LEFT JOIN company ON
	bridge.company_code = company.company_number
LEFT JOIN 
		(SELECT *,
		max(company.extraction_date)
	FROM company
	GROUP BY company_number) AS COMPANY_NEW_NAME ON
    bridge.company_code = company_new_name.company_number
WHERE products.end_date is NULL    
GROUP BY company.company_number, bridge.product_code
ORDER BY product_name;



--Task 2

SELECT 
	company_number,
    company_new_name.company_name,
    products.product_code,
    IFNULL(sum(volume * exch_rate), 0) AS TOTAL_VOLUME,
	CASE 
        WHEN IFNULL(sum(volume * exch_rate), 0) BETWEEN 1 and 4000 THEN 'Low sells'
        WHEN IFNULL(sum(volume * exch_rate), 0) BETWEEN 4001 and 200000 THEN 'Medium  sells'
        WHEN IFNULL(sum(volume * exch_rate), 0) > 200000 THEN 'High sells'
        ELSE 'No sells' 
    END AS SELLS
FROM products 
JOIN bridge ON
	products.product_code = bridge.product_code
    AND bridge.end_date IS NULL
LEFT JOIN sales ON
	bridge.product_code = sales.product_code
    AND bridge.company_code = sales.company_code
LEFT JOIN 
		(SELECT *,
			max(company.extraction_date)
		FROM company
		Group by company_number) AS COMPANY_NEW_NAME ON
    bridge.company_code = company_new_name.company_number
LEFT JOIN exchange_rate_to_eur ON
	sales.currency = exchange_rate_to_eur.CURRENCY
WHERE products.end_date is NULL 
GROUP BY company_number, bridge.product_code;



--Task 3

SELECT
	sales.client_number
FROM sales
LEFT JOIN products ON
	sales.PRODUCT_CODE = products.PRODUCT_CODE
LEFT JOIN 
	(SELECT
		sales.client_number,
    	CASE 
        	WHEN product_code = 1 THEN 1
        	ELSE 0 
    	END AS BANK_ACCOUNT
	FROM sales
	WHERE bank_account = 1
    ) AS CLIENTS_WITH_BANK_ACCOUNT ON
    sales.client_number = clients_with_bank_account.client_number
WHERE sales.product_code in (10,5,2) AND bank_account is NULL
GROUP BY sales.client_number;




--Task 4

SELECT
	product_name,
    bridge.product_code,
    bridge.company_code,
    strftime('%Y',sales_date) as SALES_YEAR,
    sum(volume * exch_rate) AS TOTAL_VOLUME
FROM sales
JOIN bridge ON
	sales.product_code = bridge.product_code
    AND sales.company_code = bridge.company_code
LEFT JOIN exchange_rate_to_eur ON
	sales.currency = exchange_rate_to_eur.currency
LEFT JOIN products ON
	bridge.product_code = products.product_code
GROUP BY bridge.company_code, bridge.product_code, sales_year
HAVING TOTAL_VOLUME > 0
ORDER BY
	bridge.product_code,
    sales_year DESC;




--Task 5

SELECT
	sales.currency,
    round(sum(volume * exch_rate) / Total.total_sum * 100, 4) AS Percentage
FROM sales 
Left join exchange_rate_to_eur ON
	sales.currency = exchange_rate_to_eur.currency
LEFT join (
  select sum(volume * exch_rate) AS TOTAL_SUM
     from sales
	  Left join exchange_rate_to_eur ON
		sales.currency = exchange_rate_to_eur.currency
) AS Total
GROUP BY sales.currency
HAVING sales.currency = 'EUR';

