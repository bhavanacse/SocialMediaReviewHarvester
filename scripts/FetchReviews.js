var json;
var totalWebsitesCount;

// Function to execute when response is successfully obtained from "ViewUserReviews.jsp"
function functionWhenSucceeds(response) {
	json = response;
	// Global variable to get the count of total number of sites selected by user
	totalWebsitesCount = (Object.keys(json)).length;

	// Renders user reviews under Results section of Reviews tab
	renderReviews(null, null);
	// Renders the total reviews chart in Reviews tab
	renderReviewsChart();

	// Function used to calculate the total reviews and average ratings at all levels like business, web site, year, month and day
	generateAggregates();
	// Render average ratings chart in Reviews tab
	renderRatingsChart();

	for (myKey in json) {
		var numBusis = (Object.keys(json[myKey])).length;
	}
	if (numBusis == 1) {
		// Hide the information message if only one business is selected by user 
		$('#viewWithOneBusiness').hide();
		$('#viewAvgRatingWithOneBusiness').hide();

		// Render the total reviews trend chart for a business across web sites
		renderTrendsChart(
				sitesArray,
				businessChartName(),
				websiteTotalsArray,
				yearlyTrendsFunction,
				'#businessContainer',
				'Reviews of ',
				'Yearly, Monthly, or Daily total reviews of business across sites with Drilldown',
				'Number of User Reviews', hidereviewCharts, 'reviews', false);
		// Render the average ratings trend chart for a business across web sites
		renderTrendsChart(
				sitesArray,
				businessAvgRatingChartName(),
				websiteAvgRatingArray,
				yearlyAvgRatingTrendsFunction,
				'#businessAvgRatingContainer',
				'Average Ratings of ',
				'Yearly, Monthly, or Daily average ratings of business across sites with Drilldown',
				'Average Rating', hideAvgRatingCharts, 'avg rating', false);
		// Show the note sections in third and fourth tabs
		$('#thirdTabNote').show();
		$('#fourthTabNote').show();
	} else {
		// Hide the charts if more than one business is selected by user
		hidereviewCharts();
		hideAvgRatingCharts();
		
		// Hide the note sections in third and fourth tabs
		$('#thirdTabNote').hide();
		$('#fourthTabNote').hide();

		// Show the information message
		$('#viewWithOneBusiness').show();
		$('#viewAvgRatingWithOneBusiness').show();
		document.getElementById("viewWithOneBusiness").innerHTML = "Please select single business to view review trends over websites, years & months";
		document.getElementById("viewAvgRatingWithOneBusiness").innerHTML = "Please select single business to view average rating trends over websites, years & months";
	}
}

// Function to find whether value is present in an array
function isInArray(value, array) {
	return array.indexOf(value) > -1;
}

//Renders the total reviews chart in Reviews tab
function renderReviews(sites, business) {

	$("#loaderImage").hide(); // Hide the loading image

	var keyBusiness, idx, ptr;
	// Construct the header of attributes under Results section
	var out = "<div id='tabularForm' class='col-md-12'><table class='table table-striped' id='reviewsTable' style='font-size:12px;'>"
			+ "<thead><tr>"
			+ "<th class='col-md-2'><p class='text-primary col-md-offset-2'>Author</p></th>"
			+ "<th class='col-md-2'><p class='text-primary col-md-offset-1'>Date</p></th>"
			+ "<th class='col-md-4'><p class='text-primary col-md-offset-3'>Business</p></th>"
			+ "<th class='col-md-2'><p  class='text-primary col-md-offset-4'>Rating</p></th>"
			+ "<th class='col-md-2'><p class='text-primary'>Website</p></th>"
			+ "</tr></thead>";

	var jsonRecords = [];

	for ( var key in json) {

		/*
		 * if (site != null && site.toLowerCase() != key.toLowerCase()) {
		 * continue; }
		 */

		if (sites != null) {
			if (!(isInArray(key.toLowerCase(), sites))) {
				continue;
			}
		}

		for ( var idx in json[key]) {

			if (business != null && business != idx) {
				continue;
			}

			ptr = 0;
			while (ptr < json[key][idx].length) {
				var rating = json[key][idx][ptr].ssdcommentorrating;
				var postingUrl = json[key][idx][ptr].postingURL;
				var ref;

				rating = rating == null ? "N/A" : rating;
				postingUrl = postingUrl == null ? "" : postingUrl;
				ref = postingUrl == "" ? "#" : postingUrl;

				var jsonRecordsEntry = {};

				// Take the values of required columns into jsonRecordEntry
				jsonRecordsEntry["website"] = key;
				if (rating == "N/A") {
					jsonRecordsEntry["rating"] = rating;
				} else {
					jsonRecordsEntry["rating"] = (parseFloat(rating))
							.toFixed(1);
				}
				jsonRecordsEntry["author"] = json[key][idx][ptr].ssdcommentorname;
				jsonRecordsEntry["date"] = json[key][idx][ptr].ssdconvertedpostat;
				jsonRecordsEntry["comment"] = json[key][idx][ptr].ssdcomment;
				jsonRecordsEntry["business"] = idx;
				jsonRecords.push(jsonRecordsEntry);

				ptr++;
			}
		}

	}
	out += "</table></div>";
	if (out != "") {
		// If the column bar is clicked then show site - business as heading for user reviews 
		if (sites != null && sites.length == 1) {
			if (business != null) {
				document.getElementById("results").innerHTML = "<h4><b><center>"
						+ sites[0].toUpperCase()
						+ " - "
						+ business
						+ "</center></b></h4>";
				// If the legend items of the graph are enabled/disabled, then "Results" is shown as heading
			} else {
				document.getElementById("results").innerHTML = "<h4><b><center>Results</center></b></h4>";
			}
			// 	"Results" heading is shown as default
		} else {
			document.getElementById("results").innerHTML = "<h4><b><center>Results</center></b></h4>";
		}
	}
	document.getElementById("reviews").innerHTML = out;

	// Dynatable used for pagination, sorting and searching
	var dynamictable = $('#reviewsTable').dynatable({
		dataset : {
			records : jsonRecords,
			perPageDefault : 10
		// Show 10 records per page as default
		},
		writers : {
			_rowWriter : resultRowWriter
		},
		features : {
			paginate : true, // Pagination enabled
			search : true, // Search enabled
			recordCount : true, // Message that shows total records enabled
			perPageSelect : true, // Number of records to show per page enabled
			sorting : true
		// Sorting enabled
		},
		inputs : {
			recordCountPlacement : 'before' // Number of records message to show on top under Results section
		}
	});
}

