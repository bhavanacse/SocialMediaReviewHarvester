//Function that executes on successful data retrieval from "CriteriaSelection.jsp"
function functionToCallWhenSucceed(response) {
	// Response from CriteriaSelection.jsp
	var json = response;
	var index, pointer;

	// Bind the response with site names and business names to multi-select
	// drop-downs of "Site" and "Business"
	var siteOutput = "<select name='socialsitename' id='sitename' class='multiselect' multiple='multiple'>";
	var businessOutput = "<select name='businame' id='businessname' class='multiselect' multiple='multiple'>";

	for (index = 0; index < json.socialmediasites.length; index++) {
		siteOutput += "<option " + "value='"
				+ json.socialmediasites[index].ssname + "'>"
				+ json.socialmediasites[index].ssname + "</option>";
	}

	for (pointer = 0; pointer < json.businesses.length; pointer++) {
		businessOutput += "<option " + "value='"
				+ json.businesses[pointer].bshortname + " - "
				+ json.businesses[pointer].bname + "'>"
				+ json.businesses[pointer].bshortname + " - "
				+ json.businesses[pointer].bname + "</option>";
	}

	siteOutput += "</select>";
	businessOutput += "</select>";

	document.getElementById("sitelist").innerHTML = siteOutput;
	document.getElementById("businesslist").innerHTML = businessOutput;
	$("#loadingImage").hide(); // Hide the loading image once the data is shown
	// in "Site" and "Business" fields

	// Multi-select drop-down configuration
	$('.multiselect').multiselect({
		includeSelectAllOption : false, // Disable "Select All" option
		enableCaseInsensitiveFiltering : true, // Search keywords without case
		// sensitivity
		enableFiltering : true, // To search keywords
		filterPlaceholder : 'Search', // Include "Search" option
		filterBehavior : 'both',
		maxHeight : 400, // Restrict the height of drop-down
		numberDisplayed : 0
	// Number of options to be shown on the display if selected
	});

	$("#sitename").change(function() {
		// Restrict the number of options to be selected on Site drop-down
		restrictOptionsLimit("#sitename");
	});

	$("#businessname").change(function() {
		// Restrict the number of options to be selected on Business drop-down
		restrictOptionsLimit("#businessname");
	});
}

// Function to restrict the number of options to be selected on drop-downs
function restrictOptionsLimit(idName) {
	// Get selected options.
	var selectedOptions = $(idName + " option:selected");

	// If the number of selected options is greater than five
	if (selectedOptions.length >= 5) {
		alert("Please select 5 or less businesses for good visibility of graph.");

		// Collect the options which are not selected
		var nonSelectedOptions = $(idName + " option").filter(function() {
			return !$(this).is(':selected');
		});

		// Disable those unselected check boxes
		var dropdown = $(idName).siblings(".multiselect-container");
		nonSelectedOptions.each(function() {
			var input = $('input[value="' + $(this).val() + '"]');
			input.prop('disabled', true);
			input.parent('li').addClass('disabled');
		});
	} else {
		// Enable all check boxes.
		var dropdown = $(idName).siblings(".multiselect-container");
		$(idName + " option").each(function() {
			var input = $('input[value="' + $(this).val() + '"]');
			input.prop('disabled', false);
			input.parent('li').addClass('disabled');
		});
	}
}

// Function that executes on failure while retrieving the response from
// "CriteriaSelection.jsp" page
function functionToCallWhenFailed(jqXHR, textStatus, errorThrown) {
	alert(textStatus);
	alert(jqXHR);
	alert(errorThrown);
}