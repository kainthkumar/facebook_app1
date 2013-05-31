alter table stock_symbols add `foreign` boolean default false;
alter table stock_symbols add `fund` boolean default false;
ALTER TABLE `stock_symbols` MODIFY `company_name` VARCHAR(100)