// Get the icon name using the site names
function getIconName(icon) {
	icon = icon.toLowerCase();
	var iconName = "fa fa-" + icon;
	return iconName;
}

//Function to define the style of how the reviews should be displayed 
function resultRowWriter(rowIndex, record, columns, cellWriter) {
	return "<tr>" + "<td colspan=5>"
			+ "<table style='width: 100%; font-size:12px;'>"
			+ "<tr style='border-bottom:1px solid #CCCCCC;'>"
			+ "<td class='col-md-2'><p>" + "<strong>"
			+ record.author
			+ "</strong>"
			+ "</p></td>"
			+ "<td class='col-md-3'><p>"
			+ record.date
			+ "</p></td>"
			+ "<td class='col-md-5'><p class='text-success'>"
			+ "<strong>"
			+ record.business
			+ "</strong></p></td>"
			+ "<td class='col-md-1'><p class='text-danger'>"
			+ "<strong>"
			+ record.rating
			+ "</strong>"
			+ "</p></td>"
			+ "<td class='col-md-1'><div style='float:left' class='col-md-1'><a href='#'><i class='"
			+ getIconName(record.website)
			+ " fa-1x'></i></a>"
			+ "<p class='text-primary'><small>"
			+ record.website.toLowerCase()
			+ "</small></p></div></td>"
			+ "</tr>"
			+ "<tr>"
			+ "<td colspan=5><br/>"
			+ record.comment
			+ "</td>"
			+ "</tr>"
			+ "</table>" + "</td>" + "</tr>";
}

// Function that renders total reviews chart
function renderReviewsChart() {

	var currentSiteNum = 0, seriesNames = [], seriesDatasets = [];

	var elementsCount, idxs, totalBusinesses;
	var currentKey, currentIdx;
	var labelsArray = [];

	for (currentKey in json) {
		var icon = currentKey.toLowerCase();

		// seriesNames is an array that stores site names sequencially
		seriesNames[currentSiteNum] = icon.toUpperCase();

		for (currentIdx in json[currentKey]) {

			idxs = Object.keys(json[currentKey]);
			totalBusinesses = idxs.length;

			// Assemble the business names into labelsArray
			if (labelsArray.length < totalBusinesses) {
				labelsArray.push(currentIdx);
			}

			elementsCount = json[currentKey][currentIdx].length;

			if (!seriesDatasets[currentSiteNum]) {
				seriesDatasets[currentSiteNum] = [];
			}
			// seriesDatasets stores total reviews for each site sequencially
			seriesDatasets[currentSiteNum].push(elementsCount);

		}
		currentSiteNum++;
	}

	var seriesData = [];

	// Build an object with key value pairs of sitenames and total reviews
	for (var seriesIdx = 0; seriesIdx < totalWebsitesCount; seriesIdx++) {
		seriesObject = {};
		seriesObject["name"] = seriesNames[seriesIdx];
		seriesObject["data"] = seriesDatasets[seriesIdx];
		seriesData.push(seriesObject);
	}

	// Highcharts used to generate the chart
	$('#businessVsReviews')
			.highcharts(
					{
						chart : {
							type : 'column'
						},
						title : {
							text : 'Distinct Business User Reviews'
						},
						subtitle : {
							text : 'Reviews of businesses across Social-Media sites'
						},
						xAxis : {
							// Businessnames array
							categories : labelsArray
						},
						yAxis : {
							min : 0,
							title : {
								text : 'Number of User Reviews'
							}
						},
						tooltip : {
							positioner : function() {
								return {
									x : 80,
									y : 100
								};
							},
							headerFormat : '<span style="font-size:10px">{point.key}</span><table>',
							pointFormat : '<tr><td style="color:{series.color};padding:0">{series.name}: </td>'
									+ '<td style="padding:0"><b>{point.y} reviews</b></td></tr>',
							footerFormat : '</table>',
							shared : true,
							useHTML : true
						},
						plotOptions : {
							column : {
								pointPadding : 0.2,
								borderWidth : 0,
								events : {
									// Click of the legend item changes reviews that are rendered
									legendItemClick : function() {
										var series = this.chart.series;
										var currentSeriesIndex = this.index;
										var thisSeries = this.name;
										var visib = [];
										var visibility = this.visible ? 'visible'
												: 'hidden';
										// Get the values of those sites which are still enabled
										for (var i = 0; i < series.length; i++) {

											if (i != currentSeriesIndex) {
												if (series[i].visible == true) {
													visib.push((series[i].name)
															.toLowerCase());
												}
											} else {
												if (visibility == 'visible') {

												} else {
													visib.push(thisSeries
															.toLowerCase());
												}
											}
										}
										renderReviews(visib, null);
										// return false; // <== returning false
										// will cancel the default action
									}
								},
								showInLegend : true
							},
							series : {
								cursor : 'pointer',
								point : {
									events : {
										// Click of the column bar displays the reviews of particular business and web site
										click : function() {
											var busnesName = this.category;
											var siteName = [];
											siteName.push((this.series.name)
													.toLowerCase());
											//alert(siteName + " " + busnesName);
											renderReviews(siteName, busnesName);
										}
									}
								}
							}
						},
						// Give the object of key value pairs of sitenames and their total reviews
						series : seriesData
					});
}

