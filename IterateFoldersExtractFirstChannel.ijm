// ImageJ macro to extract the first channel from ome.tiff files generated with micromanager
// Saves files in another directory
// Requires that ONLY folders containing ome.tif files be present in the source directory, no empty folders, no mdb files &c.
// The output directory should not be created in the input directory, thus creating an initially empty folder. 
//
//												- Written by Marie Held [mheldb@liv.ac.uk] July 2019
// 												  Liverpool CCI [http://cci.liv.ac.uk]

// Erase all entries in Log window
print("\\Clear");

// Ask user for the input and output directories
input = getDirectory("Source directory");
//-- DEBUG only, make sure the path looks good
//print("Source directory: " + input);
output = getDirectory("Destination directory");
//-- DEBUG only, make sure the path looks good
//print("Destination directory of ROI sets: " + output);

// run script without diplaying the images during macro excecution
setBatchMode(true);

processFolder(input);

function processFolder(input) {
	//-- get a list of files and folders in the input
	list = getFileList(input);
	print("... Working on it ...");
	//-- DEBUG only, print the list to see what we have
	//print("Folders located in input folder:")
	//Array.print(list);
	//-- Iterate the list
	for (i=0; i<list.length; i++) {
		//-- If the item is a directory, list the contents of the directory and pull the first alphanumerically sorted filename
		if(File.isDirectory(input + list[i])==1);{
			fileList=getFileList(input + list[i]);
			//-- Sort to get alphabetical
			fileList=Array.sort(fileList);
			fileListFirst=fileList[0];
			}
			//-- DEBUG only, make sure the path looks good
			//print("Files located in folder: " + input + list[i] + fileListFirst);
		//-- Open the image located in the folder
		if(endsWith(input + list[i] + fileListFirst, ".tif")==true) {
			open(input + list[i] + fileListFirst);
			run("Duplicate...", " ");
			//-- Save the first channel image as a tif file
			title=getTitle();
			selectWindow(title);
			saveAs("Tiff", output + title);
			//-- Close the files
			close("*");
		}
		else{ i = i + 1;}
} //-- folder loop

} //-- close function

print("------------- Finished extracting the first channel from each folder located in the input folder. -------------")

