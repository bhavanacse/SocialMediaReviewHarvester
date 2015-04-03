<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.logging.Logger"%>
<%@ page import="java.lang.Object"%>
<%@ page import="java.io.Writer"%>
<%@ page import="java.io.OutputStreamWriter"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="com.google.gson.*"%>
<%@ page import="com.google.gson.stream.JsonWriter"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>User Reviews Page</title>
</head>
<body>

	<%
		// Logger to log any errors while executing the code
		Logger logger = Logger.getLogger(this.getClass().getName());

		// Show the home page if the session is not valid
		Object user = session.getAttribute("username");
		if (user == null) {
			response.sendRedirect("index.jsp");
			return;
		}

		/*  Retrieve the username, password, selected sites, selected businesses, selected timeline
		 */
		String username = user.toString();
		String password = session.getAttribute("password").toString();
		String socialSites[] = request.getParameterValues("socialsitename");
		String selectedBusiness[] = request.getParameterValues("businame");
		String selectedTenure = request.getParameter("tenure");
		String beginDate = "";
		String finalDate = "";

		// Define the database driver
		String driver = "org.postgresql.Driver";
		// Get the JDBC connection string 
		String jdbcUrl = //"jdbc:postgresql://" + "localhost" + ":" + "5432" + "/" + "dbcollection"; 
							//"jdbc:postgresql://" + hostname + ":" + port + "/" + dbName;     
		System.getProperty("JDBC_CONNECTION_STRING");
		String myQuery;
		String concatenatedQuery;

		Connection myConnection = null;
		//Statement myStatement = null;

		// Prepared Statement used to handle SQL injection
		PreparedStatement myStatement = null;
		ResultSet resultSet = null;

		try {
			Class.forName(driver);
		} catch (ClassNotFoundException e) {
			out.println("<h1>Driver not found:" + e + e.getMessage()
					+ "</h1>");
			out.println("<h1> Please contact the administrator to fix this problem. </h1>");
		}

		try {
			// Get the connection from the database driver using JDBC connection string
			myConnection = //DriverManager.getConnection(jdbcUrl, username, password);
			DriverManager.getConnection(jdbcUrl);

			//myQuery = "UPDATE logins SET selectedsites = null WHERE username='"
			//        + username + "';";

			// Query to update null value in "selectedsites" field of "logins" entity 
			myQuery = "UPDATE logins SET selectedsites = null WHERE username = ?";

			//myStatement = myConnection.createStatement();
			myStatement = myConnection.prepareStatement(myQuery);

			myStatement.setString(1, username);

			//myStatement.executeUpdate(myQuery);

			// Execute updation
			myStatement.executeUpdate();

		} catch (SQLException ex) {
			out.println("SQLException: " + ex.getMessage());
			out.println("SQLState: " + ex.getSQLState());
			out.println("VendorError: " + ex.getErrorCode());
			out.println("<h1> Please contact the database administrator for any SQL errors. </h1>");
		}

		/* Query to update the sites selected by user
		 */
		if (socialSites != null) {
			int site = 0;
			while (site < socialSites.length) {
				int index = site + 1;
				//myQuery = "UPDATE logins SET selectedsites[" + index + "]='"
				//        + socialSites[site] + "' WHERE username='"
				//        + username + "'" + ";";

				myQuery = "UPDATE logins SET selectedsites[" + index
						+ "]='" + socialSites[site]
						+ "' WHERE username = ?";

				//myStatement = myConnection.createStatement();
				myStatement = myConnection.prepareStatement(myQuery);

				myStatement.setString(1, username);

				//myStatement.executeUpdate(myQuery);
				myStatement.executeUpdate();
				site++;
			}
		}
	%>
	<form>
		<%
			ResultSet rs = null;

			// Required date format
			DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd");

			// Get current date time with Date()
			Date date = new Date();
			String currentDate = dateFormat.format(date);// Format the current date using the date format
			// Get From and To date values
			String startDt = request.getParameter("startDate");
			String endDt = request.getParameter("endDate");

			boolean startDateProvided = !(startDt == null || startDt.isEmpty());
			boolean endDateProvided = !(endDt == null || endDt.isEmpty());

			// Consider From and To fields as current dates if From and To fields are not changed by user
			if (selectedTenure.equals("Date Range")) {
				logger.info("Date Range");
				beginDate = (!startDateProvided ? "CURRENT_DATE"
				//: "'" + startDt + "'");
						: "?::date");
				finalDate = (!endDateProvided ? "CURRENT_DATE"
				//: "'" + endDt + "'");
						: "?::date");
				// Calculate From and To field date values for "Last Week"
			} else if (selectedTenure.equals("Last Week")) {
				logger.info("Last Week");
				beginDate = "CURRENT_DATE - integer '7'";
				finalDate = "CURRENT_DATE - integer '1'";
				// Calculate From and To field date values for "Last Month"
			} else if (selectedTenure.equals("Last Month")) {
				beginDate = "CURRENT_DATE - integer '30'";
				finalDate = "CURRENT_DATE - integer '1'";
				// Calculate From and To field date values for "Last 6 Months"
			} else if (selectedTenure.equals("Last 6 Months")) {
				beginDate = "CURRENT_DATE - integer '183'";
				finalDate = "CURRENT_DATE - integer '1'";
				// Calculate From and To field date values for "Last Year"
			} else if (selectedTenure.equals("Last Year")) {
				beginDate = "CURRENT_DATE - integer '365'";
				finalDate = "CURRENT_DATE - integer '1'";
			}

			int count, cnum = 0;
			// Use Jsonwriter to build the response in json format
			JsonWriter writer = new JsonWriter(new OutputStreamWriter(
					response.getOutputStream(), "UTF-8"));
			writer.setLenient(true);
			writer.beginObject(); // Begin object i.e. "{"

			// Iterate on social-media sites
			while (cnum < socialSites.length) {

				writer.name(socialSites[cnum]); // Take the key as socialsite name 
				writer.beginObject(); // Begin object i.e. "{"

				//myStatement = myConnection.createStatement();

				for (int index = 0; index < selectedBusiness.length; index++) {

					/*
					concatenatedQuery = String
							.format("SELECT ssdcommentorname, ssdpostat, ssdcommentorrating,"
									+ " ssdcomment, ssddownloaddatetimestamp, ssdconvertedpostat, postingurl as postingURL"
									+ " FROM sscommentordata"
									+ " WHERE ssid IN (SELECT ssid FROM socialmediasites WHERE ssname = '%s') AND"
									+ " bid IN (SELECT bid FROM businesses WHERE bname = '%s')"
									+ " AND %s <= ssdconvertedpostat::date"
									+ " ANDs ssdconvertedpostat::date <= %s",
									socialSites[cnum], selectedBusiness[index].split(" - ")[1],
									beginDate, finalDate);
					 */

					// Query to retrieve user reviews basing on user's selection of sites, businesses and timeline. Prepared
					// statement parameters are applicable only when From, To date fields are changed
					concatenatedQuery = "SELECT ssdcommentorname, ssdpostat, ssdcommentorrating,"
							+ " ssdcomment, ssddownloaddatetimestamp, ssdconvertedpostat, postingurl as postingURL"
							+ " FROM sscommentordata"
							+ " WHERE ssid IN (SELECT ssid FROM socialmediasites WHERE ssname = ?) AND"
							+ " bid IN (SELECT bid FROM businesses WHERE bname = ?)"
							+ " AND "
							+ beginDate
							+ " <= ssdconvertedpostat::date"
							+ " AND ssdconvertedpostat::date <= "
							+ finalDate
							+ " ORDER BY ssdconvertedpostat::date DESC;";

					logger.info(concatenatedQuery);

					myStatement = myConnection
							.prepareStatement(concatenatedQuery);

					/*
					Date bD = dateFormat.parse(beginDate);
					java.sql.Date bDate = new java.sql.Date(bD.getTime());
					
					Date fD = dateFormat.parse(finalDate);
					java.sql.Date fDate = new java.sql.Date(fD.getTime());
					 */

					myStatement.setString(1, socialSites[cnum]);
					myStatement.setString(2,
							selectedBusiness[index].split(" - ")[1]); //Split the selected business name and take the right side part  
					//myStatement.setDate(3, bDate);
					//myStatement.setDate(4, fDate);

					// If both From and To fields are changed
					if (startDateProvided && endDateProvided
							&& selectedTenure.equals("Date Range")) {
						myStatement.setString(3, startDt);
						myStatement.setString(4, endDt);
						// If only From date is changed by the user
					} else if (startDateProvided && !endDateProvided
							&& selectedTenure.equals("Date Range")) {
						myStatement.setString(3, startDt);
						// If only To date is changed by the user
					} else if (!startDateProvided && endDateProvided
							&& selectedTenure.equals("Date Range")) {
						myStatement.setString(3, endDt);
					}

					// Query execution
					rs = myStatement.executeQuery();
					//myStatement.executeQuery(concatenatedQuery);

					// Get the metadata from the resultset
					ResultSetMetaData rsmd = rs.getMetaData();
					count = rsmd.getColumnCount();

					// Set the response in json format
					response.setContentType("application/json; charset=UTF-8");
					response.setCharacterEncoding("UTF-8");

					writer.name(selectedBusiness[index].split(" - ")[0]); // Take key as business name
					writer.beginArray(); // Build an array with objects 

					// Build objects with key value pairs as required columns from query and their values
					while (rs.next()) {
						writer.beginObject();
						// loop rs.getResultSetMetadata columns
						for (int idx = 1; idx <= count; idx++) {
							writer.name(rsmd.getColumnLabel(idx)); // write key:value pairs
							writer.value(rs.getString(idx));
						}
						writer.endObject();
					}
					writer.endArray(); // End the array of objects
				}

				writer.endObject(); // End the object
				cnum++;
			}

			writer.endObject(); // End the whole json
			writer.close(); // Close the writer
			response.getOutputStream().flush();
		%>
		<br /> <br />
	</form>
	<%
		myConnection.close(); // Close the connection
	%>
</body>
</html>