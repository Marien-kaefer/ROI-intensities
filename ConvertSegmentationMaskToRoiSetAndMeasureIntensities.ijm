// ImageJ macro to generate regions of interest from segmentation masks and measure the inteensities of all channels of the input data. 
// The last region of interest in each set is the full field of view minus the cell regions of interest that serves as a background measure. 
// Only the intensities of files are measured for which segmentation masks exist. 
// Saves files in another directory.
// Requires that ONLY folders containing ome.tif files be present in the source directory, no empty folders, no mdb files &c.
// The output directory should not be created in the input directory, thus creating an initially empty folder. 
//
//												- Written by Marie Held [mheldb@liv.ac.uk] July 2019
// 												  Liverpool CCI [http://cci.liv.ac.uk]

// Erase all entries in Log window
print("\\Clear");

// Ask user for the input and output directories
input = getDirectory("Source directory of segmentation masks");
//-- DEBUG only, make sure the path looks good
//print("Source directory of segmentation masks: " + input);
output = input + "ROI_Sets/"; 
File.makeDirectory(output);
//-- DEBUG only, make sure the path looks good
//print("Destination directory of ROI sets: " + output);

// run script without diplaying the images during macro excecution
setBatchMode(true);

print("------------- Start extracting the regions of interest from each mask located in the input folder. -------------");
print("... Working on it ...");

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
    list = getFileList(input);
    //-- DEBUG only, print the list to see what we have
	//print("Files located in input folder:")
	//Array.print(list);
    for (i = 0; i < list.length; i++) {
        if(File.isDirectory(list[i]))
            processFolder("" + input + list[i]);
        if(endsWith(list[i], ".tiff"))
            processFile(input, output, list[i]);
    } // -- for loop close
} // -- function close
 
function processFile(input, output, file) {
    //-- DEBUG only, print the file name being processed
    //print("Processing: " + input + file);
    open(input + file);
	title=getTitle();
	setOption("ScaleConversions", true);
	run("8-bit");
	//run("Invert LUT");
	run("Fill Holes");
	run("Analyze Particles...", "size=350-Infinity clear add");
	count = roiManager("count");
	if(count > 1){
		selectWindow(title);
		run("Select All");
		roiManager("Add");
		roiManager("Deselect");
		count = roiManager("count");
		roiManager("XOR");
		roiManager("Add");
		roiManager("Deselect");
		count = roiManager("count");
		roiManager("select", count-2);
		roiManager("delete");
	
		//-- Save regions of interest as zip file
		titleOut = File.nameWithoutExtension(); 
		selectWindow(title);
		//-- DEBUG only, make sure the path looks good
		//print("Saving to: " + output + titleOut + "_ROISet.zip");
		ROIOutput = titleOut + "_ROISet.zip";
		roiManager("Save", output + ROIOutput);
		roiManager("deselect");
		roiManager("delete");

	} // -- if condition close

} // -- function close

print("------------- Finished extracting the regions of interest from each mask located in the input folder. -------------");

print(" ");

print("------------- Start measuring the minimum, maximum and median intensities of the generated regions of interest for each channel. -------------");

inputData = getDirectory("Source directory containing the microscopy data files");
inputROI = output;
//-- DEBUG only, make sure the path looks good
//print("Data directory: " + inputData);
//print("ROI directory: " + inputROI);

run("Set Measurements...", "min median display redirect=None decimal=3");

measureIntensities(inputData);

function measureIntensities(inputData) {
		//-- get a list of files and folders in the input directory
	list = getFileList(inputData);
	print("... Working on it ...");
	//-- DEBUG only, print the list to see what we have
	//print("Folders located in input folder:")
	//Array.print(list);

	IntOutput = inputData + "RegionOfInterestIntensities/"; 
	File.makeDirectory(IntOutput);
	//-- DEBUG only, make sure the path looks good
	// print("Destination directory of ROI sets: " + IntOutput);
	
	//-- Iterate the list
	for (i=0; i<list.length; i++) {
		//-- If the item is a directory, list the contents of the directory and pull the first alphanumerically sorted filename
		if(File.isDirectory(inputData + list[i])==1){
			fileList=getFileList(inputData + list[i]);
			fileListFirst=fileList[0];			
			//-- Sort to get alphabetical
			fileList=Array.sort(fileList);
			} //-- close if conditional statement			
		//-- DEBUG only, make sure the path looks good
		//print("Files located in folder: " + inputData + list[i] + fileListFirst);
			
		//-- Open the image located in the folder
		if(endsWith(inputData + list[i] + fileListFirst, ".tif")==true) {
			//-- DEBUG only, make sure the path looks good
			//print("File to be processed: " + input + list[i] + fileListFirst);
			open(inputData + list[i] + fileListFirst);
			title=getTitle();
			//-- DEBUG only, make sure the file name looks good
			//print("File name: " + title);
			titleOut = File.nameWithoutExtension(); 
			ROITitle = titleOut + "-1_Simple Segmentation_ROISet.zip";	
			if(File.exists(inputROI + ROITitle)){
			//-- DEBUG only, make sure the path looks good
			//print("File " + inputROI + ROITitle + " exists in ROI directory");	
			ResultsTitle = titleOut + "_ROIIntensities.csv";
			//-- DEBUG only, make sure the Output file name looks good
			//print("results title: " + ResultsTitle);			
			roiManager("Open", inputROI + ROITitle);
			roiManager("Multi Measure");
			//-- Save the results as a csv file
			saveAs("Results", IntOutput + ResultsTitle);
			roiManager("deselect"); 
			roiManager("delete");
			}

			//-- Close windows
			close("ROI Manager");
			close("Results");
		}
} //-- folder loop

} //-- close function

print("------------- Finished measuring the minimum, maximum and median intensities of the generated regions of interest for each channel. -------------");
print("All done");