// Function to render average ratings chart for each business across websites
function renderRatingsChart() {

	var ratingSeriesNames = [], averageRatingsDataset = [];
	var ratingsTotal = [], commentsTotal = [];

	var numTotalBusinesses;
	var presentKey, presentIdx, presentPtr;
	var businessNamesArray = [];

	var presentSiteNum = 0;
	// Parsing the obtained json 
	for (presentSiteName in json) {

		var websiteName = presentSiteName.toLowerCase();
		// ratingSeriesNames.push(websiteName.toUpperCase());
		// Gather the site names in an array
		ratingSeriesNames.push(presentSiteName);

		if (!ratingsTotal[presentSiteNum]) {
			ratingsTotal[presentSiteNum] = [];
		}

		if (!commentsTotal[presentSiteNum]) {
			commentsTotal[presentSiteNum] = [];
		}

		if (!averageRatingsDataset[presentSiteNum]) {
			averageRatingsDataset[presentSiteNum] = [];
		}

		var presentBusinessNum = 0;
		for (presentBusinessIdx in json[presentSiteName]) {

			numTotalBusinesses = (Object.keys(json[presentSiteName])).length;

			// Total reviews for each business on a website
			var numCommentsForBusiness = json[presentSiteName][presentBusinessIdx].length;

			// Gather the business names in an array
			if (businessNamesArray.length <= numTotalBusinesses) {
				businessNamesArray.push(presentBusinessIdx);
			}

			presentPtr = 0;
			var ratingsTotalForBusiness = 0.0;

			while (presentPtr < numCommentsForBusiness) {

				var rating = json[presentSiteName][presentBusinessIdx][presentPtr].ssdcommentorrating;

				var ratingFloat = rating == null ? 0.0 : parseFloat(rating);

				ratingsTotalForBusiness += ratingFloat;
				presentPtr++;
			}

			// Gather the ratings totals for each business on a website
			ratingsTotal[presentSiteNum][presentBusinessNum] = ratingsTotalForBusiness;
			// alert("Ratings Total on" + presentSiteName + "for"
			// + presentBusinessIdx + "= " + ratingsTotalForBusiness);

			if (websiteName == "twitter") {
				// Consider the total number of reviews as 0 if the website is "twitter"
				commentsTotal[presentSiteNum][presentBusinessNum] = 0;
			} else {
				commentsTotal[presentSiteNum][presentBusinessNum] = numCommentsForBusiness;
			}
			// alert("Total number of comments on" + presentSiteName + "for"
			// + presentBusinessIdx + "= "
			// + commentsTotal[presentSiteNum][presentBusinessNum]);

			if (numCommentsForBusiness == 0) {
				// To avoid divide-by-zero errors
				averageRatingsDataset[presentSiteNum][presentBusinessNum] = 0;
			} else {
				// Calculate the average rating for each business on each site 
				averageRatingsDataset[presentSiteNum][presentBusinessNum] = Math
						.round(ratingsTotalForBusiness / numCommentsForBusiness);
			}

			presentBusinessNum++;
		}
		presentSiteNum++;
	}

	// Calculating the total average rating for each business
	var datasetTotals = [];
	var compRatingsTotal, compCommentsTotal;
	for (var b = 0; b < numTotalBusinesses; b++) {
		compRatingsTotal = 0.0;
		compCommentsTotal = 0;
		for (var s = 0; s < totalWebsitesCount; s++) {
			compRatingsTotal += ratingsTotal[s][b];
			compCommentsTotal += commentsTotal[s][b];
		}
		// alert("Complete Ratings Total= " + compRatingsTotal);
		// alert("Number of Comments= " + compCommentsTotal);
		var totalAvgRat = (compCommentsTotal == 0 ? 0 : Math
				.round(compRatingsTotal / compCommentsTotal));
		datasetTotals.push(totalAvgRat);
	}

	// Construct an object of key value pairs with sites and their average ratings for each business preceded by total average rating
	var seriesAvgRatingsData = [];

	var seriesAvgRatingsObject = {};
	seriesAvgRatingsObject["name"] = "Total Avg Rating";
	seriesAvgRatingsObject["data"] = datasetTotals;
	seriesAvgRatingsData.push(seriesAvgRatingsObject);

	for (var st = 0; st < totalWebsitesCount; st++) {
		seriesAvgRatingsObject = {};
		seriesAvgRatingsObject["name"] = ratingSeriesNames[st];
		seriesAvgRatingsObject["data"] = averageRatingsDataset[st];
		seriesAvgRatingsData.push(seriesAvgRatingsObject);
	}

	$("#loaderImage").hide(); // Hide loading image

	$('#businessVsRatings')
			.highcharts(
					{
						chart : {
							type : 'column'
						},
						title : {
							text : 'Distinct Business Average Ratings'
						},
						subtitle : {
							text : 'Average Ratings of businesses across Social-Media sites'
						},
						xAxis : {
							categories : businessNamesArray
						},
						yAxis : {
							min : 0,
							title : {
								text : 'Average Rating'
							}
						},
						tooltip : {
							positioner : function() {
								return {
									x : 100,
									y : 100
								};
							},
							headerFormat : '<span style="font-size:10px">{point.key}</span><table>',
							pointFormat : '<tr><td style="color:{series.color};padding:0">{series.name}: </td>'
									+ '<td style="padding:0"><b>{point.y} Avg Rating </b></td></tr>',
							footerFormat : '</table>',
							shared : true,
							useHTML : true
						},
						plotOptions : {
							column : {
								pointPadding : 0.2,
								borderWidth : 0
							},
							series : {
								cursor : 'pointer',
								point : {
									events : {
										// Column bar click
										click : function() {
											var businessValue = this.category;
											var siteValue = this.series.name;
											//alert(businessValue + " " + siteValue);
											alertTotalReviews(businessValue,
													siteValue);
										}
									}
								}
							}
						},
						series : seriesAvgRatingsData
					});
}

