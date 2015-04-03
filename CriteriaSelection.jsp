<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.Writer"%>
<%@ page import="java.io.OutputStreamWriter"%>
<%@ page import="com.google.gson.*"%>
<%@ page import="com.google.gson.stream.JsonWriter"%>

<%
    //Go to home page if the session is not valid
    Object user = session.getAttribute("username");
 	if (user == null){
 		response.sendRedirect("index.jsp");
 		return;
 	}
 	
 	//Retrieve username and password from the same session with user has logged in
 	String username = user.toString();
 	String password = session.getAttribute("password").toString();
 	
 	//Get the JDBC connection string from the configuration that is set
 	String driver = "org.postgresql.Driver";
    String jdbcUrl = //"jdbc:postgresql://" + "localhost" + ":" + "5432" + "/" + "dbcollection"; 
                     //"jdbc:postgresql://" + hostname + ":" + port + "/" + dbName;     
    		         System.getProperty("JDBC_CONNECTION_STRING");
    String myQuery;
       
    Connection myConnection = null;
	Statement myStatement = null;
	ResultSet myResultSet = null, rs = null;
	
	try {
 	    Class.forName(driver);
       } catch (ClassNotFoundException e) {
           out.println("<h1>Driver not found:" + e + e.getMessage() + "</h1>" );
           out.println("<h1> Please contact the administrator to fix this problem. </h1>" );
       } 
	
	try {
		// Get the connection from the PostgreSQL driver manager using the JDBC connection string
		myConnection = //DriverManager.getConnection(jdbcUrl, username, password);
	                   DriverManager.getConnection(jdbcUrl);
	           	                   
		// Create a statement
        myStatement = myConnection.createStatement();
		
		myQuery = "SELECT DISTINCT ssname FROM socialmediasites;";
		// Execution of query
		myResultSet = myStatement.executeQuery(myQuery);
		
		ResultSetMetaData rsmd = myResultSet.getMetaData();
	    int count = rsmd.getColumnCount();
	    
	    //Set the response in json format
	    response.setContentType("application/json; charset=UTF-8");
	    response.setCharacterEncoding("UTF-8");
	    
		// JsonWriter to write the results of the query in json format
	    JsonWriter writer = new JsonWriter(new OutputStreamWriter(response.getOutputStream(), "UTF-8"));
	    writer.setLenient(true);
	    
	    // To begin an object i.e. '{'
	    writer.beginObject(); 
	    // Key as "socialmediasites"
	    writer.name("socialmediasites");
	    // Value as array of objects
	    writer.beginArray();
     
	    while(myResultSet.next()) {
	       writer.beginObject(); // Begin object
	       // loop rs.getResultSetMetadata columns
	       for(int idx=1; idx<=count; idx++) {
	    	 writer.name(rsmd.getColumnLabel(idx)); // write key:value pairs, ssname: ssname value pairs
	         writer.value(myResultSet.getString(idx));
	       }
	       writer.endObject();  // End object
	    }

    writer.endArray();  //End array
    
    // Another statement creation
    myStatement = myConnection.createStatement();
    myQuery = "SELECT bname, bshortname FROM businesses;";
    rs = myStatement.executeQuery(myQuery);
    
    ResultSetMetaData rsmd1 = rs.getMetaData();
    int totalnum = rsmd1.getColumnCount();
    
    /* Write the businesses list in json format with key as "businesses" and value as array of objects with key value
     * pairs of bname and bname value from businesses entity
     */ 
    writer.name("businesses");
    writer.beginArray();
    
    while(rs.next()) {
       writer.beginObject();
       // loop rs.getResultSetMetadata columns
       for(int ptr=1; ptr<=totalnum; ptr++) {
    	 writer.name(rsmd1.getColumnLabel(ptr)); // write key:value pairs
         writer.value(rs.getString(ptr));
       }
       writer.endObject();
    }

    writer.endArray();
    writer.endObject();
    
    writer.close();
    response.getOutputStream().flush();
    myConnection.close(); //Close the connection
	
	} catch (SQLException ex) {
		out.println("SQLException: " + ex.getMessage());
		out.println("SQLState: " + ex.getSQLState());
		out.println("VendorError: " + ex.getErrorCode());
		out.println("<h1> Please contact the database administrator for any SQL errors. </h1>");
	}
 %>

