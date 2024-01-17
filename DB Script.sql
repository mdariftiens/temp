declare
    mainTableName                 varchar2(100);
    historyTableName              varchar2(100);
    mainTableColNames             VARCHAR2(5000);
    historyTableColNames          VARCHAR2(5000);
    historyTableColNamesForDelete VARCHAR2(5000);
    insertQuery                   VARCHAR2(5000);
    updateQuery                   VARCHAR2(5000);
    deleteQuery                   VARCHAR2(5000);
    insertTrigger                 VARCHAR2(5000);
    updateTrigger                 VARCHAR2(5000);
    deleteTrigger                 VARCHAR2(5000);
    insertTriggerName             VARCHAR2(100);
    updateTriggerName             VARCHAR2(100);
    deleteTriggerName             VARCHAR2(100);

begin
    FOR histable IN (SELECT table_name
                     FROM all_tables
                     WHERE table_name LIKE '%\_HISTORY' ESCAPE '\' and TABLE_NAME not in
                                                                       ('DF_DAILY_INTEREST_ACCRUAL_HISTORY',
                                                                        'DF_DEALER_MASTER_HISTORY',
                                                                        'PASSWORD_POLICY_HISTORY',
                                                                        'CUSTOMER_BANK_ACCOUNT_MASTER_HISTORY',
                                                                        'PASS_HISTORY', 'PASSWORD_HISTORY',
                                                                        'NPA_HISTORY', 'LIMIT_HISTORY',
                                                                        'TAKEOVER_TRANSACTIONS_VF_HISTORY'))
        LOOP
            historyTableName := lower(histable.TABLE_NAME);
            mainTableName := (replace(lower(histable.table_name), '_history', ''));

            if historyTableName = 'dfband_discoun_rates_history' then
                mainTableName := 'histabledf_band_discounting_rates';
            elsif historyTableName = 'dfband_discoun_rates_history' then
                mainTableName := 'df_band_discounting_rates';
            elsif historyTableName = 'dfod_discoun_rates_history' then
                mainTableName := 'df_od_discounting_rates';
            elsif historyTableName = 'factoring_invoice_pay_history' then
                mainTableName := 'factoring_invoice_payments';
            end if;

            DBMS_OUTPUT.PUT_LINE(mainTableName || ' => ' || historyTableName);

            FOR col IN (SELECT column_name, data_type, data_length, data_precision
                        FROM all_tab_columns
                        WHERE lower(table_name) = mainTableName

                          AND column_name NOT IN (SELECT column_name
                                                  FROM all_tab_columns
                                                  WHERE lower(table_name) = historyTableName))
                LOOP

                    IF mainTableName is not null  THEN
                        DBMS_OUTPUT.PUT_LINE('col name ' || col.COLUMN_NAME || ' of ' || mainTableName || ' table ' ||
                                             ' not fund in ' || historyTableName);
                        --AddMissingColumns(mainTableName, historyTableName);


                        FOR column_rec IN (SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE
                                           FROM USER_TAB_COLUMNS
                                           WHERE lower(TABLE_NAME) = lower(mainTableName))
                            LOOP
                                BEGIN
                                    -- Try to select the column in the history table
                                    EXECUTE IMMEDIATE 'SELECT ' ||
                                                      lower(column_rec.COLUMN_NAME)
                                        || ' FROM ' || historyTableName || ' WHERE ROWNUM = 1';
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        -- If an exception occurs, the column is missing
                                        DECLARE
                                            v_sql_statement VARCHAR2(1000);
                                        BEGIN
                                            -- Generate dynamic SQL to add the missing column with the same definition


                                            v_sql_statement := 'ALTER TABLE ' || historyTableName || ' ADD ' || case
                                                                                                                    when lower(column_rec.COLUMN_NAME) = 'date'
                                                                                                                        THEN  '"'||UPPER(column_rec.COLUMN_NAME) || '"'
                                                                                                                    ELSE upper(column_rec.COLUMN_NAME) END ||
                                                               ' ' || column_rec.DATA_TYPE || ' ';
                                            IF column_rec.DATA_TYPE = 'VARCHAR2' OR column_rec.DATA_TYPE = 'CHAR' THEN
                                                v_sql_statement := v_sql_statement || '(' || column_rec.DATA_LENGTH || ')';
                                            ELSIF column_rec.DATA_TYPE = 'NUMBER' THEN
                                                IF column_rec.DATA_SCALE IS NOT NULL THEN
                                                    v_sql_statement := v_sql_statement || '(' || (case
                                                                                                      when column_rec.DATA_PRECISION is null
                                                                                                          then 20
                                                                                                      else column_rec.DATA_PRECISION end) ||
                                                                       ',' || column_rec.DATA_SCALE || ')';
                                                ELSE
                                                    v_sql_statement := v_sql_statement || '(' || (case
                                                                                                      when column_rec.DATA_PRECISION is null
                                                                                                          then 20
                                                                                                      else column_rec.DATA_PRECISION end) ||
                                                                       ')';
                                                END IF;
                                            ELSIF column_rec.DATA_TYPE = 'DATE' THEN
                                                -- Do nothing, as DATE columns do not have a size or precision
                                                NULL;
                                            ELSIF column_rec.DATA_TYPE = 'TIMESTAMP' AND column_rec.DATA_SCALE = 6 THEN
                                                v_sql_statement := v_sql_statement || '(6)';
                                            END IF;


                                            DBMS_OUTPUT.PUT_LINE(v_sql_statement || ' DEFAULT NULL' || ': the statement');

                                            EXECUTE IMMEDIATE v_sql_statement || ' DEFAULT NULL';
                                            DBMS_OUTPUT.PUT_LINE('Column ' || column_rec.COLUMN_NAME || ' added successfully.');
                                        EXCEPTION
                                            WHEN OTHERS THEN
                                                DBMS_OUTPUT.PUT_LINE('Error adding column ' || column_rec.COLUMN_NAME || ': ' || SQLERRM);
                                        END;
                                END;
                            END LOOP;
                        commit;


                        -- trigger part
                        mainTableName := UPPER(mainTableName);
                        historyTableName := UPPER(historyTableName);

                        SELECT LISTAGG(case
                                           when lower(column_name) = 'date' THEN '"' || UPPER(column_name) || '"'
                                           ELSE upper(column_name) END, ', ')
                        into mainTableColNames
                        FROM all_tab_columns
                        WHERE table_name = mainTableName;

                        SELECT LISTAGG(':NEW.' || case
                                                      when lower(column_name) = 'date'
                                                          THEN '"' || UPPER(column_name) || '"'
                                                      ELSE upper(column_name) END || '', ', ')
                        into historyTableColNames
                        FROM all_tab_columns
                        WHERE table_name = mainTableName;
                        SELECT LISTAGG(':OLD.' || case
                                                      when lower(column_name) = 'date'
                                                          THEN '"' || UPPER(column_name) || '"'
                                                      ELSE upper(column_name) END || '', ', ')
                        into historyTableColNamesForDelete
                        FROM all_tab_columns
                        WHERE table_name = mainTableName;


                        insertQuery := 'INSERT INTO ' || historyTableName || '
                                   (  ' || mainTableColNames || ' , HISTORY_UPDATED_AT, ACTION_HISTORY )
                                   VALUES
                                   ( ' || historyTableColNames || '  , CURRENT_TIMESTAMP, ' || '''Inserted'' );';


                        updateQuery := 'INSERT INTO ' || historyTableName || '
                                   (  ' || mainTableColNames || ' , HISTORY_UPDATED_AT, ACTION_HISTORY )
                                   VALUES
                                   ( ' || historyTableColNames || '  , CURRENT_TIMESTAMP, ' || '''Updated'' );';

                        deleteQuery := 'INSERT INTO ' || historyTableName || '
                                   (  ' || mainTableColNames || ' , HISTORY_UPDATED_AT, ACTION_HISTORY )
                                   VALUES
                                   ( ' || historyTableColNamesForDelete || '  , CURRENT_TIMESTAMP, ' || '''Delete'' );';

                        DBMS_OUTPUT.PUT_LINE('mainTableColNames');
                        DBMS_OUTPUT.PUT_LINE(mainTableColNames);
                        DBMS_OUTPUT.PUT_LINE('historyTableColNames');
                        DBMS_OUTPUT.PUT_LINE(historyTableColNames);


                        insertTriggerName := mainTableName || '_HIS_ON_INS';
                        insertTrigger := 'CREATE OR REPLACE TRIGGER ' || insertTriggerName || '
                                AFTER INSERT
                                   ON ' || mainTableName || '
                                   FOR EACH ROW
                                DECLARE
                                BEGIN ' || insertQuery || '
                                END;';

                        DBMS_OUTPUT.PUT_LINE(insertTriggerName);
                        DBMS_OUTPUT.PUT_LINE(insertTrigger);

                        --EXECUTE IMMEDIATE 'DROP TRIGGER ' || insertTriggerName;

                        EXECUTE IMMEDIATE insertTrigger;


                        updateTriggerName := mainTableName || '_HIS_ON_UPDATE';

                        updateTrigger := 'CREATE OR REPLACE TRIGGER ' || updateTriggerName || '
                                AFTER UPDATE
                                   ON ' || mainTableName || '
                                   FOR EACH ROW
                                DECLARE
                                BEGIN
                                ' || updateQuery || '
                                END;';
                        DBMS_OUTPUT.PUT_LINE(updateTriggerName);
                        DBMS_OUTPUT.PUT_LINE(updateTrigger);

                        -- EXECUTE IMMEDIATE 'DROP TRIGGER ' || updateTriggerName;

                        EXECUTE IMMEDIATE updateTrigger;


                        deleteTriggerName := mainTableName || '_HIS_ON_DEL';
                        deleteTrigger := 'CREATE OR REPLACE TRIGGER ' || deleteTriggerName || '
                        BEFORE DELETE
                           ON ' || mainTableName || '
                           FOR EACH ROW
                        DECLARE
                        BEGIN
                            ' || deleteQuery || '
                        END;';
                        DBMS_OUTPUT.PUT_LINE(deleteTriggerName);
                        DBMS_OUTPUT.PUT_LINE(deleteTrigger);

                        -- EXECUTE IMMEDIATE 'DROP TRIGGER ' || deleteTriggerName;

                        EXECUTE IMMEDIATE deleteTrigger;

                        COMMIT;


                    END IF;

                END LOOP;
        END LOOP;
end;