// Function that shows an alert with  total reviews, median rating, average rating and standard deviation 
function alertTotalReviews(bVal, sVal) {
	var stdDev;
	var median;
	// Alert for total average rating of a business
	if (sVal == "Total Avg Rating") {
		stdDev = calculateStandardDeviation(bVal, null);
		median = calculateMedian(bVal, null);
		alert("Business: "
				+ bVal
				+ ", Total number of reviews: "
				+ dictionary[bVal]["business_total_XcludngSitesWithRatingN/A"]
				+ ", Median rating: "
				+ median
				+ ", Average rating: "
				+ Math
						.round(dictionary[bVal]["businessRatings_total"]
								/ dictionary[bVal]["business_total_XcludngSitesWithRatingN/A"])
				+ " +/- " + stdDev);
		// Alert for average rating of a business on a site	
	} else {
		stdDev = calculateStandardDeviation(bVal, sVal);
		median = calculateMedian(bVal, sVal);
		alert("Business: "
				+ bVal
				+ ", Website: "
				+ sVal
				+ ", Total number of reviews: "
				+ dictionary[bVal][sVal]["website_total"]
				+ ", Median rating: "
				+ median
				+ ", Average rating: "
				+ Math.round(dictionary[bVal][sVal]["websiteRatings_total"]
						/ dictionary[bVal][sVal]["website_total"]) + " +/- "
				+ stdDev);
	}
}

// Function to calculate the Median for a whole business as well as for a business on a particular web site
function calculateMedian(nameOfBsns, nameOfSite) {
	var median = 0.0;
	var ratingsArray;
	if (nameOfSite == null) {
		ratingsArray = dictionary[nameOfBsns]["businessRatings_Array"];
	} else {
		ratingsArray = dictionary[nameOfBsns][nameOfSite]["websiteRatings_Array"];
	}
	ratingsArray.sort(function(a, b) {
		return a - b;
	});

	var half = Math.floor(ratingsArray.length / 2);
	if (ratingsArray.length % 2 == 0) {
		median = (ratingsArray[half - 1] + ratingsArray[half]) / 2.0;
	} else {
		median = ratingsArray[half];
	}
	return median.toFixed(2);
}

