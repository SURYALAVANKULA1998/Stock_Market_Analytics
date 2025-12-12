-- Total Market Capitalization
SELECT 
    SUM(share_price * outstanding_shares) AS total_market_cap
FROM
    `stock market new.xlsx - stocks`;

-- Average Daily Trading Volume
SELECT 
    AVG(volume) AS avg_daily_trading_volume
FROM
    `stock market new.xlsx - fact_daily_prices`;

-- Volatility = Std Dev of Daily Returns
SELECT 
    STDDEV((close - open) / open) AS volatility
FROM
    `stock market new.xlsx - fact_daily_prices`;

--  Top Performing Sector
SELECT 
    sector, AVG(return_pct) AS avg_return
FROM
    `stock market new.xlsx - stocks`
GROUP BY sector
ORDER BY avg_return DESC
LIMIT 1;

-- Portfolio Value (Your Current Holdings)
SELECT 
    SUM(quantity * share_price) AS portfilio_value
FROM
    `stock market new.xlsx - stocks`;

--  Portfolio Return %
SELECT 
    company_name,
    ((SUM(current_value) - SUM(initial_value)) / SUM(initial_value)) * 100 AS portfolio_return_pct
FROM
    `stock market new.xlsx - stocks`
GROUP BY company_name;

-- Divident Yield 
SELECT 
    dc.company_name,
    SUM(fd.dividend_per_share) AS total_dividend_per_share,
    ROUND((SUM(fd.dividend_per_share) / AVG(s.share_price)) * 100,
            2) AS dividend_yield
FROM
    `stock market new.xlsx - fact_dividends` fd
        JOIN
    `stock market new.xlsx - dim_company` dc ON fd.company_id = dc.company_id
        JOIN
    `stock market new.xlsx - stocks` s ON dc.company_name = s.company_name
GROUP BY dc.company_name;
    
-- Sharpe ratio
SELECT 
    (portfolio_return - 0.05) / volatility AS sharpe_ratio
FROM
    (SELECT 
        ((SUM(current_value) - SUM(initial_value)) / SUM(initial_value)) AS portfolio_return,
            (SELECT 
                    STDDEV((close - open) / open)
                FROM
                    `stock market new.xlsx - fact_daily_prices`) AS volatility
    FROM
        `stock market new.xlsx - stocks`) AS t;
        
-- TRADER PERFORMANCE
SELECT 
    dc.company_name,
    SUM(CASE
        WHEN ft.side = 'SELL' THEN (ft.price * ft.quantity - ft.fees)
        WHEN ft.side = 'BUY' THEN -(ft.price * ft.quantity + ft.fees)
    END) AS trader_performance
FROM
    `stock market new.xlsx - fact_trades` ft
        JOIN
    `stock market new.xlsx - dim_company` dc ON ft.company_id = dc.company_id
GROUP BY dc.company_name;


