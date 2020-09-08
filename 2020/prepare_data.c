#include<stdio.h>
#include<stdlib.h>
#include<string.h>
//#include<curl/curl.h>

//---ARGS--
char* startDate; //Date & Time,format:"YYYYMMDDHH" ie:2020013000
int maxTime; //Hours to predict, ie:24
char* resolution; //Resolution= 0p25 || 0p50 || 1p00


//---FOLDERS--
char dataFolder[6];
char toolsDirectory[100];
char scriptFolder[100];
char sstFolder[100];
char dpsDirectory[100];
char soilMostureFolder[100];
char ndviMODISFolder[100];
char topographyFolder[100];

//--VALUES--
int intervalHour;
char gfsFilePattern[100];
char gfsSourceDataAddress[100];
char cptecSourceDataAddress[100];
int DP_FILE_DEFAULT_SIZE;


//--VARNAMES--
char uComponentOfWind[100];
char vComponentOfWind[100];
char temperature[100];
char geopotentialHeight[100];
char relativeHumidity[100];

char* dpFilenames[100];
int sizeDPFilenames;

void setFolderVariables(){


	strcpy(dataFolder,"/data");
	strcpy(toolsDirectory,"/tools");
	strcpy(scriptFolder,"/script");

	strcat(sstFolder,dataFolder);
	strcat(sstFolder,"/datain/SST");

	strcat(dpsDirectory,dataFolder);
	strcat(dpsDirectory,"/datain/dp-files/");
	strcat(dpsDirectory,startDate);

	strcat(soilMostureFolder,dataFolder);
	strcat(soilMostureFolder,"/datain/UMIDADE/");
	strcat(soilMostureFolder,startDate);

	strcat(ndviMODISFolder,dataFolder);
	strcat(ndviMODISFolder,"/shared_datain/SURFACE_DATA/NDVI-MODIS_vfm");

	strcat(topographyFolder,dataFolder);
	strcat(topographyFolder,"/shared_datain/SURFACE_DATA/topo1km");
}
void setValuesVariables(){

	intervalHour=6;

	strcat(gfsSourceDataAddress,"gfs.t00z.pgrb2.");
	strcat(gfsSourceDataAddress,resolution);
	strcat(gfsSourceDataAddress,".f");

	strcat(gfsSourceDataAddress,"ncep.noaa.gov./pub/data/nccf/com/gfs/prof");

	strcat(cptecSourceDataAddress,"ftp://ftp1.cptec.inpe.br/brams/data-brams");

	DP_FILE_DEFAULT_SIZE=177402422;
}

void  setVarNamesVariables(){
	strcpy(uComponentOfWind,"U-Component of Wind");
	strcpy(vComponentOfWind,"V-Component of Wind");
	strcpy(temperature,"Temperature");
	strcpy(geopotentialHeight,"Geopotential Height");
	strcpy(relativeHumidity,"Relative Humidity");
}
void getDPFilenamesByStartDateAndMaxTime(){
	printf("Generating  DP Filenames starting from %s taking %d Hours...\n",startDate,maxTime);
	char date[9],hour[3];
	memset(date,'\0',sizeof date);
	memset(hour,'\0',sizeof hour);
	strncpy(date,startDate,8);
	strncpy(hour,startDate+8,2);
	FILE* f;
	f=fopen("in","w");
	fclose(f);
	for(int i=0;i<(maxTime/intervalHour);i++){
		char time[60];
		strcpy(time,"date +%Y-%m-%d-%H00 -d \"");
		strcat(time,hour);
		strcat(time,":00:00 ");
		strcat(time,date);
		strcat(time," $(( ");
		char period[4];
		snprintf(period, sizeof period, "%d", intervalHour*i);
		strcat(time,period);
		strcat(time," )) hours\"");
		strcat(time," | cat >> in ");
		int status=system(time);
	}
	char*buff=NULL;
	f=fopen("in","r");
	int i=0;
	size_t len=0;
	while(getline(&buff,&len,f)!=-1){
		dpFilenames[i]=buff;
		i++;
	}

	fclose(f);
	sizeDPFilenames=i;

}
int flag_dp_exists=0;
void checkIfDPFilesExistsAndAreCorrect(){
	printf("Checking if DP Files are already created and have a right size...\n");
	FILE *f;
	for(int i=0;i<sizeDPFilenames;i++){
		char tmp[200];
		strcpy(tmp,dpsDirectory);
		strcat(tmp,"/");
		strcat(tmp,dpFilenames[i]);
		f=fopen(tmp,"r");
		if(!f){
			printf("DP File not founded: %s\n",tmp);
			flag_dp_exists=1;
			continue;
		}
		fclose(f);
	}
}
void downloadGFSFiles(){
	printf("Downloading GFSFiles\n");

	char webAddres[255];
	strcpy(webAddres,gfsSourceDataAddress);
	strcat(webAddres,"/gfs.");

	char tmp[255];
	strcpy(tmp,"mkdir -p ");
	strcat(tmp,dpsDirectory);
	system(tmp);

	for(int i=0;i<maxTime;i+=intervalHour){
		char hourPad[4];
		hourPad[0]=hourPad[1]=hourPad[2]='0';
		char gfsFile[255];
		strcpy(gfsFile,gfsFilePattern);
		strcat(gfsFile,hourPad);
	}

	FILE *fp;
	char path[1022];

/* Open the command for reading. */
	fp = popen("/bin/ls /home/brams-scripts/", "r");
	if (fp == NULL) {
		printf("Failed to run command\n" );
		return;
	}

	/* Read the output a line at a time - output it. */
	while (fgets(path, sizeof(path), fp) != NULL) {
		printf("%s", path);
	}

	/* close */
	pclose(fp);

}
void verifyDownloadedGFSFiles(){
}
void convertGFSFilesToBin(){
}
void init(){

	//Fixing environment
	setFolderVariables();
	setValuesVariables();
	setVarNamesVariables();
	getDPFilenamesByStartDateAndMaxTime();
	checkIfDPFilesExistsAndAreCorrect();

	if(flag_dp_exists){
		downloadGFSFiles();
		verifyDownloadedGFSFiles();
		convertGFSFilesToBin();
	}
	else
		printf("DP already generated\n");

}

//Example to input ie:./a.out 2020032000 24 0p25
int main(int argc,char *argv[]){


	//int status=system("ls -l");
	if(argc==1){
		printf("Start Date is not fixed\n");
		return 1;
	}
	startDate=argv[1];
	if(argc>2)
		sscanf(argv[2],"%d",&maxTime);
	else
		maxTime=6;


	if(argc>3)
		resolution=argv[3];
	else
		resolution="0p25";

	printf("Defined values:: %s %d %s\n",startDate,maxTime,resolution);

	init();


	return 0;
}