// Function to calculate the standard deviation 
function calculateStandardDeviation(nameOfBusiness, nameOfWebsite) {
	var totalSquaresOfDiffs = 0.0;
	var standardDeviation = 0.0;
	// For a whole business 
	if (nameOfWebsite == null) {
		var totalRatingsInBusiness = dictionary[nameOfBusiness]["businessRatings_Array"].length;
		var avgRatingForBusiness = Math
				.round(dictionary[nameOfBusiness]["businessRatings_total"]
						/ dictionary[nameOfBusiness]["business_total_XcludngSitesWithRatingN/A"]);

		for (var ratingPointer = 0; ratingPointer < totalRatingsInBusiness; ratingPointer++) {
			var squareOfDiff_Business = Math
					.pow(
							dictionary[nameOfBusiness]["businessRatings_Array"][ratingPointer]
									- parseFloat(avgRatingForBusiness), 2);
			totalSquaresOfDiffs += squareOfDiff_Business
		}
		standardDeviation = Math.sqrt(totalSquaresOfDiffs
				/ totalRatingsInBusiness);
		// For a business on a particular web site	
	} else {
		var totalRatingsInWebsitePerBusiness = dictionary[nameOfBusiness][nameOfWebsite]["websiteRatings_Array"].length;
		var avgRatingOfWebsitePerBusiness = Math
				.round(dictionary[nameOfBusiness][nameOfWebsite]["websiteRatings_total"]
						/ dictionary[nameOfBusiness][nameOfWebsite]["website_total"]);

		for (var ratingIndex = 0; ratingIndex < totalRatingsInWebsitePerBusiness; ratingIndex++) {
			var squareOfDiff_Website = Math
					.pow(
							dictionary[nameOfBusiness][nameOfWebsite]["websiteRatings_Array"][ratingIndex]
									- parseFloat(avgRatingOfWebsitePerBusiness),
							2);
			totalSquaresOfDiffs += squareOfDiff_Website
		}
		standardDeviation = Math.sqrt(totalSquaresOfDiffs
				/ totalRatingsInWebsitePerBusiness);
	}

	return standardDeviation.toFixed(2);
}

var dictionary = {};
var sitesArray, businessName, websiteTotalsArray, websiteAvgRatingArray;

// Generates a dictionary which calculates total reviews and ratings total at levels of business, website, year, month and day 
function generateAggregates() {

	var currentWebsite, currentBusiness, currentPtr, numComments, length = 0;
	dictionary = {};
	sitesArray = [];
	websiteTotalsArray = [];
	websiteAvgRatingArray = [];
	for (currentWebsite in json) {

		sitesArray.push(currentWebsite);
		for (currentBusiness in json[currentWebsite]) {

			businessName = currentBusiness;
			numComments = json[currentWebsite][currentBusiness].length;
			currentPtr = 0;

			while (currentPtr < numComments) {
				var currentCommentDate = new Date(
						json[currentWebsite][currentBusiness][currentPtr].ssdconvertedpostat);
				var presentYear = currentCommentDate.getFullYear();
				var presentMonth = currentCommentDate.getMonth();
				var presentDate = currentCommentDate.getDate();

				var currentRating = json[currentWebsite][currentBusiness][currentPtr].ssdcommentorrating;
				currentRating = currentRating == null ? 0.0
						: parseFloat(currentRating);

				// For the whole business
				if (!dictionary[currentBusiness]) {
					dictionary[currentBusiness] = {};
					dictionary[currentBusiness]["businessRatings_Array"] = [];
					dictionary[currentBusiness]["business_total"] = 0; // Calculates total number of reviews
					// Calculates total number of reviews excluding sites with ratings as N/A
					dictionary[currentBusiness]["business_total_XcludngSitesWithRatingN/A"] = 0;
					// Calculates ratings total
					dictionary[currentBusiness]["businessRatings_total"] = 0.0;
				}
				// For a business on a website
				if (!dictionary[currentBusiness][currentWebsite]) {
					dictionary[currentBusiness][currentWebsite] = {};
					dictionary[currentBusiness][currentWebsite]["websiteRatings_Array"] = [];
					dictionary[currentBusiness][currentWebsite]["website_total"] = 0;
					dictionary[currentBusiness][currentWebsite]["websiteRatings_total"] = 0.0;
				}
				// For a business on a website on an year
				if (!dictionary[currentBusiness][currentWebsite][presentYear]) {
					dictionary[currentBusiness][currentWebsite][presentYear] = {};
					dictionary[currentBusiness][currentWebsite][presentYear]["yearlyRatings_Array"] = [];
					dictionary[currentBusiness][currentWebsite][presentYear]["yearly_total"] = 0;
					dictionary[currentBusiness][currentWebsite][presentYear]["yearlyRatings_total"] = 0.0;
				}
				// For a business on a website on an year and month
				if (!dictionary[currentBusiness][currentWebsite][presentYear][presentMonth]) {
					dictionary[currentBusiness][currentWebsite][presentYear][presentMonth] = {};
					dictionary[currentBusiness][currentWebsite][presentYear][presentMonth]["monthlyRatings_Array"] = [];
					dictionary[currentBusiness][currentWebsite][presentYear][presentMonth]["monthly_total"] = 0;
					dictionary[currentBusiness][currentWebsite][presentYear][presentMonth]["monthlyRatings_total"] = 0.0;
				}
				// For a business on a website on an year, month and day
				if (!dictionary[currentBusiness][currentWebsite][presentYear][presentMonth][presentDate]) {
					dictionary[currentBusiness][currentWebsite][presentYear][presentMonth][presentDate] = {};
					dictionary[currentBusiness][currentWebsite][presentYear][presentMonth][presentDate]["dailyRatings_Array"] = [];
					dictionary[currentBusiness][currentWebsite][presentYear][presentMonth][presentDate]["daily_total"] = 0;
					dictionary[currentBusiness][currentWebsite][presentYear][presentMonth][presentDate]["dailyRatings_total"] = 0.0;
				}

				// Save the Ratings into separate arrays
				dictionary[currentBusiness][currentWebsite]["websiteRatings_Array"]
						.push(currentRating);
				dictionary[currentBusiness][currentWebsite][presentYear]["yearlyRatings_Array"]
						.push(currentRating);
				dictionary[currentBusiness][currentWebsite][presentYear][presentMonth]["monthlyRatings_Array"]
						.push(currentRating);
				dictionary[currentBusiness][currentWebsite][presentYear][presentMonth][presentDate]["dailyRatings_Array"]
						.push(currentRating);

				// Finding total number of comments
				dictionary[currentBusiness]["business_total"] += 1;
				if (currentWebsite != "twitter") {
					dictionary[currentBusiness]["business_total_XcludngSitesWithRatingN/A"] += 1;
					dictionary[currentBusiness]["businessRatings_Array"]
							.push(currentRating);
				}
				dictionary[currentBusiness][currentWebsite]["website_total"] += 1;
				dictionary[currentBusiness][currentWebsite][presentYear]["yearly_total"] += 1;
				dictionary[currentBusiness][currentWebsite][presentYear][presentMonth]["monthly_total"] += 1;
				dictionary[currentBusiness][currentWebsite][presentYear][presentMonth][presentDate]["daily_total"] += 1;

				// Finding the totals of ratings
				dictionary[currentBusiness]["businessRatings_total"] += currentRating;
				dictionary[currentBusiness][currentWebsite]["websiteRatings_total"] += currentRating;
				dictionary[currentBusiness][currentWebsite][presentYear]["yearlyRatings_total"] += currentRating;
				dictionary[currentBusiness][currentWebsite][presentYear][presentMonth]["monthlyRatings_total"] += currentRating;
				dictionary[currentBusiness][currentWebsite][presentYear][presentMonth][presentDate]["dailyRatings_total"] += currentRating;

				currentPtr++;
			}

		}
		// If there are no comments
		if (numComments == 0) {
			websiteTotalsArray.push(0);
			websiteAvgRatingArray.push(0);
			// If there are comments, form two arrays
		} else {
			// Array that stores total reviews on a website for each business
			websiteTotalsArray
					.push(dictionary[currentBusiness][currentWebsite]["website_total"]);
			// Array that stores average rating on a website for each business
			websiteAvgRatingArray
					.push(Math
							.round(dictionary[currentBusiness][currentWebsite]["websiteRatings_total"]
									/ dictionary[currentBusiness][currentWebsite]["website_total"]));
		}
	}
	console.log(dictionary);
}

