// Paul Zaslansky (Charite, Berlin), Sep 2019, micro XRF maps from .mca folders
// V2.1
default_element=1710 //Select freely. 
print("\\Clear");
print("ImageJ/Fiji macro creates 2D images from chosen peaks of xrf - mca - spectra from MySpot");
print("Convert XRF point-scans into 2D images. Designed for 2D or diffTomo maps/sinograms"); 
print("");

InpDir=getDirectory("Choose the input directory (XRF .mca spectra folder), make sure to include only one scan (program fails on multiples)");

print(" --> Reading files from: ["+InpDir+"], \n ..... for large folders this can take a few moments...");
Wtitle = "[One moment please]";
  run("Text Window...", "name="+ Wtitle +" width=47 height=3.5 monospaced");
  setLocation(1,2);
  print(Wtitle,"Reading....");
fiofils = getFileList(InpDir);
print(Wtitle," sorting...");
fiofiles=Array.sort(fiofils);
print(Wtitle, "\\Close");

NfioFiles=fiofiles.length;
print(" --> Found - "+fiofiles.length+" - files.");

Dialog.create("2D image from ["+InpDir+"]");
Dialog.addMessage("Found "+NfioFiles+" files. These will be split into rows and columns. "); 
Dialog.addNumber("Please enter the number of columns that the data has (number of horizontal motor points):",1);
Dialog.addNumber("First channel to extract [min=1 max=4096]?",default_element);
//Dialog.addToSameRow();
Dialog.addNumber("Number of channels to sum-up [min=1 max=(4096-first channel)]?",40);
setLocation(1,2);
Dialog.show();
img_w=Dialog.getNumber();
fioChan=Dialog.getNumber(); // Start channel variable
fioNs=Dialog.getNumber();   // number of consecutive channels to sum up

img_h=NfioFiles/img_w;
print(" --> Creating image sized: "+img_w+" X "+img_h+" pixels, ("+NfioFiles+" vs "+img_h*img_w+ " datapoints)");

if ((img_h*img_w)!=NfioFiles) getBoolean("Oh oh: size of image and number of .mca files do not match. Ensure only one scan in folder. Continue?");

print(" ---> First file found= "+ fiofiles[0]);
//fioRoot=substring(fiofiles[0],0,lengthOf(fiofiles[0])-9);
fioRoot=File.getNameWithoutExtension(fiofiles[0]);
name_for_img="ch_"+fioChan+"_"+fioNs+"_"+fioRoot;
print(" ---> Creating image out of channel {"+fioChan+"}, summing up {"+fioNs+"} consecutive channels:");
newImage(name_for_img, "32-bit black", img_w, img_h, 1); 
JB1=getImageID();

fioI=0; // this is the file number/identifier in the folder. In BESSY scans this starts with 0

print (" ---> Creating image...");
title = "[Progress]";
  run("Text Window...", "name="+ title +" width=47 height=3.5 monospaced");
  setLocation(2,5);

  TimeLeft=0;
  tic=getTime();
  upda=1;     //Screen update interval, e.g. update initialize with 1 but update every 10 points...
setBatchMode("hide");
	for (h=0; h<img_h;h++){
//		print("Now on line "+h+ " of a total of "+img_h+" lines.");
		for(w=0; w<img_w; w++){
			tic=getTime(); 
//			cur_name=fioRoot+IJ.pad(fioI,5)+".mca";
			indx = (h*img_w) + w;
			cur_name = fiofiles[indx];
			curfiofile=File.openAsString(InpDir+cur_name);
			splitHDR=split(curfiofile,"(@A)");
			fioSpectra=split(splitHDR[1], " \\\n");
			SpecificChanToRead=fioChan-1; fioSumChan=0.0;
			for (i=0; i<fioNs;i++)
			{
				fioSumChan=fioSumChan+parseFloat(fioSpectra[SpecificChanToRead]);
				SpecificChanToRead++;
			}
//			if (w<0) {
//
//				print("Integrated sum="+fioSumChan+", SpecificChanToRead="+SpecificChanToRead+",fioSpectra[SpecificChanToRead]="+fioSpectra[SpecificChanToRead] );
//				Chan1stNum=split(fioSpectra[SpecificChanToRead]," ");
//				print("Chan1stNum.length="+Chan1stNum.length+", Chan1stNum[0]="+Chan1stNum[0]+", parseFloat(Chan1stNum[0])="+parseFloat(Chan1stNum[0]));
//				}
//			selectWindow(name_for_img);
			selectImage(JB1);
			setPixel(w,h,fioSumChan);			fioI++;
			
//Progress window
			toc=getTime();
			if (fioI>1) {
				upda--;
				if (upda==0) {
					TimeLeft=(toc-tic)*((1+NfioFiles-fioI)/(1000*60));
					print(title, "\\Update:"+fioI+1+"/"+NfioFiles+" ("+((fioI+1)*100)/NfioFiles+"%)\nRemaining time (min) --> "+TimeLeft+" ");
					upda=10;
				}
     //wait(200);
				}
			else {
				print(title, "\\Update:"+fioI+1+"/"+NfioFiles+" ("+((fioI+1)*100)/NfioFiles+"%)\n");
     //wait(200);
				}			
			}
		setBatchMode("show"); // Update the image at the end of each row
		}
			
	setBatchMode("exit and display");
	print(title, "\\Close");
	selectImage(JB1);
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("In [+]");
	run("Select All");
	run("Enhance Contrast", "saturated=0.35");
print(" ---> This program needed "+(toc-tic)*NfioFiles/60000+" min to process this data.");
print("Macro ended normally. Ciao.");
