import oracle.jdbc.*;
import java.sql.*;
import java.math.*;
import java.io.*;
import java.awt.*;
import oracle.jdbc.pool.OracleDataSource;
import java.util.Scanner;
import java.text.DateFormat;
import java.util.Date;
import java.io.BufferedReader;
import java.io.InputStreamReader;

/* This class displays the output from plsql dbms_output.put_line */
class DbmsOutput {
	private CallableStatement enable_stmt;
	private CallableStatement disable_stmt;
	private CallableStatement show_stmt;


	public DbmsOutput( Connection conn ) throws SQLException {
    		enable_stmt  = conn.prepareCall( "begin dbms_output.enable(:1); end;" );
    		disable_stmt = conn.prepareCall( "begin dbms_output.disable; end;" );

    		show_stmt = conn.prepareCall( 
          		"declare " +
          		"    l_line varchar2(255); " +
          		"    l_done number; " +
          		"    l_buffer long; " +
          		"begin " +
          		"  loop " +
          		"    exit when length(l_buffer)+255 > :maxbytes OR l_done = 1; " +
          		"    dbms_output.get_line( l_line, l_done ); " +
          		"    l_buffer := l_buffer || l_line || chr(10); " +
          		"  end loop; " +
          		" :done := l_done; " +
          		" :buffer := l_buffer; " +
          		"end;" );
	}

	public void enable( int size ) throws SQLException
	{
    		enable_stmt.setInt( 1, size );
    		enable_stmt.executeUpdate();
	}

	public void disable() throws SQLException{
	    	disable_stmt.executeUpdate();
	}

	public void show() throws SQLException {
		int done = 0;

    		show_stmt.registerOutParameter( 2, java.sql.Types.INTEGER );
    		show_stmt.registerOutParameter( 3, java.sql.Types.VARCHAR );

    		for(;;) {    
			show_stmt.setInt( 1, 32000 );
        		show_stmt.executeUpdate();
        		System.out.print( show_stmt.getString(3) );
        		if ( (done = show_stmt.getInt(2)) == 1 ) break;
		}
	}

	public void close() throws SQLException {
			enable_stmt.close();
			disable_stmt.close();
			show_stmt.close();
	}
}

public class project2 {
	