// Hide charts in Review-Trends tab
function hidereviewCharts() {
	$("#businessContainer").hide();
	$("#websiteContainer").hide();
	$("#yearContainer").hide();
	$("#monthContainer").hide();
}

//Hide charts in Rating-Trends tab
function hideAvgRatingCharts() {
	$("#businessAvgRatingContainer").hide();
	$("#websiteAvgRatingContainer").hide();
	$("#yearAvgRatingContainer").hide();
	$("#monthAvgRatingContainer").hide();
}

/*
 * Find the chart names
 */
function businessChartName() {
	return "Reviews for " + businessName;
}

function websiteChartName() {
	return "Reviews on website " + currentSiteName.toUpperCase();
}

function yearlyChartName() {
	return "Reviews on website " + currentSiteName.toUpperCase()
			+ " for the year " + currentYearNumber;
}

function monthlyChartName(monthName) {
	return "Reviews on website " + currentSiteName.toUpperCase() + " for "
			+ monthName + " of " + currentYearNumber;
}

function businessAvgRatingChartName() {
	return "Average Ratings for " + businessName;
}

function websiteAvgRatingChartName() {
	return "Average Ratings on website " + presentWebsiteName.toUpperCase();
}

function yearlyAvgRatingChartName() {
	return "Average Ratings on website " + presentWebsiteName.toUpperCase()
			+ " for the year " + presentYearNumber;
}

function monthlyAvgRatingChartName(month) {
	return "Average Ratings on website " + presentWebsiteName.toUpperCase()
			+ " for " + month + " of " + presentYearNumber;
}

var currentSiteName, currentYearNumber, currentMonthNumber;
var presentWebsiteName, presentYearNumber, presentMonthNumber;
var yearsArray, yearlyTotalsArray, yrsArray, yrlyAvgRatingArray;
var monthsArray, monthlyTotalsArray, mnsArray, mnlyAvgRatingArray;
var daysArray, dailyTotalsArray, desArray, delyAvgRatingArray;

// Chart that shows total reviews for each year of a website in Review-Trends tab  
function yearlyTrendsFunction() {
	yearsArray = [];
	yearlyTotalsArray = [];
	currentSiteName = this.category;
	for (yr in dictionary[businessName][currentSiteName]) {
		if (yr != "website_total" && yr != "websiteRatings_total"
				&& yr != "websiteRatings_Array") {
			yearsArray.push(yr);
			yearlyTotalsArray
					.push(dictionary[businessName][currentSiteName][yr]["yearly_total"]);
		}
	}
	renderTrendsChart(
			yearsArray,
			websiteChartName(),
			yearlyTotalsArray,
			monthlyTrendsFunction,
			'#websiteContainer',
			'Reviews of ',
			'Yearly, Monthly, or Daily total reviews of business across sites with Drilldown',
			'Number of User Reviews', hidereviewCharts, 'reviews', false);
}

