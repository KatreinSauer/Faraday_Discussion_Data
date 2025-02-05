//macro "XRFp03_read [L]" {
// V1.2
print("\\Clear");

print("ImageJ/Fiji macro to create line plots of .mca XRF files and integrates intensity into spectra (channels) in a folder. KS, PZ, Charite, 2019");
print("");
XRDchannels=2048;// change this to match the number of channels to plot.

InpDir=getDirectory("Choose the input XRF directory (.mca containing folder)");

print(" --> Reading files from: ["+InpDir+"], \n ..... for large folders this can take a few moments...");
fiofils = getFileList(InpDir);
fiofiles=Array.sort(fiofils);

NfioFiles=fiofiles.length;

print(" --> Creating image sized: "+NfioFiles+" X "+XRDchannels+" pixels");
print(" ---> First file found= "+ fiofiles[0]);
print(" ----> A total of "+lengthOf(fiofiles)+" files.");

fioRoot=File.getNameWithoutExtension(fiofiles[0]);
print(" --> Creating image out of all XRF counts {1-"+XRDchannels+"}");
newImage(fioRoot, "32-bit black", NfioFiles, XRDchannels, 1); 


fioI=0; // this is the file number/identifier in the folder. 

setBatchMode("hide");
	for (h=0; h<NfioFiles;h++){
		cur_name=fiofiles[h];
//		cur_name=fioRoot+IJ.pad(fioI,5)+".mca";
		curfiofile=File.openAsString(InpDir+cur_name);
		splitHDR=split(curfiofile,"(@A)");
		fioSpectra=split(splitHDR[1], " \\\n");
		for (i=0; i<XRDchannels;i++)
		{
			fioChanVal=parseFloat(fioSpectra[i]);
			selectWindow(fioRoot);
			setPixel(h,i,fioChanVal);
		}
		fioI++;
			
		setBatchMode("show"); // Update the image at the end of each row
		}
			
	setBatchMode("exit and display");
	selectWindow(fioRoot);

run("Invert LUT");
run("Fire");
run("Enhance Contrast", "saturated=10");
run("Select All");
setKeyDown("alt"); run("Plot Profile");

print(" ---> Last loaded file= ["+ cur_name+"]. Done.");

