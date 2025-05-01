// Get the title of the current image to be labeled
originalTitle = getTitle();

//Create the title of the labeled image if needed
//newTitle = replace(originalTitle, ".tif", "_labeled.tif"); //

//Create an image with the same size of the original image, filled with black pixels
newImage(originalTitle, "16-bit black", getWidth(), getHeight(), 1);

//Add all the ROIs to the black image with their label color
for (i = 0; i < roiManager("count"); i++) {
	roiManager("select", i);
	setColor(i+1);
	fill();
}

//Reset min/max to properly display labels since labeled image is in 16bit
resetMinAndMax();

//Get rid of ROI selection on image
run("Select None");