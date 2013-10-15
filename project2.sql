/* --- #8 --- */
/*	This trigger adds a row into the logs table, stating who opened a new account */

CREATE OR REPLACE TRIGGER acc_opened
	BEFORE INSERT ON transaction
	FOR EACH ROW
	WHEN (new.transaction_type = 'Open')
	DECLARE
		c_name customers.cname%TYPE;
	BEGIN
		/* uses new cid to get the name of customer to be able to insert into logs table  */
		SELECT cname INTO c_name
		FROM customers c
		WHERE c.cid = :new.cid;
		
		INSERT INTO logs (who, time, what) VALUES (c_name, SYSDATE, 'An account is opened');
	END;
	/
/*
	This is a trigger that adds a row into the logs table when a customer is added or deleted.
	It checks to see if an action is performed on the customers table. If it is inserting a new customer, then this trigger will fire and add the new customer information into the logs table. If it is deleting a customer, it will add the old customer info into the logs table.
*/
CREATE OR REPLACE TRIGGER add_del_cust
	BEFORE INSERT OR DELETE ON customers
	FOR EACH ROW
	BEGIN
		IF INSERTING THEN
			INSERT INTO logs (who, time, what) VALUES (:new.cname, SYSDATE, 'A customer is added to the customers table');
		ELSE
			INSERT INTO logs (who, time, what) VALUES (:old.cname, SYSDATE, 'A customer is deleted from the customers table');
		END IF;
	END;
	/
	
set serveroutput on

/* --- #1 --- Cannot have 5 digit log id because the script you gave us is making the attribute of logid a number instead of some sort of char. A number cannot have leading zeros. */
CREATE SEQUENCE log_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER log_insert
	BEFORE INSERT ON logs
	FOR EACH ROW 
	BEGIN
		SELECT log_seq.nextval INTO :NEW.logid FROM dual;
	END;
	/

/* Bank package initialization */
CREATE OR REPLACE PACKAGE banking AS
	/* --- #2 --- */
	PROCEDURE display_all_emp;
	/* --- #2 --- */
	PROCEDURE display_all_cust;
	/* --- #2 --- */
	PROCEDURE display_all_acc;
	/* --- #2 --- */
	PROCEDURE display_all_trans;
	/* --- #3 --- */
	PROCEDURE add_customer(cid IN CHAR, cname IN VARCHAR2, city IN VARCHAR2);
	/* --- #4 --- */
	PROCEDURE c_info(id IN CHAR);
	/* --- #5 --- */
	PROCEDURE a_info(id IN CHAR);
	/* --- #6 --- */
	PROCEDURE add_acc(tid IN CHAR, eid IN CHAR, cid IN CHAR, aid IN CHAR, amount IN NUMBER, type IN VARCHAR2, rate IN NUMBER);
	/* --- #7 --- */
	PROCEDURE add_trans(t_tid IN CHAR, e_eid IN CHAR, c_cid IN CHAR, a_aid IN CHAR, a_amount IN NUMBER, t_type IN VARCHAR2);
END;
/
	