	public static void main (String args []) throws SQLException {
		try {
			OracleDataSource ds = new oracle.jdbc.pool.OracleDataSource();
			ds.setURL("jdbc:oracle:thin:@grouchoIII.cc.binghamton.edu:1521:ACAD111");
			Connection conn = ds.getConnection("zhe2", "Pragmatic1");

			/* Menu Display */
			System.out.println("\n\n\n----- Menu ----- \n" + "1: Display all employees\n" + "2: Display all customers\n" + "3: Display all accounts\n" + "4: Display all transactions\n" + "5: Add a customer\n" + "6: Customer and accounts\n" + "7: Account info and transactions\n" + "8: Add account\n" + "9: Add transaction\n" + "0: Exit\n\n\n");
			BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

			Scanner s = new Scanner(System.in);
			int input;
			System.out.print("Enter input (0 to exit): ");
			input = s.nextInt();

			/* To call each procedure based on input */
			while (input != 0) {

				if (input == 1) {
				  	DbmsOutput dbmsOutput = new DbmsOutput(conn);
					dbmsOutput.enable(1000000);
					
					CallableStatement cs = conn.prepareCall("{ call banking.display_all_emp() }");	
					cs.execute();	
					cs.close();
					
					dbmsOutput.show();	
					dbmsOutput.close();
				}
				else if (input == 2) {
				  	DbmsOutput dbmsOutput = new DbmsOutput(conn);
					dbmsOutput.enable(1000000);
					
					CallableStatement cs = conn.prepareCall("{ call banking.display_all_cust() }");	
					cs.execute();	
					cs.close();
					
					dbmsOutput.show();	
					dbmsOutput.close();
				}
				else if (input == 3) {
				  	DbmsOutput dbmsOutput = new DbmsOutput(conn);
					dbmsOutput.enable(1000000);
					
					CallableStatement cs = conn.prepareCall("{ call banking.display_all_acc() }");	
					cs.execute();	
					cs.close();
					
					dbmsOutput.show();	
					dbmsOutput.close();
				}
				else if (input == 4) {
				  	DbmsOutput dbmsOutput = new DbmsOutput(conn);
					dbmsOutput.enable(1000000);
					
					CallableStatement cs = conn.prepareCall("{ call banking.display_all_trans() }");	
					cs.execute();	
					cs.close();
					
					dbmsOutput.show();	
					dbmsOutput.close();
				}
				else if (input == 5) {
				  	String cid;
					String cname;
					String city;
					System.out.print("\nEnter id: ");
					cid = reader.readLine();
					System.out.print("\nEnter name: ");
					cname = reader.readLine();
					System.out.print("\nEnter city: ");
					city = reader.readLine();
					System.out.println(cid + " " + cname + " " + city);
				  	//DbmsOutput dbmsOutput = new DbmsOutput(conn);
					//dbmsOutput.enable(1000000);
					
					CallableStatement cs = conn.prepareCall("{ call banking.add_customer(?, ?, ?) }");
					cs.setString(1, cid);
					cs.setString(2, cname);	
					cs.setString(3, city);
					cs.execute();
					
					cs.close();
					
					//dbmsOutput.show();	
					//dbmsOutput.close();
				}
				else if (input == 6) {
				  	String cid;
					System.out.print("\nEnter customer id: ");
					cid = reader.readLine();
				  	DbmsOutput dbmsOutput = new DbmsOutput(conn);
					dbmsOutput.enable(1000000);
					
					CallableStatement cs = conn.prepareCall("{ call banking.c_info(?) }");
					cs.setString(1, cid);
					cs.execute();
					
					cs.close();
					
					dbmsOutput.show();	
					dbmsOutput.close();
				}
				else if (input == 7) {
				  	String aid;
					System.out.print("\nEnter account id: ");
					aid = reader.readLine();
				  	DbmsOutput dbmsOutput = new DbmsOutput(conn);
					dbmsOutput.enable(1000000);
					
					CallableStatement cs = conn.prepareCall("{ call banking.a_info(?) }");
					cs.setString(1, aid);
					cs.execute();
					
					cs.close();
					
					dbmsOutput.show();	
					dbmsOutput.close();
				}
				else if (input == 8) {
				  	String tid, eid, cid, aid, type, s_amount, s_rate;
					double amount;
					double rate;
					System.out.print("\nEnter transaction id: ");
					tid = reader.readLine();
					System.out.print("\nEnter employee id: ");
					eid = reader.readLine();
					System.out.print("\nEnter customer id: ");
					cid = reader.readLine();
					System.out.print("\nEnter account id: ");
					aid = reader.readLine();
					System.out.print("\nEnter account type: ");
					type = reader.readLine();
					System.out.print("\nEnter amount: ");
					s_amount = reader.readLine();
					amount = Double.parseDouble(s_amount);
					System.out.print("\nEnter rate: ");
					s_rate = reader.readLine();
					rate = Double.parseDouble(s_rate);

				  	DbmsOutput dbmsOutput = new DbmsOutput(conn);
					dbmsOutput.enable(1000000);
					
					CallableStatement cs = conn.prepareCall("{ call banking.add_acc(?, ?, ?, ?, ?, ?, ?) }");
					cs.setString(1, tid);
					cs.setString(2, eid);
					cs.setString(3, cid);
					cs.setString(4, aid);
					cs.setDouble(5, amount);
					cs.setString(6, type);
					cs.setDouble(7, rate);
					cs.execute();	
					cs.close();
					
					dbmsOutput.show();	
					dbmsOutput.close();
				}
				else if (input == 9) {
				  	String tid, eid, cid, aid, type, s_amount;
					double amount;
					System.out.print("\nEnter transaction id: ");
					tid = reader.readLine();
					System.out.print("\nEnter employee id: ");
					eid = reader.readLine();
					System.out.print("\nEnter customer id: ");
					cid = reader.readLine();
					System.out.print("\nEnter account id: ");
					aid = reader.readLine();
					System.out.print("\nEnter account type: ");
					type = reader.readLine();
					System.out.print("\nEnter amount: ");
					s_amount = reader.readLine();
					amount = Double.parseDouble(s_amount);
	
				  	DbmsOutput dbmsOutput = new DbmsOutput(conn);
					dbmsOutput.enable(1000000);
					
					CallableStatement cs = conn.prepareCall("{ call banking.add_trans(?, ?, ?, ?, ?, ?) }");
					cs.setString(1, tid);
					cs.setString(2, eid);
					cs.setString(3, cid);
					cs.setString(4, aid);
					cs.setDouble(5, amount);
					cs.setString(6, type);
					cs.execute();	
					cs.close();
					
					dbmsOutput.show();	
					dbmsOutput.close();
				}
				else {

				}
				System.out.println("\n\n\n----- Menu ----- \n" + "1: Display all employees\n" + "2: Display all customers\n" + "3: Display all accounts\n" + "4: Display all transactions\n" + "5: Add a customer\n" + "6: Customer and accounts\n" + "7: Account info and transactions\n" + "8: Add account\n" + "9: Add transaction\n" + "0: Exit\n\n\n");

				System.out.print("Enter input (0 to exit): ");
				input = s.nextInt();
			}
			conn.close();
		}
	
		catch (SQLException ex) {
			System.out.println("\n*** SQLException caught ***\n");
		}
		catch (Exception e) {
		  	System.out.println("\n*** other Exception caught ***\n");
		}
	}
}
