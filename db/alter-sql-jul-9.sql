alter table stock_symbols add market varchar(50);
alter table stock_symbols add enable varchar(5) default 'true';
alter table stock_symbols add `type_stock` varchar(5) default 'stock';
update stock_symbols set `type_stock` = 'index' where symbol REGEXP '^[^a-z]';