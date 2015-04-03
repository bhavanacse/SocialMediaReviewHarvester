<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
	// Show the home page if a user tries to access this page directly
	Object user = session.getAttribute("username");
	if (user == null) {
		response.sendRedirect("index.jsp");
		return;
	}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Criteria Selection</title>

<script src="scripts/FetchSiteBusiness.js" /></script>
<script src="scripts/FetchReviews.js" /></script>

<!-- jQuery (necessary for Bootstrap's JavaScript plug-ins) -->
<!--  This should be included before we call any of jQuery functionality, so don't move from here -->
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
<!-- JavaScript plug-in for multiple options select drop-down -->
<script src="scripts/bootstrap-multiselect.js"></script>

<script>

$(document).ready(function(){

    // To hide the loader image after the page is loaded
    $("#loaderImage").hide();
    
    // To show the messages in tabs on load of the page
    $("#firstTabMessage").show();
    $("#secondTabMessage").show();
    $("#thirdTabMessage").show();
    $("#fourthTabMessage").show();
    
    // To hide the containers containing graphs in 3rd tab
    $("#businessContainer").hide();
    $("#websiteContainer").hide();
    $("#yearContainer").hide();
    $("#monthContainer").hide();

    // To hide the containers containing graphs in 4th tab
    $("#businessAvgRatingContainer").hide();
    $("#websiteAvgRatingContainer").hide();
    $("#yearAvgRatingContainer").hide();
    $("#monthAvgRatingContainer").hide();

    // Hide the warnings in 1st and 2nd tabs
    $("#firstChartWarning").hide();
    $("#secondChartWarning").hide();
    
    // To hide notes on all tabs
    $("#firstTabNote").hide();
    $("#secondTabNote").hide();
    $("#thirdTabNote").hide();
    $("#fourthTabNote").hide();

    // Empty the values of hidden date fields on load of the page
    document.getElementById('startDateHidden').value = "";
    document.getElementById('endDateHidden').value = "";
    
	// Shows the Business view of total number of reviews across websites in 3rd tab on click of "Back to Business View" button
	$("#backToBusinessView").click(function () {
        renderTrendsChart(sitesArray, businessChartName(), websiteTotalsArray, yearlyTrendsFunction, '#businessContainer', 
        'Reviews of ', 
        'Yearly, Monthly, or Daily total reviews of business across sites with Drilldown',
        'Number of User Reviews', hidereviewCharts, 'reviews', false);
	});
	
	// Shows the Website view of total number of reviews across years in 3rd tab on click of "Back to Website View" button 
	$("#backToWebsiteView").click(function () {
	    renderTrendsChart(yearsArray, websiteChartName(), yearlyTotalsArray, monthlyTrendsFunction, '#websiteContainer',
	    'Reviews of ', 
        'Yearly, Monthly, or Daily total reviews of business across sites with Drilldown',
        'Number of User Reviews', hidereviewCharts, 'reviews', false);
	});
	
	// Shows the Yearly view of total number of reviews across months in 3rd tab on click of "Back to Yearly View" button
	$("#backToYearlyView").click(function () {
	    renderTrendsChart(monthsArray, yearlyChartName(), monthlyTotalsArray, dailyTrendsFunction, '#yearContainer',
	    'Reviews of ', 
        'Yearly, Monthly, or Daily total reviews of business across sites with Drilldown',
        'Number of User Reviews', hidereviewCharts, 'reviews', false);
	});
	
	// Shows the Business view of average ratings across websites in 4th tab on click of "Back to Business View" button
	$("#backToBusinessAvgRatingView").click(function () {
        renderTrendsChart(sitesArray, businessAvgRatingChartName(), websiteAvgRatingArray, yearlyAvgRatingTrendsFunction, '#businessAvgRatingContainer',
        'Average Ratings of ', 
        'Yearly, Monthly, or Daily average ratings of business across sites with Drilldown',
        'Average Rating', hideAvgRatingCharts, 'avg rating', false);
    });
    
    // Shows the Website view of average ratings across years in 4th tab on click of "Back to Website View" button
    $("#backToWebsiteAvgRatingView").click(function () {
        renderTrendsChart(yrsArray, websiteAvgRatingChartName(), yrlyAvgRatingArray, monthlyAvgRatingTrendsFunction, '#websiteAvgRatingContainer',
        'Average Ratings of ', 
        'Yearly, Monthly, or Daily average ratings of business across sites with Drilldown',
        'Average Rating', hideAvgRatingCharts, 'avg rating', false);
    });
    
    // Shows the Yearly view of average ratings across months in 4th tab on click of "Back to Yearly View" button
    $("#backToYearlyAvgRatingView").click(function () {
        renderTrendsChart(mnsArray, yearlyAvgRatingChartName(), mnlyAvgRatingArray, dailyAvgRatingTrendsFunction, '#yearAvgRatingContainer',
        'Average Ratings of ', 
        'Yearly, Monthly, or Daily average ratings of business across sites with Drilldown',
        'Average Rating', hideAvgRatingCharts, 'avg rating', false);
    });
    
    if(document.getElementById('dateRange').checked){
         // Show "From" and "To" fields only when "Date Range" is selected 
         document.getElementById('dates').style.display = "block";
    } else {
         // Hide "From" and "To" fields when "Date Range" is not selected
         document.getElementById('dates').style.display = "none";
    } 
	
	// Web service call to show sites and businesses using multi select dropdowns
	var URL = "CriteriaSelection.jsp";
	$.ajax({
		url: URL,
		dataType: "json",
		success: functionToCallWhenSucceed,
		error: functionToCallWhenFailed
	});
	
	// Attach a submit handler to the form
	$("#selectMediaForm").submit(function( event ) {
	       
	        // Alert to show if none of the sites are selected
	        if ($('#sitename option:selected').length == 0) { 
	           alert('Please select atleast one social-media site.');
	           document.SMForm.socialsitename.focus();
	           return false; 
           }
	        
	        // Alert to show if none of the businesses are selected
	        if ($('#businessname option:selected').length == 0) { 
	           alert('Please select atleast one business name.');
	           document.SMForm.businame.focus();
	           return false; 
            }

            // Alert to show if none of the timeline options are selected
            var myRadios = document.SMForm.tenure;
            for (var currentIdx = 0; currentIdx < myRadios.length; currentIdx++){
                if(myRadios[currentIdx].checked){
                    break;
                }
                if(currentIdx == myRadios.length-1){
                    alert("No timeline is checked. Please select a timeline.");
                    return false;
                }
            }
            
            // Alert to show if start date is greater than the end date
            var sD = document.getElementById("startDateHidden").value;
	        var eD = document.getElementById("endDateHidden").value;
	        var tempDate, mnth;
	        tempDate = new Date();
	        mnth = tempDate.getMonth() + 1;
	        
	        if(sD == '' && eD == ''){
	            //Do Nothing
	        } else if(sD != '' && eD == ''){
	            //Do Nothing
	        } else if(sD == '' && eD != ''){
	            sD = mnth + '/' + tempDate.getDate() + '/' + tempDate.getFullYear();
	            if (Date.parse(sD) > Date.parse(eD)) {
	                alert("From Date should be less than To Date.");
	                
	                return false;
	            }
	        } else if(sD != '' && eD != ''){
	            if (Date.parse(sD) > Date.parse(eD)) {
	                alert("From Date should be less than To Date.");
	                return false;
	            }
	        }
            
            // Loading image to show up on form submit 
            $("#loaderImage").show();
            
            // To clear the search box under Results section
            //$("#dynatable-query-search-reviewsTable").empty();
            
            // Hide all the tab messages
            $("#firstTabMessage").hide();
            $("#secondTabMessage").hide();
            $("#thirdTabMessage").hide();
            $("#fourthTabMessage").hide();
            
            var formData = $("#selectMediaForm").serializeArray();

			// Web service call to retrieve the reviews basing on the criteria selected
			var URL = "ViewUserReviews.jsp";
			$.ajax({
					url: URL,
					type: "POST",
					data: formData,
					dataType: "json",
					success: functionWhenSucceeds,
					error: functionWhenFails
			});
			
			// Stop form from submitting normally
			event.preventDefault();
            
            // Show the 1st and 2nd chart warnings on click of "View Reviews" button
            $("#firstChartWarning").show();
            $("#secondChartWarning").show();
            
            // To show note sections on 1st & 2nd tabs
		    $("#firstTabNote").show();
		    $("#secondTabNote").show();
	});
   	
   	// $("#startDate").bfhdatepicker('toggle');
	// $("#endDate").bfhdatepicker('toggle');

	$('#startDateDiv').on('change.bfhdatepicker', function(e) {
      
      // Get the value of "From" field into a hidden textbox 
      $('#startDateHidden').val($(e.target).val());
      
      // Validate whether "From" date is greater than "To" date
      //dateValidation();
    });

    $('#endDateDiv').on('change.bfhdatepicker', function(e) {
      
      // Get the value of "To" field into a hidden textbox
      $('#endDateHidden').val($(e.target).val());
      
      // Validate whether "From" date is greater than "To" date
      //dateValidation();
    }); 
    
    // Function to validate whether start date is greater than the end date
    function dateValidation(){
        var sD = document.getElementById("startDateHidden").value;
        var eD = document.getElementById("endDateHidden").value;
        var tempDate, mnth;
        tempDate = new Date();
        mnth = tempDate.getMonth() + 1;
        
        if(sD == '' && eD == ''){
            //Do Nothing
        } else if(sD != '' && eD == ''){
            //Do Nothing
        } else if(sD == '' && eD != ''){
            sD = mnth + '/' + tempDate.getDate() + '/' + tempDate.getFullYear();
            if (Date.parse(sD) > Date.parse(eD)) {
                alert("Start Date should be less than End Date.");
                return false;
            }
        } else if(sD != '' && eD != ''){
            if (Date.parse(sD) > Date.parse(eD)) {
                alert("Start Date should be less than End Date.");
                return false;
            }
        }
    }
});

</script>

<!-- Latest compiled CSS -->
<link rel="stylesheet" href="styles/bootstrap.css">

<!-- StyleSheet for icons used like twitter, yelp etc -->
<link rel="stylesheet"
	href="http://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css">

<!-- StyleSheet for multi-select drop-down -->
<link rel="stylesheet" href="styles/bootstrap-multiselect.css">
<!--  <link rel="stylesheet" href="styles/simplePagination.css"> -->

<!-- Stylesheet used for pagination, sorting and number of pages to show -->
<link rel="stylesheet" href="styles/jquery.dynatable.css">

<!-- Bootstrap Form Helpers for calendar date fields -->
<link rel="stylesheet" href="styles/bootstrap-formhelpers.min.css"
	media="screen">

<!-- DO NOT move the position of this CSS. Calendar arrows, ascending & descending arrows are shown using "th a" style-->
<link rel="stylesheet" href="styles/webstyle.css">
</head>
<body>
	<!-- Loading image -->
	<div class="loaderBackGround" id="loaderImage">
		<i class="fa fa-spinner fa-spin fa-4x loaderSpinner"></i>
	</div>
	<%
		// Retrieve the value of session attribute username
		String username = session.getAttribute("username").toString();
		session.setAttribute("username", username);
	%>

	<!-- Nav bar -->
	<div class="navbar navbar-inverse" >
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

			<div class="navbar-collapse collapse" >
				<p class="navbar-text">
					Signed in as
					<%=username%></p>
				<p class="navbar-text navbar-right">
					<a href="LogOut.jsp" class="navbar-link">Sign Out</a>
				</p>
			</div>
		</div>
	</div>

	<!-- Secondary heading -->
	<h4>
		<strong class="text-primary col-md-offset-4">User Reviews </strong><small
			class="text-primary">(Select criteria to view reviews)</small>
	</h4>

	<hr />
	<div class="row">
	   <div class="col-md-3">
			<!-- Form that contains criteria for the user to select -->
			<form name="SMForm" id="selectMediaForm" class="form-horizontal">

				<!-- Site names to select using multi selection dropdown -->
				<div class="form-group">
					<div class="row">
						<div class="col-md-2 col-xs-offset-2">
							<label class="text-primary"> <strong>Site</strong></label>
						</div>

						<div id="sitelist" class="col-md-3 col-md-offset-1"></div>
					</div>
				</div>

				<!-- Business names to select using multi selection dropdown -->
				<div class="form-group">
					<div class="row">
						<div class="col-md-2 col-xs-offset-2">
							<label class="text-primary"> <strong>Business</strong></label>
						</div>
						<div id="businesslist" class="col-md-3 col-md-offset-1"></div>
					</div>
				</div>

				<!-- Timeline criteria to select -->
				<div class="form-group">
					<div class="radio col-md-11">
						<div class="row">
							<div class="col-md-2 col-xs-offset-1">
								<label class="text-primary"> <strong>Timeline</strong></label>
							</div>
							<label class="col-md-offset-3"> <input type="radio"
								name="tenure" value="Last Week" onchange="handleClick();">
								Last Week
							</label>
						</div>
						<label class="col-md-offset-6"> <input type="radio"
							name="tenure" value="Last Month" onchange="handleClick();">
							Last Month
						</label> <label class="col-md-offset-6"> <input type="radio"
							name="tenure" value="Last 6 Months" onchange="handleClick();">
							Last 6 Months
						</label><label class="col-md-offset-6"> <input type="radio"
							name="tenure" value="Last Year" onchange="handleClick();">
							Last Year
						</label> <br /> <label class="col-md-offset-6"> <input
							id="dateRange" type="radio" name="tenure" value="Date Range"
							onchange="handleClick();"> Date Range
						</label>
					</div>
				</div>

				<!--  Hidden values for the form, to store the values of From and To fields-->
				<input id="startDateHidden" type="text" name="startDate"
					style="display: none" /> <input id="endDateHidden" type="text"
					name="endDate" style="display: none" />

				<!-- From and To fields that uses bootstrap form-helpers for calendar control -->
				<div class="form-group" id="dates">
					<div class="row" id="dateToStart">
						<div class="col-md-2 col-xs-offset-2">
							<label class="text-primary"> <strong>From</strong></label>
						</div>
						<div class="col-xs-6">
							<div class="bfh-datepicker" data-max="today" id="startDateDiv">
								<input id="startDate" type="text" class="datepicker" />
							</div>
						</div>
					</div>
					<br />
					<div class="row" id="dateToEnd">
						<div class="col-md-2 col-xs-offset-2">
							<label class="text-primary"><strong>To </strong></label>
						</div>
						<div class="col-xs-6" id="endDateDiv">
							<div class="bfh-datepicker" data-max="today" id="endDateDiv">
								<input id="endDate" type="text" class="datepicker" />
							</div>
						</div>
					</div>
				</div>

				<!-- "View Reviews" button -->
				<div class="form-group">
					<div>
						<button type="submit" id="viewReviews"
							class="btn btn-primary col-md-4 col-md-offset-4">View
							Reviews</button>
					</div>
				</div>

			</form>

		</div>

		<!-- Tabs to show information of user reviews -->
		<div class="col-md-9" style="border-left:2px solid #eeeeee;">
			<ul class="nav nav-tabs">
				<!-- Reviews tab -->
				<li class="active"><a href="#userViewsTab" data-toggle="tab">Reviews</a></li>

				<!-- Ratings tab -->
				<li><a href="#ratingTab" data-toggle="tab">Ratings</a></li>

				<!-- Review-Trends tab -->
				<li><a href="#reviewTrendsTab" data-toggle="tab">Review-Trends</a></li>

				<!-- Rating-Trends tab -->
				<li><a href="#ratingTrendsTab" data-toggle="tab">Rating-Trends</a></li>
			</ul>

			<div class="tab-content">

				<!-- Reviews tab content -->
				<div class="tab-pane active" id="userViewsTab">

					<div class="col-md-12" id="firstTabMessage">
						<br />
						<!-- Message to be shown initially -->
						<h4 class="text-center">
							<strong class="text-primary">Reviews tab shows a graph
								of total reviews and corresponding text of reviews for each
								business across Websites.</strong>
						</h4>
					</div>
					<div class="col-md-12">
						<!-- Chart section to show number of reviews of a website for each business selected -->
						<div class="col-md-5" id="chartSection">
							<div id="businessVsReviews"
								style="width: 400px; height: 340px; margin: 0 auto"></div>

							<!-- Warning message under the reviews chart -->
							<div class="text-center col-md-offset-3">
								<p class="text-danger" id="firstChartWarning"><b>Click on each
									item of Legend to enable/disable it in graph</b></p>
                            </div>
                        </div>

                        <!-- Reviews shown in this section for the sites, businesses and timeline selected by user -->
                        <div class="col-md-7" id="resultsSection">

                            <div class="col-md-12">
                                <p id="results" class="bg-primary"></p>
                            </div>
                            <div id="reviews"></div>

                        </div>
                    </div>

                    <!-- Note section in first tab to provide information about the functionalities that a user can perform -->
                    <div class="col-md-12" id="firstTabNote">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h6 class="panel-title">
                                    <a data-toggle="collapse" href="#firstNoteSection">Note on
                                        <b>Reviews</b> tab (Click here to expand/collapse)
                                    </a>
                                </h6>
                            </div>
                            <div class="panel-collapse collapse in" id="firstNoteSection">
                                <div class="panel-body">
                                    <ul>
                                        <li><b>Find reviews of a business and Website:</b> Click
                                            the column bar of chart to see the corresponding reviews of
                                            that particular business and website on the right side.</li>
                                        <li><b>Find reviews using legend items:</b> Click
                                            on each legend item of graph to enable/disable it. Enabling/disabling
                                            legend items change the reviews on the right side. </li>
                                        <li><b>Print and export chart:</b> Chart can be printed
                                            and exported to various formats like PNG, JPEG, PDF and SVG
                                            using the "Chart context menu" that is on the right top
                                            corner of the chart.</li>
                                        <li><b>Pagination:</b> Number of records per page varies
                                            with the number selected from the "Show" dropdown. Navigation
                                            to front and back pages with reviews can be done using the
                                            pagination option under reviews.</li>
                                        <li><b>Searching:</b> To search user reviews with a
                                            specific keyword, provide the keyword in "Search" textbox and
                                            then press "Enter" key or "Tab" key. To get back to all the reviews,
                                            just clear the text in "Search" text box and press "Enter"
                                            key or "Tab" key.</li>
                                        <li><b>Single column sorting:</b> "Author", "Date",
                                            "Business", "Rating" and "Website" attributes can be sorted
                                            individually in ascending or descending order just by
                                            clicking on each attribute. Upward arrow indicates ascending
                                            and downward arrow indicates descending.</li>
                                        <li><b>Multiple attributes' sorting:</b> Multi
                                            attributes's sort is possible by clicking an attribute, then
                                            pressing "Shift" key and clicking on another attribute. This
                                            kind sorting is possible with all the five attributes. Order
                                            of the sorting depends on the order of selecting each
                                            attribute followed by a "Shift" key press.</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- Ratings tab content -->
                <div class="tab-pane" id="ratingTab">
                    <!-- Message to be shown initially on load of this tab -->
                    <div class="col-md-12" id="secondTabMessage">
                        <br />
                        <h4 class="text-center">
                            <strong class="text-primary">Ratings tab shows a graph
                                of average ratings for each business across Websites. Each
                                column on click shows Average Rating, Standard Deviation and
                                Median for the number of total reviews.</strong>
                        </h4>
                    </div>
                    <!-- Chart section to show average ratings for each business across websites -->
                    <div class="col-md-11" id="ratingChartSection">
                        <div id="businessVsRatings"
                            style="min-width: 925px; height: 340px; margin: 0 auto"></div>
                        <div class="text-center">
                            <!-- Warning message to be shown under the average ratings' chart -->
                            <p class="text-danger" id="secondChartWarning">
                                <b>Click on each item of Legend to enable/disable it in
                                    graph</b>
                            </p>
                        </div>
                    </div>

                    <!-- Note section in second tab to provide information about the functionalities that a user can perform -->
                    <div class="col-md-12" id="secondTabNote">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h6 class="panel-title">
                                    <a data-toggle="collapse" href="#secondNoteSection">Note on
                                        <b>Ratings</b> tab(Click here to expand/collapse)
                                    </a>
                                </h6>
                            </div>
                            <div class="panel-collapse collapse in" id="secondNoteSection">
                                <div class="panel-body">
                                    <ul>
                                        <li>For each business, total number of reviews column bar
                                            is followed by number of reviews per website column bars.</li>
                                        <li><b>Find Median and Standard Deviation(SD):</b> Click
                                            the column bar of chart to see "Total number of reviews",
                                            "Median Rating", and "Average Rating" +/- "Standard
                                            Deviation" value.</li>
                                        <li><b>Print and export chart:</b> Chart can be printed
                                            and exported to various formats like PNG, JPEG, PDF and SVG
                                            using the "Chart context menu" that is on the right top
                                            corner of the chart.</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- Review-Trends tab content -->
                <div class="tab-pane" id="reviewTrendsTab">
                    <div class="col-md-12" id="thirdTabMessage">
                        <br /> <br />
                        <!-- Initial message to be shown on load of this tab -->
                        <h4 class="text-center">
                            <strong class="text-primary">Review-Trends tab shows a
                                Drilldown graph of total reviews for a Business from Website to
                                Yearly, Monthly and finally Daily trend.</strong>
                        </h4>
                    </div>
                    <!-- Total reviews trend charts -->
                    <div class="col-md-11" id="trendsChartSection">
                        <!-- Business chart to show total reviews across each website -->
                        <div id="businessContainer" style="">
                            <br/>
                            <div class="text-center">
                                <!-- Warning message under the chart -->
                                <p class="text-danger">
                                    <strong>Click on item of Legend to enable/disable it
                                        in graph. Click the bar to view <mark>YEARLY</mark> reviews
                                    </strong>
                                </p>
                            </div>
                            <div id="businessContainerChart"
                                style="min-width: 925px; height: 380px; margin: 0 auto"></div>
                        </div>
                        <!-- Website chart to show total reviews across each year -->
                        <div id="websiteContainer" style="">
                            <br/>
                            <div>
                                <button class="btn btn-info col-md-4" id="backToBusinessView">Back
                                    to the Business view</button>
                                <!-- Warning message under the chart -->
                                <p class="text-danger text-center col-md-8">
                                    <strong>Click on item of Legend to enable/disable it
                                        in graph. Click the bar to view <mark>MONTHLY</mark> reviews
                                    </strong>
                                </p>
                            </div>
                            <div class="col-md-12" id="websiteContainerChart"
                                style="min-width: 925px; height: 380px; margin: 0 auto"></div>
                        </div>
                        <!-- Yearly chart to show total reviews across each month -->
                        <div id="yearContainer" style="">
                            <br/>
                            <div>
                                <button class="btn btn-info col-md-4" id="backToWebsiteView">Back
                                    to the Yearly view</button>
                                <!-- Warning message under the chart -->
                                <p class="text-danger text-center col-md-8">
                                    <strong>Click on item of Legend to enable/disable it
                                        in graph. Click the bar to view <mark>DAILY</mark> reviews
                                    </strong>
                                </p>
                            </div>
                            <div class="col-md-12" id="yearContainerChart"
                                style="min-width: 925px; height: 380px; margin: 0 auto"></div>
                        </div>
                        <!-- Monthly chart to show total reviews across each day -->
                        <div id="monthContainer" style="">
                            <br/>
                            <div>
                                <button class="btn btn-info col-md-4" id="backToYearlyView">Back
                                    to the Monthly view</button>
                                <!-- Warning message under the chart -->
                                <p class="text-danger text-center col-md-8">
                                    <strong>Click on item of Legend to enable/disable it
                                        in graph.<br /> <br />
                                    </strong>
                                </p>
                            </div>
                            <div class="col-md-12" id="monthContainerChart"
                                style="min-width: 925px; height: 380px; margin: 0 auto"></div>
                        </div>
                        <!-- Information message to indicate when total reviews trend charts can be seen by user -->
                        <div class='text-center'>
                            <h3 id="viewWithOneBusiness" class="text-danger"></h3>
                        </div>
                    </div>
                    <!-- Note section in third tab to provide information to user about functionalities that a user can perform -->
                    <div class="col-md-12" id="thirdTabNote">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h6 class="panel-title">
                                    <a data-toggle="collapse" href="#thirdNoteSection">Note on
                                        <b>Review-Trends</b> tab(Click here to expand/collapse)
                                    </a>
                                </h6>
                            </div>
                            <div class="panel-collapse collapse in" id="thirdNoteSection">
                                <div class="panel-body">
                                    <ul>
                                        <li><b>Print and export charts:</b> Chart can be printed
                                            and exported to various formats like PNG, JPEG, PDF and SVG
                                            using the "Chart context menu" that is on the right top
                                            corner of the chart.</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Rating-Trends tab content -->
                <div class="tab-pane" id="ratingTrendsTab">
                    <div class="col-md-12" id="fourthTabMessage">
                        <br /> <br />
                        <!-- Initial message to be shown on load of this tab -->
                        <h4 class="text-center">
                            <strong class="text-primary">Rating-Trends tab shows a
                                Drilldown graph of average ratings for a Business from Website
                                to Yearly, Monthly and finally Daily trend. Click the column bar
                                in Daily trend to view total number of reviews and average
                                rating for that day.</strong>
                        </h4>
                    </div>
                    <!-- Average rating trend charts -->
                    <div class="col-md-11" id="ratingTrendsChartSection">
                        <!-- Business chart to show average rating across each website -->
                        <div id="businessAvgRatingContainer" style="">
                            <br/>
                            <div class="text-center">
                                <!-- Warning message under the chart -->
                                <p class="text-danger">
                                    <strong>Click on item of Legend to enable/disable it
                                        in graph. Click the bar to view <mark>YEARLY</mark> average
                                        ratings
                                    </strong>
                                </p>
                            </div>
                            <div id="businessAvgRatingContainerChart"
                                style="min-width: 925px; height: 380px; margin: 0 auto"></div>
                        </div>
                        <!-- Website chart to show average rating across each year -->
                        <div id="websiteAvgRatingContainer" style="">
                            <br/>
                            <div>
                                <button class="btn btn-info col-md-4"
                                    id="backToBusinessAvgRatingView">Back to the Business
                                    view</button>
                                <!-- Warning message under the chart -->
                                <p class="text-danger text-center col-md-8">
                                    <strong>Click on item of Legend to enable/disable it
                                        in graph. Click the bar to view <mark>MONTHLY</mark> average
                                        ratings
                                    </strong>
                                </p>
                            </div>
                            <div class="col-md-12" id="websiteAvgRatingContainerChart"
                                style="min-width: 925px; height: 380px; margin: 0 auto"></div>
                        </div>
                        <!-- Yearly chart to show average rating across each month -->
                        <div id="yearAvgRatingContainer" style="">
                            <br/>
                            <div>
                                <button class="btn btn-info col-md-4"
                                    id="backToWebsiteAvgRatingView">Back to the Yearly
                                    view</button>
                                <!-- Warning message under the chart -->
                                <p class="text-danger text-center col-md-8">
                                    <strong>Click on item of Legend to enable/disable it
                                        in graph. Click the bar to view <mark>DAILY</mark> average
                                        ratings
                                    </strong>
                                </p>
                            </div>
                            <div class="col-md-12" id="yearAvgRatingContainerChart"
                                style="min-width: 925px; height: 380px; margin: 0 auto"></div>
                        </div>
                        <!-- Monthly chart to show average rating across each day -->
                        <div id="monthAvgRatingContainer" style="">
                            <br/>
                            <div>
                                <button class="btn btn-info col-md-4"
                                    id="backToYearlyAvgRatingView">Back to the Monthly
                                    view</button>
                                <!-- Warning message under the chart -->
                                <p class="text-danger text-center col-md-8">
                                    <strong>Click on item of Legend to enable/disable it
                                        in graph. Click on the column bar to view total reviews on
                                        that day.</strong>
                                </p>
                            </div>
                            <div class="col-md-12" id="monthAvgRatingContainerChart"
                                style="min-width: 925px; height: 380px; margin: 0 auto"></div>
                        </div>
                        <!-- Information message to indicate when average rating trend charts can be seen by user -->
                        <div class='text-center'>
                            <h3 id="viewAvgRatingWithOneBusiness" class="text-danger"></h3>
                        </div>
                    </div>
                    <br /> <br />
                    <!-- Note section in fourth tab to provide information to user about functionalities that a user can perform -->
                    <div class="col-md-12" id="fourthTabNote">
                        <div class="panel panel-primary">
                            <div class="panel-heading">
                                <h6 class="panel-title">
                                    <a data-toggle="collapse" href="#fourthNoteSection">Note on
                                        <b>Rating-Trends</b> tab(Click here to expand/collapse)
                                    </a>
                                </h6>
                            </div>
                            <div class="panel-collapse collapse in" id="fourthNoteSection">
                                <div class="panel-body">
                                    <ul>
                                        <li><b>Print and export charts:</b> Chart can be printed
                                            and exported to various formats like PNG, JPEG, PDF and SVG
                                            using the "Chart context menu" that is on the right top
                                            corner of the chart.</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

        </div>

    </div>
    
    <!-- Horizontal bar to indicate end of the page  -->
    <div class="container" >
        <div class="row">
            <hr />
            <div class="col-md-12">
                <p class="text-muted">SFSU Project - Fall 2014</p>
            </div>
        </div>
    </div>

    <!-- Include all compiled plug-ins (below), or include individual files as needed -->
    <!-- Twitter Bootstrap -->
    <script src="scripts/bootstrap.min.js"></script>

    <!-- <script src="scripts/jquery.simplePagination.js"></script>  -->

    <!-- Dynatable for pagination, sorting and searching -->
    <script src="scripts/jquery.dynatable.js"></script>

    <!-- Bootstrap Form Helpers for calendar date fields -->
    <script src="scripts/bootstrap-formhelpers.js"></script>

    <!-- Highcharts for all charts used in this application -->
    <script src="http://code.highcharts.com/highcharts.js"></script>

    <!-- Highcharts export functionality to export and print charts -->
    <script src="http://code.highcharts.com/modules/exporting.js"></script>

</body>
</html>	