
insert into stock_symbols (symbol,company_name,processing_host,last_process_date,created_at,updated_at)
values ('^IXIC','NASDAQ Composite',NULL,'1970-01-01 00:00:01',NOW(),NOW()),
('$INDU','Dow Jones Industrial Average',NULL,'1970-01-01 00:00:01',NOW(),NOW()),
('^GSPC','S&P 500',NULL,'1970-01-01 00:00:01',NOW(),NOW());

alter table stock_symbols add category varchar(60) after company_name;