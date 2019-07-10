# Automate extraction of first channel from MicroManager multichannel datasets and generation of regions of interest from Ilastik-generated segmentation masks followed by intensity measurement

1. Use Fiji script to generate DIC images from OME.tif stacks
   *  Micromanager saves individual data sets in individual folders which is convenient for multidimensional data like time series but not so convenient for individual still images.
   * The script extracts the first image of the stack with the same file name as the original file. The script assumes that the first image in the stack is the DIC channel.
   * The script iterates through all the folders within the original experimental data folder. None of them should be empty folders. If one of the daughter folders contains further folders, the respective daughter folder has to be processed individually. 
   * Script: `IterateFoldersExtractDICChannel.ijm`
2. Segment DIC images using Ilastik - exported as floating 32-bit tiff files. 
3. Generate regions of interest from Ilastik segmentation masks  
   * Mask covering each region of interest identified as the cells of interest plus one region of interest which is the whole field of view minus cell body regions of interest.
4. Measure minimum, maximum and median intensity of all channels for each region of interest and save data as a “.csv” file.
   * Steps 3 and 4 are both covered in the script: `ConvertSegmentationMaskToRoiSet.ijm`
   * The last region of interest is the "all but the cell bodies" region of interest and is created to serve as a measure for the image background. 
  
## License
This code is licensed under the GNU General Public License Version 3.

For more information contact m.held@liverpool.ac.uk.