/* Banking package body */
CREATE OR REPLACE PACKAGE BODY banking AS 		
		/* Display all employees */	
	PROCEDURE display_all_emp IS	
			/* Cursor to get all the employees from the table */
			CURSOR all_emp IS 
				SELECT eid, ename, city
				FROM employees;
			
			/* Set table types */	
			TYPE emp_id IS TABLE OF employees.eid%TYPE;
			TYPE emp_name IS TABLE OF employees.ename%TYPE;
			TYPE emp_city IS TABLE OF employees.city%TYPE;
			
			emp_ids emp_id;
			emp_names emp_name;
			emp_cities emp_city;
			/* Counter for loop */
			counter PLS_INTEGER;
		BEGIN
			OPEN all_emp;
			/* Fetches all the records into each array */
			FETCH all_emp BULK COLLECT INTO emp_ids, emp_names, emp_cities;
			CLOSE all_emp;
			
			/* Loops through each record and displays all the employees */
			FOR counter IN 1..emp_ids.count LOOP
				DBMS_OUTPUT.PUT_LINE ('ID: ' || emp_ids(counter) || '   NAME: ' || emp_names(counter) || '   CITY: ' || emp_cities(counter));
			END LOOP;
		END;
	
	
	/* Display all customers */
	/* This procedure uses the same method as procedure, display_all_emp */
	PROCEDURE display_all_cust IS
			CURSOR all_cust IS 
				SELECT cid, cname, city
				FROM customers;
				
			TYPE cust_id IS TABLE OF customers.cid%TYPE;
			TYPE cust_name IS TABLE OF customers.cname%TYPE;
			TYPE cust_city IS TABLE OF customers.city%TYPE;
			
			cust_ids cust_id;
			cust_names cust_name;
			cust_cities cust_city;
			counter PLS_INTEGER;
		BEGIN
			OPEN all_cust;
			FETCH all_cust BULK COLLECT INTO cust_ids, cust_names, cust_cities;
			CLOSE all_cust;
			
			FOR counter IN 1..cust_ids.count LOOP
				DBMS_OUTPUT.PUT_LINE ('ID: ' || cust_ids(counter) || '   NAME: ' || cust_names(counter) || '   CITY: ' || cust_cities(counter));
			END LOOP;
		END;
	
	
	/* Display all accounts */
	/* Uses same method as procedure, display_all_emp */
	PROCEDURE display_all_acc IS
			CURSOR all_acc IS 
				SELECT aid, account_type, rate, balance, date_opened
				FROM accounts;
				
			TYPE acc_id IS TABLE OF accounts.aid%TYPE;
			TYPE acc_type IS TABLE OF accounts.account_type%TYPE;
			TYPE acc_rate IS TABLE OF accounts.rate%TYPE;
			TYPE acc_balance IS TABLE OF accounts.balance%TYPE;
			TYPE acc_date IS TABLE OF accounts.date_opened%TYPE;
			
			acc_ids acc_id;
			acc_types acc_type;
			acc_rates acc_rate;
			acc_balances acc_balance;
			acc_dates acc_date;
			counter PLS_INTEGER;
		BEGIN
			OPEN all_acc;
			FETCH all_acc BULK COLLECT INTO acc_ids, acc_types, acc_rates, acc_balances, acc_dates;
			CLOSE all_acc;
			
			FOR counter IN 1..acc_ids.count LOOP
				DBMS_OUTPUT.PUT_LINE ('ID: ' || acc_ids(counter) || '   TYPE: ' || acc_types(counter) || ' RATE: ' || acc_rates(counter) || '   BALANCE: ' || acc_balances(counter) || '   DATE OPENED: ' || acc_dates(counter));
			END LOOP;
		END;
		
	
	/* Display all transactions */
	/* Uses same method as procedure, display_all_emp */
	PROCEDURE display_all_trans IS
			CURSOR all_trans IS 
				SELECT trans_num, eid, cid, aid, amount, transaction_type, date1
				FROM transaction;
				
			TYPE trans_id IS TABLE OF transaction.trans_num%TYPE;
			TYPE trans_eid IS TABLE OF transaction.eid%TYPE;
			TYPE trans_cid IS TABLE OF transaction.cid%TYPE;
			TYPE trans_aid IS TABLE OF transaction.aid%TYPE;
			TYPE trans_amount IS TABLE OF transaction.amount%TYPE;
			TYPE trans_type IS TABLE OF transaction.transaction_type%TYPE;
			TYPE trans_date IS TABLE OF transaction.date1%TYPE;
			
			trans_ids trans_id;
			trans_eids trans_eid;
			trans_cids trans_cid;
			trans_aids trans_aid;
			trans_amounts trans_amount;
			trans_types trans_type;
			trans_dates trans_date;
			counter PLS_INTEGER;
		BEGIN
			OPEN all_trans;
			FETCH all_trans BULK COLLECT INTO trans_ids, trans_eids, trans_cids, trans_aids, trans_amounts, trans_types, trans_dates;
			CLOSE all_trans;
			
			FOR counter IN 1..trans_ids.count LOOP
				DBMS_OUTPUT.PUT_LINE ('ID: ' || trans_ids(counter) || '   EID: ' || trans_eids(counter) || '   CID: ' || trans_cids(counter) || '   AID: ' || trans_aids(counter) || '   AMOUNT: ' || trans_amounts(counter) || '   TYPE: ' || trans_types(counter) || '   DATE: ' || trans_dates(counter));
			END LOOP;
		END;
		
	/* Add customer to customers table */
	PROCEDURE add_customer(cid IN CHAR, cname IN VARCHAR2, city IN VARCHAR2) IS
		BEGIN
			/* Inserts all the parameters into customers table */
			INSERT INTO customers VALUES (cid, cname, city);
		END;
		
	/* get customer info and all his accounts */	
	PROCEDURE c_info(id IN CHAR)
		IS
			/* Cursor to get name and all the account ids and types */
			CURSOR all_accounts IS 
				SELECT c.cid, c.cname, a.aid, a.account_type
				FROM customers c 
				LEFT JOIN transaction t on (t.cid = c.cid)
				LEFT JOIN accounts a on (a.aid = t.aid)
				WHERE c.cid = id
				GROUP BY c.cid, c.cname, a.aid, a.account_type;
			
			/* initialize array */
			TYPE c_id IS TABLE OF customers.cid%TYPE;
			TYPE c_name IS TABLE OF customers.cname%TYPE;
			TYPE a_id IS TABLE OF accounts.aid%TYPE;
			TYPE a_type IS TABLE OF accounts.account_type%TYPE;
			
			c_ids c_id;
			c_names c_name;
			a_ids a_id;
			a_types a_type;
			counter PLS_INTEGER;
		BEGIN
			OPEN all_accounts;
			/* stores all information into arrays */
			FETCH all_accounts BULK COLLECT INTO c_ids, c_names, a_ids, a_types;
			CLOSE all_accounts;
			
			/* If no match for ids */
			IF c_ids.count = 0 THEN
				DBMS_OUTPUT.PUT_LINE('The cid is invalid');
			/* If no match for accounts */
			ELSIF a_ids.count = 0 THEN
				DBMS_OUTPUT.PUT_LINE ('ID: ' || c_ids(1) || '   NAME: ' || c_names(1) || '   The customer has no accounts.');
			/* Displays customer id, name, and account information */
			ELSE
				FOR counter IN 1..a_ids.count LOOP
					DBMS_OUTPUT.PUT_LINE ('ID: ' || c_ids(1) || '   NAME: ' || c_names(1) || '   AID: ' || a_ids(counter) || '   A_TYPE: ' || a_types(counter));
				END LOOP;
			END IF;
		END;
	
	/* get account info and all its transactions */
	PROCEDURE a_info(id IN CHAR)
		IS 
			/* gets all the transaction information */
			CURSOR all_trans IS 
				SELECT t.aid, t.trans_num, t.amount, t.transaction_type, t.date1
				FROM transaction t 
				WHERE t.aid = id;	
				
			/* initialize arrays that will hold transaction information */
			TYPE t_aid IS TABLE OF transaction.aid%TYPE;
			TYPE t_id IS TABLE OF transaction.trans_num%TYPE;
			TYPE t_amount IS TABLE OF transaction.amount%TYPE;
			TYPE t_type IS TABLE OF transaction.transaction_type%TYPE;
			TYPE t_date IS TABLE OF transaction.date1%TYPE;
			
			t_aids t_aid;
			t_ids t_id;
			t_amounts t_amount;
			t_types t_type;
			t_dates t_date;
			counter PLS_INTEGER;
		BEGIN
			OPEN all_trans;
			/* stores information in arrays */
			FETCH all_trans BULK COLLECT INTO t_aids, t_ids, t_amounts, t_types, t_dates;
			CLOSE all_trans;
			
			/* if invalid aid */
			IF t_aids.count = 0 THEN
				DBMS_OUTPUT.PUT_LINE('The aid is invalid');
			/* if no transactions */
			ELSIF t_ids.count = 0 THEN
				DBMS_OUTPUT.PUT_LINE('AID: ' || t_aids(1) || '   No transaction found');
			/* Displays account and all of its transactions */
			ELSE
				FOR counter IN 1..t_ids.count LOOP
					DBMS_OUTPUT.PUT_LINE('AID: ' || t_aids(1) || '   TRANS_NUM: ' || t_ids(counter) || '   AMOUNT: ' || t_amounts(counter) || '   TYPE: ' || t_types(counter) || '   DATE: ' || t_dates(counter));
				END LOOP;
			END IF;
		END;
		
	/* Open account for customer */
	PROCEDURE add_acc(tid IN CHAR, eid IN CHAR, cid IN CHAR, aid IN CHAR, amount IN NUMBER, type IN VARCHAR2, rate IN NUMBER) IS
	
		/* Gets cid */
		CURSOR all_cust IS
			SELECT c.cid
			FROM customers c
			WHERE c.cid = cid;
		
		TYPE c_id IS TABLE OF customers.cid%TYPE;
		
		c_ids c_id;
		BEGIN
			OPEN all_cust;
			FETCH all_cust BULK COLLECT INTO c_ids;
			CLOSE all_cust;
			
			/* If cid does not exist */
			IF c_ids.count = 0 THEN
				DBMS_OUTPUT.PUT_LINE('The cid is invalid');
			ELSE
				/* Inserts into accounts first, then into transaction to satisfy foreign key constraint */
				INSERT INTO accounts VALUES (aid, type, rate, amount, SYSDATE);
				INSERT INTO transaction VALUES (tid, eid, cid, aid, amount, 'Open', SYSDATE);
			END IF;
		END;
				
	/* Add transaction to transaction table */
	PROCEDURE add_trans(t_tid IN CHAR, e_eid IN CHAR, c_cid IN CHAR, a_aid IN CHAR, a_amount IN NUMBER, t_type IN VARCHAR2) IS
	
		/* Used to get the correct eid */
		CURSOR emp_id IS
			SELECT e.eid
			FROM employees e
			WHERE e.eid = e_eid;
	
		/* Used to get the correct cid */
		CURSOR cust_id IS
			SELECT c.cid
			FROM customers c
			WHERE c.cid = c_cid;
			
		/* Used to get the correct aid and balance */
		CURSOR acc_info IS
			SELECT a.aid, a.balance
			FROM accounts a
			WHERE a.aid = a_aid;
			
		TYPE e_id IS TABLE OF employees.eid%TYPE;
		TYPE c_id IS TABLE OF customers.cid%TYPE;
		TYPE a_id IS TABLE OF accounts.aid%TYPE;
		TYPE a_balance IS TABLE OF accounts.balance%TYPE;
		
		e_ids e_id;
		c_ids c_id;
		a_ids a_id;
		a_balances a_balance;
	
		BEGIN
			
			OPEN emp_id;
			FETCH emp_id BULK COLLECT INTO e_ids;
			CLOSE emp_id;
			OPEN cust_id;
			FETCH cust_id BULK COLLECT INTO c_ids;
			CLOSE cust_id;
			OPEN acc_info;
			FETCH acc_info BULK COLLECT INTO a_ids, a_balances;
			
			/* If transaction_type is valid */
			IF (t_type = 'Open' OR t_type = 'Close' OR t_type = 'Withdraw' OR t_type = 'Deposit' OR t_type = 'Balance') THEN
				/* if eid exists */
				IF e_ids.count = 0 THEN
					DBMS_OUTPUT.PUT_LINE('The eid is invalid');
				/* if cid exists */
				ELSIF c_ids.count = 0 THEN
					DBMS_OUTPUT.PUT_LINE('The cid is invalid');
				/* if aid exists */
				ELSIF a_ids.count = 0 THEN
					DBMS_OUTPUT.PUT_LINE('The aid is invalid');
				/* if withdraw and amount > balance */
				ELSIF (t_type = 'Withdraw' AND a_amount > a_balances(1)) THEN
					DBMS_OUTPUT.PUT_LINE('Invalid transaction: Insufficient funds');
				/* else insert into transaction */
				ELSE
					INSERT INTO transaction VALUES (t_tid, e_eid, c_cid, a_aid, a_amount, t_type, SYSDATE);
				END IF;
			/* if transaction_type is invalid */
			ELSE
				DBMS_OUTPUT.PUT_LINE('Invalid transaction type');
			END IF;
		END;
				
			

 END;
 /
