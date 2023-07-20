SELECT max(od_transactions.od_account_id) AS id, rtrim( xmlagg(xmlelement(e,NVL (od_transactions.id, NULL),',').extract('//text()') order by NVL (od_transactions.id, NULL)).getclobval() ,',') AS odt_ids, SUM (od_transactions.interest_balance) AS interest_balance_sum, SUM (od_transactions.penal_interest) AS penal_interest_sum, ( SUM (od_transactions.interest_balance) + SUM (od_transactions.penal_interest)) AS int_sum, rtrim( xmlagg(xmlelement(e,NVL (od_transactions.currency, NULL),',').extract('//text()') order by NVL (od_transactions.currency, NULL)).getclobval() ,',') AS odt_currency, rtrim( xmlagg(xmlelement(e,NVL (od_transactions.invoice_id, NULL),',').extract('//text()') order by NVL (od_transactions.invoice_id, NULL)).getclobval() ,',') AS loan_ids, rtrim( xmlagg(xmlelement(e,NVL (od_transactions.applied_base_rate, NULL),',').extract('//text()') order by NVL (od_transactions.applied_base_rate, NULL)).getclobval() ,',') AS applied_base_rates, rtrim( xmlagg(xmlelement(e,NVL (od_transactions.seasonal_limit_id, NULL),',').extract('//text()') order by NVL (od_transactions.seasonal_limit_id, NULL)).getclobval() ,',') AS seasonal_limit_ids, rtrim( xmlagg(xmlelement(e,to_char(od_transactions.particulars),',').extract('//text()') order by to_char(od_transactions.particulars)).getclobval() ,',') AS particulars, rtrim( xmlagg(xmlelement(e,NVL (od_transactions.interest_balance, NULL),',').extract('//text()') order by NVL (od_transactions.interest_balance, NULL)).getclobval() ,',') AS interest_balance_details, rtrim( xmlagg(xmlelement(e,NVL (od_transactions.penal_interest, NULL),',').extract('//text()') order by NVL (od_transactions.penal_interest, NULL)).getclobval() ,',') AS penal_interest_details, rtrim( xmlagg(xmlelement(e,od_transactions.invoice_number,',').extract('//text()') order by od_transactions.invoice_number).getclobval() ,',') AS invoice_numbers, rtrim( xmlagg(xmlelement(e,NVL (od_transactions.invoice_id, NULL),',').extract('//text()') order by NVL (od_transactions.invoice_id, NULL)).getclobval() ,',') AS invoice_ids, rtrim( xmlagg(xmlelement(e,NVL (od_transactions.discounting_id, NULL),',').extract('//text()') order by NVL (od_transactions.discounting_id, NULL)).getclobval() ,',') AS discountingids, MAX(cd.name) AS distributor_name, MAX(cd.is_npa) AS is_npa, MAX(b.id) AS bank_id, MAX(cd.identification_no) AS buyer_identification_no, MAX(od_accounts.distributor_id) AS distributor_id, MAX(br.code) AS branch_code, MAX(to_char(b.configurations)) AS bank_configurations, rtrim( xmlagg(xmlelement(e,NVL (od_transactions.payment_request_id, NULL),',').extract('//text()') order by NVL (od_transactions.payment_request_id, NULL)).getclobval() ,',') AS payment_request_ids, (CASE WHEN JSON_VALUE ( b.configurations,'$.basic_configuration.round_off_repayments') IS NOT NULL THEN CAST (JSON_VALUE ( b.configurations,'$.basic_configuration.round_off_repayments') As DECIMAL (4, 2)) ELSE 0 END) min_amount, max(cbc.id) AS credit_to_id, max(od_accounts.account_number) AS debit_from, (CASE WHEN JSON_VALUE ( b.configurations,'$.basic_configuration.dis_interest_account_branch_specific') = 1 THEN br.code ||'~'||cbc.account_no ELSE cbc.account_no END) credit_to, max(cbp.id) AS credit_penal_to_id, (CASE WHEN JSON_VALUE ( b.configurations,'$.basic_configuration.dis_penal_interest_account_branch_specific') = 1 THEN br.code ||'~'||cbp.account_no ELSE cbp.account_no END) credit_penal_to, max(od_accounts.available_limit) as available_limit FROM OD_TRANSACTIONS LEFT JOIN PAYMENT_REQUESTS ON OD_TRANSACTIONS.PAYMENT_REQUEST_ID = PAYMENT_REQUESTS.ID LEFT JOIN OD_ACCOUNTS ON PAYMENT_REQUESTS.OD_ACCOUNT_ID = OD_ACCOUNTS.ID LEFT JOIN BANKS b ON B.ID = OD_ACCOUNTS.BANK_ID LEFT JOIN COMPANY_BANKS cb ON CB.ID = JSON_VALUE ( b . configurations, '$.basic_configuration.separate_interest_receivable_account_from_overdraft') left join COMPANY_BANKS cbc on CBC.ID = JSON_VALUE (b.configurations, '$.basic_configuration.dis_interest_account') left join COMPANY_BANKS cbp on CBP.ID = JSON_VALUE(b.configurations,'$.basic_configuration.dis_penal_interest_recievable_account') left join DISCOUNTINGS on PAYMENT_REQUESTS.PI_ID = DISCOUNTINGS.PI_ID and DISCOUNTINGS.STATUS = 7 left join PAYMENT_INSTRUCTIONS on DISCOUNTINGS.PI_ID = PAYMENT_INSTRUCTIONS.ID left join COMPANIES ca on OD_ACCOUNTS.ANCHOR_ID = CA.ID left join COMPANIES cd on OD_ACCOUNTS.DISTRIBUTOR_ID = CD.ID left join BRANCHES br on CD.BRANCH_ID = BR.ID where(INTEREST_BALANCE > 0 or PENAL_INTEREST > 0 )and OD_TRANSACTIONS.IS_OVERDUE not in (1,2) group by od_transactions.od_account_id, CASE WHEN JSON_VALUE ( b.configurations,'$.basic_configuration.round_off_repayments') IS NOT NULL THEN CAST (JSON_VALUE ( b.configurations,'$.basic_configuration.round_off_repayments') As DECIMAL (4, 2)) ELSE 0 END, CASE WHEN JSON_VALUE ( b.configurations,'$.basic_configuration.dis_interest_account_branch_specific') = 1 THEN br.code ||'~'||cbc.account_no ELSE cbc.account_no END, CASE WHEN JSON_VALUE ( b.configurations,'$.basic_configuration.dis_penal_interest_account_branch_specific') = 1 THEN br.code ||'~'||cbp.account_no ELSE cbp.account_no END