//Chart that shows average rating for each year of a website in Rating-Trends tab
function yearlyAvgRatingTrendsFunction() {
	yrsArray = [];
	yrlyAvgRatingArray = [];
	presentWebsiteName = this.category;
	for (y in dictionary[businessName][presentWebsiteName]) {
		if (y != "website_total" && y != "websiteRatings_total"
				&& y != "websiteRatings_Array") {
			yrsArray.push(y);
			yrlyAvgRatingArray
					.push(Math
							.round(dictionary[businessName][presentWebsiteName][y]["yearlyRatings_total"]
									/ dictionary[businessName][presentWebsiteName][y]["yearly_total"]));
		}
	}
	renderTrendsChart(
			yrsArray,
			websiteAvgRatingChartName(),
			yrlyAvgRatingArray,
			monthlyAvgRatingTrendsFunction,
			'#websiteAvgRatingContainer',
			'Average Ratings of ',
			'Yearly, Monthly, or Daily average ratings of business across sites with Drilldown',
			'Average Rating', hideAvgRatingCharts, 'avg rating', false);
}

//Chart that shows total reviews for each month of an year in Review-Trends tab
function monthlyTrendsFunction() {
	monthsArray = [];
	monthlyTotalsArray = [];
	var mnthName;
	currentYearNumber = this.category;
	for (var mnth = 0; mnth < 12; mnth++) {
		mnthName = getMonthName(mnth);
		monthsArray.push(mnthName);

		if (!dictionary[businessName][currentSiteName][currentYearNumber][mnth]) {
			monthlyTotalsArray.push(0);
		} else {
			monthlyTotalsArray
					.push(dictionary[businessName][currentSiteName][currentYearNumber][mnth]["monthly_total"]);
		}
	}
	renderTrendsChart(
			monthsArray,
			yearlyChartName(),
			monthlyTotalsArray,
			dailyTrendsFunction,
			'#yearContainer',
			'Reviews of ',
			'Yearly, Monthly, or Daily total reviews of business across sites with Drilldown',
			'Number of User Reviews', hidereviewCharts, 'reviews', false);
}

// Generates a chart that shows average rating for each month of an year in Rating-Trends tab
function monthlyAvgRatingTrendsFunction() {
	mnsArray = [];
	mnlyAvgRatingArray = [];
	var mnName;
	presentYearNumber = this.category;
	for (var mn = 0; mn < 12; mn++) {
		mnName = getMonthName(mn);
		mnsArray.push(mnName);

		if (!dictionary[businessName][presentWebsiteName][presentYearNumber][mn]) {
			mnlyAvgRatingArray.push(0);
		} else {
			mnlyAvgRatingArray
					.push(Math
							.round(dictionary[businessName][presentWebsiteName][presentYearNumber][mn]["monthlyRatings_total"]
									/ dictionary[businessName][presentWebsiteName][presentYearNumber][mn]["monthly_total"]));
		}
	}
	renderTrendsChart(
			mnsArray,
			yearlyAvgRatingChartName(),
			mnlyAvgRatingArray,
			dailyAvgRatingTrendsFunction,
			'#yearAvgRatingContainer',
			'Average Ratings of ',
			'Yearly, Monthly, or Daily average ratings of business across sites with Drilldown',
			'Average Rating', hideAvgRatingCharts, 'avg rating', false);
}

var monthsInAYear = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug",
		"Sep", "Oct", "Nov", "Dec" ];
var daysInMonths = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];

// getMonthName Function
function getMonthName(v) {
	return monthsInAYear[v]
}

// Get the month number for a given month
function getMonthNumber(m) {
	for (var mon = 0; mon < monthsInAYear.length; mon++) {
		if (monthsInAYear[mon] == m) {
			return mon;
		}
	}
}

// Generates a total reviews chart for each day of the month in Review-Trends tab
function dailyTrendsFunction() {
	var length;
	daysArray = [];
	dailyTotalsArray = [];
	var mName = this.category;
	currentMonthNumber = getMonthNumber(mName);

	// Show all days in the chart though the number of reviews is zero for few days
	if (currentMonthNumber == 1) {
		if (currentYearNumber % 4 == 0) {
			length = 29;
		} else {
			length = 28;
		}
	} else {
		length = daysInMonths[currentMonthNumber];
	}
	// Show zero reviews if a particular day has no reviews
	for (var dy = 1; dy <= length; dy++) {
		daysArray.push(dy);
		if (!dictionary[businessName][currentSiteName][currentYearNumber][currentMonthNumber][dy]) {
			dailyTotalsArray.push(0);
		} else {
			dailyTotalsArray
					.push(dictionary[businessName][currentSiteName][currentYearNumber][currentMonthNumber][dy]["daily_total"]);
		}
	}

	renderTrendsChart(
			daysArray,
			monthlyChartName(mName),
			dailyTotalsArray,
			dailySum,
			'#monthContainer',
			'Reviews of ',
			'Yearly, Monthly, or Daily total reviews of business across sites with Drilldown',
			'Number of User Reviews', hidereviewCharts, 'reviews', false);
}

