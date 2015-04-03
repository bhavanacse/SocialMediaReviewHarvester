<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="org.mindrot.*;"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login Validation</title>
</head>
<body>
	<%
		// Get the username and password
		String username = request.getParameter("username");
		String password = request.getParameter("password");

		// Retrieve the JDBC Connection string from the configuration
		String driver = "org.postgresql.Driver";
		String jdbcUrl = //"jdbc:postgresql://" + "localhost" + ":" + "5432" + "/" + "dbcollection"; 
							//"jdbc:postgresql://" + hostname + ":" + port + "/" + dbName;		
		System.getProperty("JDBC_CONNECTION_STRING");

		Connection myConnection = null;
		//Statement myStatement = null;
		PreparedStatement myStatement = null;
		ResultSet myResultSet = null;

		try {
			Class.forName(driver);
		} catch (ClassNotFoundException e) {
			out.println("<h1>Driver not found:" + e + e.getMessage()
					+ "</h1>");
			out.println("<h1> Please contact the administrator to fix this problem. </h1>");
		}

		try {
			// Create the connection using JDBC Url
			myConnection = //DriverManager.getConnection(jdbcUrl, username, password);
			DriverManager.getConnection(jdbcUrl);
			//myStatement = myConnection.createStatement();

			//String myQuery = "SELECT username, encrypted_password FROM logins WHERE username=" + "'" + username + "'" + ";";

			String myQuery = "SELECT username, encrypted_password FROM logins WHERE username = ? ";

			myStatement = myConnection.prepareStatement(myQuery);
			myStatement.setString(1, username);

			//myResultSet = myStatement.executeQuery(myQuery);
			myResultSet = myStatement.executeQuery();

			// Validate the credentials provided by the user
			if (myResultSet.next()
					&& BCrypt.checkpw(password,
							myResultSet.getString("encrypted_password"))) {
				session.setAttribute("username", username);
				session.setAttribute("password", password);

				// Navigate to the next page where reviews can be shown
				response.sendRedirect("ClientSide.jsp");
			} else
				// Show the error page if credentials are not correct
				response.sendRedirect("Error.jsp");

			// Close the connection
			myConnection.close();

		} catch (SQLException ex) {
			out.println("SQLException: " + ex.getMessage());
			out.println("SQLState: " + ex.getSQLState());
			out.println("VendorError: " + ex.getErrorCode());
			out.println("<h1> Please contact the database administrator for any SQL errors. </h1>");
		}
	%>
</body>
</html>
