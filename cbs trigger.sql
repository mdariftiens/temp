create trigger CBS_INSTRUCTIONS_HIS_ON_UPDATE
    after update
    on CBS_INSTRUCTIONS
    for each row
DECLARE
                  
                BEGIN
                
                INSERT INTO cbs_instructions_history
                   ( part_tran_srl_num,id,uuid,pr_id,pi_id,debit_ac,debit_ac_id,credit_ac,credit_ac_id,invoice_id,credit_amount,created_at,updated_at,transaction_date,cbs_transaction_id,payment_service,hundi_number,trail_count,payment_service_int,api_response,job_execution,branch_code,batch_id,dealer_code,is_consolidated,status,currency,pr_uuid,bank_id,pay_date,type,cbs_reference_id,loan_repayment_pi,transaction_type,suspense_status,updated_by,mail_type,cbs_remark,created_by,cron_flag,cbs_type,is_failure_mail_sent,cbs_narrations,credit_type,suspense_tran_remark,job_id , history_updated_at, action_history )
                   VALUES
                   ( :old.part_tran_srl_num,:old.id,:old.uuid,:old.pr_id,:old.pi_id,:old.debit_ac,:old.debit_ac_id,:old.credit_ac,:old.credit_ac_id,:old.invoice_id,:old.credit_amount,:old.created_at,:old.updated_at,:old.transaction_date,:old.cbs_transaction_id,:old.payment_service,:old.hundi_number,:old.trail_count,:old.payment_service_int,:old.api_response,:old.job_execution,:old.branch_code,:old.batch_id,:old.dealer_code,:old.is_consolidated,:old.status,:old.currency,:old.pr_uuid,:old.bank_id,:old.pay_date,:old.type,:old.cbs_reference_id,:old.loan_repayment_pi,:old.transaction_type,:old.suspense_status,:old.updated_by,:old.mail_type,:old.cbs_remark,:old.created_by,:old.cron_flag,:old.cbs_type,:old.is_failure_mail_sent,:old.cbs_narrations,:old.credit_type,:old.suspense_tran_remark,:old.job_id  , CURRENT_TIMESTAMP, 'Updated');
                END;



create trigger CBS_INSTRUCTIONS_HIS_ON_DEL
    before delete
    on CBS_INSTRUCTIONS
    for each row
DECLARE
                  
                BEGIN
                
                INSERT INTO cbs_instructions_history
                   ( part_tran_srl_num,id,uuid,pr_id,pi_id,debit_ac,debit_ac_id,credit_ac,credit_ac_id,invoice_id,credit_amount,created_at,updated_at,transaction_date,cbs_transaction_id,payment_service,hundi_number,trail_count,payment_service_int,api_response,job_execution,branch_code,batch_id,dealer_code,is_consolidated,status,currency,pr_uuid,bank_id,pay_date,type,cbs_reference_id,loan_repayment_pi,transaction_type,suspense_status,updated_by,mail_type,cbs_remark,created_by,cron_flag,cbs_type,is_failure_mail_sent,cbs_narrations,credit_type,suspense_tran_remark,job_id , history_updated_at, action_history )
                   VALUES
                   ( :old.part_tran_srl_num,:old.id,:old.uuid,:old.pr_id,:old.pi_id,:old.debit_ac,:old.debit_ac_id,:old.credit_ac,:old.credit_ac_id,:old.invoice_id,:old.credit_amount,:old.created_at,:old.updated_at,:old.transaction_date,:old.cbs_transaction_id,:old.payment_service,:old.hundi_number,:old.trail_count,:old.payment_service_int,:old.api_response,:old.job_execution,:old.branch_code,:old.batch_id,:old.dealer_code,:old.is_consolidated,:old.status,:old.currency,:old.pr_uuid,:old.bank_id,:old.pay_date,:old.type,:old.cbs_reference_id,:old.loan_repayment_pi,:old.transaction_type,:old.suspense_status,:old.updated_by,:old.mail_type,:old.cbs_remark,:old.created_by,:old.cron_flag,:old.cbs_type,:old.is_failure_mail_sent,:old.cbs_narrations,:old.credit_type,:old.suspense_tran_remark,:old.job_id  , CURRENT_TIMESTAMP, 'Delete');
                END;






create trigger CBS_INSTRUCTIONS_HIS_ON_INS
    after insert
    on CBS_INSTRUCTIONS
    for each row
DECLARE
                  
                BEGIN
                
                INSERT INTO cbs_instructions_history
                   ( part_tran_srl_num,id,uuid,pr_id,pi_id,debit_ac,debit_ac_id,credit_ac,credit_ac_id,invoice_id,credit_amount,created_at,updated_at,transaction_date,cbs_transaction_id,payment_service,hundi_number,trail_count,payment_service_int,api_response,job_execution,branch_code,batch_id,dealer_code,is_consolidated,status,currency,pr_uuid,bank_id,pay_date,type,cbs_reference_id,loan_repayment_pi,transaction_type,suspense_status,updated_by,mail_type,cbs_remark,created_by,cron_flag,cbs_type,is_failure_mail_sent,cbs_narrations,credit_type,suspense_tran_remark,job_id , history_updated_at, action_history )
                   VALUES
                   ( :new.part_tran_srl_num,:new.id,:new.uuid,:new.pr_id,:new.pi_id,:new.debit_ac,:new.debit_ac_id,:new.credit_ac,:new.credit_ac_id,:new.invoice_id,:new.credit_amount,:new.created_at,:new.updated_at,:new.transaction_date,:new.cbs_transaction_id,:new.payment_service,:new.hundi_number,:new.trail_count,:new.payment_service_int,:new.api_response,:new.job_execution,:new.branch_code,:new.batch_id,:new.dealer_code,:new.is_consolidated,:new.status,:new.currency,:new.pr_uuid,:new.bank_id,:new.pay_date,:new.type,:new.cbs_reference_id,:new.loan_repayment_pi,:new.transaction_type,:new.suspense_status,:new.updated_by,:new.mail_type,:new.cbs_remark,:new.created_by,:new.cron_flag,:new.cbs_type,:new.is_failure_mail_sent,:new.cbs_narrations,:new.credit_type,:new.suspense_tran_remark,:new.job_id  , CURRENT_TIMESTAMP, 'Inserted');                     
                END;