// Generate chart with average rating on each day of month in Rating-Trends tab 
function dailyAvgRatingTrendsFunction() {
	var lnth;
	desArray = [];
	delyAvgRatingArray = [];
	var monName = this.category;
	presentMonthNumber = getMonthNumber(monName);

	if (presentMonthNumber == 1) {
		if (presentYearNumber % 4 == 0) {
			lnth = 29;
		} else {
			lnth = 28;
		}
	} else {
		lnth = daysInMonths[presentMonthNumber];
	}
	for (var d = 1; d <= lnth; d++) {
		desArray.push(d);
		if (!dictionary[businessName][presentWebsiteName][presentYearNumber][presentMonthNumber][d]) {
			delyAvgRatingArray.push(0);
		} else {
			delyAvgRatingArray
					.push(Math
							.round(dictionary[businessName][presentWebsiteName][presentYearNumber][presentMonthNumber][d]["dailyRatings_total"]
									/ dictionary[businessName][presentWebsiteName][presentYearNumber][presentMonthNumber][d]["daily_total"]));
		}
	}

	renderTrendsChart(
			desArray,
			monthlyAvgRatingChartName(monName),
			delyAvgRatingArray,
			delySum,
			'#monthAvgRatingContainer',
			'Average Ratings of ',
			'Yearly, Monthly, or Daily average ratings of business across sites with Drilldown',
			'Average Rating', hideAvgRatingCharts, 'avg rating', false);
}

// Do nothing when user clicks on column bar of daily chart in Review-Trends tab 
function dailySum() {
	// alert(this.category);
}

// Alerts total number of reviews and average rating on click of column bar of a daily chart in Rating-Trends chart
function delySum() {
	var presentDayNumber = this.category;
	alert("Total number of reviews on DAY "
			+ presentDayNumber
			+ " is "
			+ dictionary[businessName][presentWebsiteName][presentYearNumber][presentMonthNumber][presentDayNumber]["daily_total"]
			+ " with Avg Rating "
			+ Math
					.round(dictionary[businessName][presentWebsiteName][presentYearNumber][presentMonthNumber][presentDayNumber]["dailyRatings_total"]
							/ dictionary[businessName][presentWebsiteName][presentYearNumber][presentMonthNumber][presentDayNumber]["daily_total"]));
}

// Uses Highchart to generate the trends chart
function renderTrendsChart(labelsArray, chartName, chartDataArray,
		nextTrendsFunction, chartContainer, titleText, subtitleText, yAxisText,
		hideChartsFunction, tooltipText, needColor) {
	$("#loaderImage").hide();
	hideChartsFunction();
	$(chartContainer).show();
	var chartContainerDiv = chartContainer + "Chart";
	$(chartContainerDiv)
			.highcharts(
					{
						chart : {
							type : 'column',
							// Edit chart spacing
							spacingBottom : 15,
							spacingTop : 10,
							spacingLeft : 30,
							spacingRight : 30,

							// Explicitly tell the width and height of a chart
							width : null,
							height : null
						},
						title : {
							text : titleText + businessName
						},
						subtitle : {
							text : subtitleText
						},
						xAxis : {
							categories : labelsArray
						},
						yAxis : {
							min : 0,
							title : {
								text : yAxisText
							}
						},
						tooltip : {
							pointFormat : '<table><tr><td style="padding:0; font-size:15px; color:{series.color};"><b>{point.y} '
									+ tooltipText + '</b></td></tr>',
							footerFormat : '</table>',
							shared : true,
							useHTML : true
						},
						plotOptions : {
							column : {
								pointPadding : 0.2,
								borderWidth : 0
							},
							series : {
								cursor : 'pointer',
								point : {
									events : {
										// Click of column bar generates another chart
										click : nextTrendsFunction
									}
								}
							}
						},
						series : [ {
							name : chartName,
							data : chartDataArray,
							colorByPoint : needColor
						} ]
					});
}

// Function to execute when response is not successfully obtained
function functionWhenFails(jqXHR, textStatus, errorThrown) {
	alert(textStatus);
}

// Function that hides From and To fields when other than "Date Range" is selected
function handleClick() {
	if (document.getElementById('dateRange').checked) {
		document.getElementById('dates').style.display = "block";
	} else {
		document.getElementById('dates').style.display = "none";

		/*
		var temporaryDate, thismnth, todaysDate;
		temporaryDate = new Date();
		thismnth = temporaryDate.getMonth() + 1;
		todaysDate = thismnth + '/' + temporaryDate.getDate() + '/' + temporaryDate.getFullYear();
		
		$('#startDateDiv').val(todaysDate);
		$('#startDate').val(todaysDate);
		
		$('#endDateDiv').val(todaysDate);
		$('#endDate').val(todaysDate);
		
		document.getElementById('startDateHidden').value = todaysDate;
		document.getElementById('endDateHidden').value = todaysDate;
		 */
	}
}
