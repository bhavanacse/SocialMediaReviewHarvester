<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>LogOut Page</title>
<!-- Latest CSS -->
<link rel="stylesheet" href="styles/bootstrap.css">
<link rel="stylesheet" href="styles/webstyle.css">
</head>
<body>
	<%
        // Show the home page if session is not valid	   
   	    Object username = session.getAttribute("username");
	 	if (username == null){
	 		response.sendRedirect("index.jsp");
	 		return;
	 	}
   	
	 	// Remove attributes and invalidate session on log out
        session.removeAttribute("username");
        session.removeAttribute("password");
        session.invalidate();
     %>

	<div class="navbar navbar-inverse">
		<div class="container">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle" data-toggle="collapse"
					data-target=".navbar-collapse">
					<span class="icon-bar"></span> <span class="icon-bar"></span> <span
						class="icon-bar"></span>
				</button>
				<a href="#" class="navbar-brand"><strong>Social Media
						Reviews Harvester</strong></a>
			</div>

			<div class="navbar-collapse collapse">
				<ul class="nav navbar-nav">
					<li><a href="index.jsp"><strong>Home</strong></a></li>
					<li><a href="html/About.html"><strong>About</strong></a></li>
					<li><a href="html/ContactUs.html"><strong>Contact
								Us</strong></a></li>
					<li><a href="http://54.193.76.174/"><strong>Data Collection</strong></a></li>
				</ul>
			</div>
		</div>
	</div>

	<div class="jumbotron">
		<div class="row">
			<center>
				<h3>
					<strong class="text-primary">You have logged out
						successfully. Please click <a class="btn btn-primary btn-lg"
						href="/index.jsp">Home</a> to login again.
					</strong>
				</h3>
			</center>
		</div>
	</div>

	<div class="container">
		<div class="row">
			<hr />
			<div class="col-md-12">
				<p class="text-muted">SFSU Project - Fall 2014</p>
			</div>
		</div>
	</div>

</body>
</html>