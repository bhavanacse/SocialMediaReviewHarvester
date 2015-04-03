<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Error Page</title>

<!-- Latest CSS -->
<link rel="stylesheet" href="styles/bootstrap.css">
<link rel="stylesheet" href="styles/webstyle.css">
</head>

<body>
	<div class="navbar navbar-inverse" style="width: 100%; height: 5%;">
		<div class="container" style="width: 100%; height: 3%;">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle" data-toggle="collapse"
					data-target=".navbar-collapse">
					<span class="icon-bar"></span> <span class="icon-bar"></span> <span
						class="icon-bar"></span>
				</button>
				<a href="#" class="navbar-brand"><strong>Social Media
						Reviews Harvester</strong></a>
			</div>

			<div class="navbar-collapse collapse"
				style="width: 100%; height: 3%;">
				<ul class="nav navbar-nav">
					<li><a href="index.jsp"><strong>Home</strong></a></li>
					<li><a href="html/About.html"><strong>About</strong></a></li>
					<li><a href="html/ContactUs.html"><strong>Contact
								Us</strong></a></li>
					<li><a href="http://54.193.76.174/"><strong>Data Collection</strong></a></li>
				</ul>
				<form action="LoginValidate.jsp" method="post"
					class="navbar-form navbar-left">
					<div class="form-group">
						<label class="sr-only">Username</label> <input type="text"
							name="username" class="form-control" placeholder="Username">
					</div>
					<div class="form-group">
						<label class="sr-only">Password</label> <input type="password"
							name="password" class="form-control" placeholder="Password">
					</div>
					<input type="submit" class="btn btn-info" value="Sign In">
				</form>
			</div>
		</div>
	</div>
	<!-- Show that the credentials are invalid -->
	<center>
		<p class="text-danger">
			<strong>Your Username/Password are incorrect. Please enter
				valid credentials.</strong>
		</p>
	</center>
	<div class="container" style="width: 100%; height: 90%;">
		<div class="row">
			<div class="col-md-12">

				<div id="smcarousel" class="carousel slide">
					<!-- Indicators -->
					<ol class="carousel-indicators">
						<li data-target="#smcarousel" data-slide-to="0" class="active"></li>
						<li data-target="#smcarousel" data-slide-to="1"></li>
						<li data-target="#smcarousel" data-slide-to="2"></li>
					</ol>

					<!-- Wrapper for slides -->
					<div class="carousel-inner">

						<div class="item active">
							<img src="images/UserReviews1.jpg"
								class="img-responsive center-block"></img>
							<div class="container">
								<div class="carousel-caption">
									<h3 class="text-primary">
										<strong>Collection of user reviews from Social-Media
											sites</strong>
									</h3>
								</div>
							</div>
						</div>

						<div class="item">
							<img src="images/UserReviews2.jpg"
								class="img-responsive center-block"></img>
							<div class="container">
								<div class="carousel-caption">
									<h3 class="text-danger">
										<strong>Different views of users</strong>
									</h3>
								</div>
							</div>
						</div>

						<div class="item">
							<img src="images/UserReviews3.jpg"
								class="img-responsive center-block"></img>
							<div class="container">
								<div class="carousel-caption">
									<h3>
										<strong>Reviews of users from different places</strong>
									</h3>
								</div>
							</div>
						</div>
					</div>


					<!-- Controls -->
					<a class="left carousel-control" href="#smcarousel"
						data-slide="prev"> <span
						class="glyphicon glyphicon-chevron-left"></span>
					</a> <a class="right carousel-control" href="#smcarousel"
						data-slide="next"> <span
						class="glyphicon glyphicon-chevron-right"></span>
					</a>
				</div>

			</div>
		</div>

		<div class="row">
			<div class="col-md-4 col-xs-4 col-sm-4">
				<center>
					<h3 class="bg-primary">
						<strong>Collaboration of reviews</strong>
					</h3>
				</center>
				<p>User reviews collected from different Social-Media sites(Ex:
					Twitter, Yelp, GooglePlaces) are shown collectively in this web
					site. Each review is differentiated with site name and business.</p>
			</div>

			<div class="col-md-4 col-xs-4 col-sm-4">
				<center>
					<h3 class="bg-primary">
						<strong>Reviews based on criteria</strong>
					</h3>
				</center>
				<p>Reviews are regarding various businesses. Criteria contains
					social sites, businesses, date range for the user to select and
					then user can view reviews.</p>
			</div>

			<div class="col-md-4 col-xs-4 col-sm-4">
				<center>
					<h3 class="bg-primary">
						<strong>Summary of user reviews</strong>
					</h3>
				</center>
				<p>User name, posted date, rating, comment are included as part
					of a review. Summary of reviews is shown in term of graphs for
					businesses and sites to make a comparison.</p>
			</div>
		</div>

	</div>
	<div class="container" style="width: 90%; height: 5%;">
		<div class="row">
			<hr />
			<div class="col-md-12">
				<p class="text-muted">SFSU Project - Fall 2014</p>
			</div>
		</div>
	</div>

	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
	<script
		src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
	<!-- Include all compiled plugins (below), or include individual files as needed -->
	<script src="scripts/bootstrap.min.js"></script>

	<script>
    // Time for each image to remain and then slide in carousel
       $(document).ready(function() {
           $('.carousel').carousel({
                interval: 4000
           });
       });
    </script>
</body>

</html>