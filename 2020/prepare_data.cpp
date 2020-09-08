#include<iostream>
#include<string>
#include<vector>
#include<array>
#include<memory>
#include<fstream>
#include<sys/types.h>
#include<sys/stat.h>

//---ARGS--
std::string  startDate; //Date & Time,format:"YYYYMMDDHH" ie:2020013000
int maxTime; //Hours to predict, ie:24
std::string resolution; //Resolution= 0p25 || 0p50 || 1p00

//---FOLDERS--
std::string dataFolder;
std::string toolsDirectory;
std::string scriptFolder;
std::string sstFolder;
std::string dpsDirectory;
std::string surfacedataFolder;
std::string soilMostureFolder;
std::string ndviMODISFolder;
std::string topographyFolder;
std::string glfaoinpeFolder;
std::string glogeinpeFolder;

//--VALUES--
int intervalHour;
std::string gfsFilePattern;
std::string gfsSourceDataAddress;
std::string cptecSourceDataAddress;
int DP_FILE_DEFAULT_SIZE;

//--VARNAMES--
std::string uComponentOfWind;
std::string vComponentOfWind;
std::string temperature;
std::string geopotentialHeight;
std::string relativeHumidity;

// Workspace
std::string workspace;

// Tools
std::string aria2;
std::string grib2;
std::string g2ctl;
std::string gribmap;
std::string grads;
std::string geraDP;
std::string curl;

std::vector<std::string> dpFilenames;
int sizeDPFilenames;

//--FLAG--
bool flag_dp_exists=0;

// Variables of GetInitialData method
std::string uComponentOfWindVarName;
std::string vComponentOfWindVarName;
std::string temperatureVarName;
std::string geopotentialHeightVarName;
std::string relativeHumidityVarName;

std::string nX;
std::string loni;
std::string intX;
std::string nY;
std::string lati;
std::string intY;
std::string nlev;
std::string nt;
std::string indef;
std::string linearY;
std::string linearX;

std::string zmax;
std::string lat2i;
std::string lat2f;
std::string lon2i;
std::string lon2f;
std::string to_f90;
std::string wind_u_z_limit;
std::string wind_u_default_value;
std::string wind_v_z_limit;
std::string wind_v_default_value;
std::string temp_z_limit;
std::string temp_default_value;
std::string geo_z_limit;
std::string geo_default_value;
std::string ur_z_limit;
std::string ur_default_value;

void setFolderVariables(){
	workspace = "/home/galvitez/brams_workspace";
	toolsDirectory=workspace+"/tools";
	scriptFolder=workspace+"/scripts";
	dataFolder= workspace + "/data";
	sstFolder=dataFolder+"/datain/SST";
	dpsDirectory=dataFolder+"/datain/dp-files/"+startDate;
	surfacedataFolder = dataFolder+"/shared_datain/SURFACE_DATA";
	soilMostureFolder=dataFolder+"/datain/UMIDADE/"+startDate;
	ndviMODISFolder=dataFolder+"/shared_datain/SURFACE_DATA/NDVI-MODIS_vfm";
	topographyFolder=dataFolder+"/shared_datain/SURFACE_DATA/topo1km";
	glfaoinpeFolder=dataFolder+"/shared_datain/SURFACE_DATA/GL_FAO_INPE";
	glogeinpeFolder=dataFolder+"/shared_datain/SURFACE_DATA/GL_OGE_INPE";

	//tools
	aria2 = toolsDirectory+ "/aria2/aria2c";
	grib2= toolsDirectory+ "/grib2/wgrib2/wgrib2";
	g2ctl= toolsDirectory+ "/g2ctl";
	gribmap= toolsDirectory+ "/grads/bin/gribmap";
	grads = toolsDirectory+ "/grads/bin/grads";
	geraDP = toolsDirectory+ "/geraDP";
	curl = toolsDirectory+ "/curl/bin/curl";

}

void setValuesVariables(){
	intervalHour=6;
	gfsFilePattern="gfs.t00z.pgrb2."+resolution+".f";
	gfsSourceDataAddress="ncep.noaa.gov/pub/data/nccf/com/gfs/prod";
	cptecSourceDataAddress="ftp://ftp1.cptec.inpe.br/brams/data-brams";
	DP_FILE_DEFAULT_SIZE=177402422;
}

void  setVarNamesVariables(){
	uComponentOfWind="U-Component of Wind";
	vComponentOfWind="V-Component of Wind";
	temperature="Temperature";
	geopotentialHeight="Geopotential Height";
	relativeHumidity="Relative Humidity";
}

// reference [https://stackoverflow.com/questions/478898/how-do-i-execute-a-command-and-get-the-output-of-the-command-within-c-using-po]
std::string exec(const char* cmd) {
	std::array<char, 128> buffer;
	std::string result;
	std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd, "r"), pclose);
	if (!pipe){
		throw std::runtime_error("popen() failed!");
	}
	while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
		result += buffer.data();
	}
	result = result.substr(0,result.size()-1);
	return result;
}

// Step 1 
void getDPFilenamesByStartDateAndMaxTime(){
	std::cout<<"Generating  DP Filenames starting from "<<startDate<<" taking "<<maxTime<<" Hours...\n";
	std::string date,hour;
	date=startDate.substr(0,8);
	hour=startDate.substr(8,2);
	int i;
	dpFilenames.resize(maxTime/intervalHour);
	for(i=0;i<(maxTime/intervalHour);i++){
		std::string time;
		time="date +%Y-%m-%d-%H00 -d \""+hour+":00:00 "+date+" $(( ";
		std::string period;
		period=std::to_string(intervalHour*i);
		time+=period+" )) hours\"";
		dpFilenames[i]="dp"+exec(time.c_str());
	}
	sizeDPFilenames=maxTime/intervalHour;
}

void checkIfDPFilesExistsAndAreCorrect(){
	std::cout<<"Checking if DP Files've been already created ...\n";
	FILE *f;
	for(int i=0;i<sizeDPFilenames;i++){
		std::string tmp;
		tmp=dpsDirectory+"/"+dpFilenames[i];
		f=fopen(tmp.c_str(),"r");
		if(!f){
			std::cout<<"DP File is not found: "<<tmp<<"\n";
			flag_dp_exists=1;
			continue;
		}
		fclose(f);
	}
}

void downloadGFSFiles(){
	std::cout<<"Downloading GFSFiles\n";

	std::string webAddres;
	webAddres=gfsSourceDataAddress+"/gfs.";

	std::string tmp;
	tmp="mkdir -p "+dpsDirectory;
	system(tmp.c_str());

	std::string cmdfinal="";
	for(int i=0;i<maxTime;i+=intervalHour){
		std::string hourPad;
		if(i<10){
			hourPad="00";
		}
		else if(i<100){
			hourPad="0";
		} 
		hourPad+=std::to_string(i);
		std::string gfsFile;
		gfsFile=gfsFilePattern+hourPad;
		std::string cmd;
		cmd=grib2+" -v "+dpsDirectory+"/"+gfsFile+" 2>&1 | grep ERROR | wc -l";
		std::string ans=exec(cmd.c_str());
		if(ans[0]=='0'){
			std::cout<<gfsFile<<" exists...\n";
		}
		else{
			//Detele corrupted files
			std::string delete_file="rm "+dpsDirectory+"/"+gfsFile;
			int delete_file_status=system(delete_file.c_str());
			std::cout<<gfsFile<<" does not exists...\n";
			std::cout<<"Downloading "<<gfsFile<<" \n";
			// Why 00 for default
			std::string url=webAddres+startDate.substr(0,8)+"/00/"+gfsFile;
			std::string https_protocol="wget -P "+dpsDirectory+" https://nomads."+url;
			std::string ftp_protocol="wget -P "+dpsDirectory+" ftp://ftp."+url;
			/*
			std::string https_protocol=curl+" -Z --parallel  https://nomads."+url+ " --output "+dpsDirectory+"/"+gfsFile;
			std::string ftp_protocol=curl+" -Z  --parallel  ftp://ftp."+url+" --output "+dpsDirectory+"/"+gfsFile;
			if(cmdfinal=="")
				cmdfinal=https_protocol;
			else
				cmdfinal=cmdfinal+" & "+https_protocol;
			cmdfinal=cmdfinal+" & "+ftp_protocol;
			*/
			int status1=system(https_protocol.c_str());
			int status2=system(ftp_protocol.c_str());
		}
	}
	//system(cmdfinal.c_str());

}

void verifyDownloadedGFSFiles(){
	std::cout<<"Verifying each GFS File\n";
/*
  for gfsFilename in $(ls -A1 $dpsDirectory | grep -e "$gfsFilePattern" )
    do
        if [ 0$(wgrib2 -match "UGRD|VGRD|TMP|HGT|RH" -match " mb:|:surface:" $dpsDirectory/$gfsFilename | wc -l ) -ge 0157 ];then
            echo "$gfsFilename OK ..."
        else
            echo "$gfsFilename Incomplete ..."
        fi
    done
*/
	
}

void getConversionParams(){
	std::string cmd = "cp "+scriptFolder+"/conversion_params.ini "+dpsDirectory;
	system(cmd.c_str());
	std::string pathFile = dpsDirectory+"/conversion_params.ini";
	std::ifstream f(pathFile);
	std::string line;
	std::string delimiter = "=";
	size_t pos;
	while(getline(f,line)){
		if((pos = line.find(delimiter)) != std::string::npos){
			std::string pre = line.substr(0,pos);
			std::string post = line.substr(pos+1,line.size());
			if(pre == "z_max_level"){
				zmax = post;
			}
			else if(pre == "initial_latitude"){
				lat2i = post;
			}
			else if(pre == "final_latitude"){
				lat2f = post;
			}
			else if(pre == "initial_longitude"){
				lon2i = post;
			}
			else if(pre == "final_longitude"){
				lon2f = post;
			}
			else if(pre == "binary_grads_exists"){
				to_f90 = post;
			}
			else if(pre == "wind_u_z_limit"){
				wind_u_z_limit = post;
			}
			else if(pre == "wind_u_default_value"){
				wind_u_default_value = post;
			}
			else if(pre == "wind_v_z_limit"){
				wind_v_z_limit = post;
			}
			else if(pre == "wind_v_default_value"){
				wind_v_default_value = post;
			}
			else if(pre == "temp_z_limit"){
				temp_z_limit = post;
			}
			else if(pre == "temp_default_value"){
				temp_default_value = post;
			}
			else if(pre == "geo_z_limit"){
				geo_z_limit = post;
			}
			else if(pre == "geo_default_value"){
				geo_default_value = post;
			}
			else if(pre == "ur_z_limit"){
				ur_z_limit = post;
			}
			else if(pre == "ur_default_value"){
				ur_default_value = post;
			}
		}
	}
	
}

void getInitialData(){
	std::string tmp;
	tmp="grep \") "+uComponentOfWind+"\" "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $1}'";
	uComponentOfWindVarName=exec(tmp.c_str());
	tmp="grep \") "+vComponentOfWind+"\" "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $1}'";
	vComponentOfWindVarName=exec(tmp.c_str());
	tmp="grep \") "+temperature+"\" "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $1}'";
	temperatureVarName=exec(tmp.c_str());
	tmp="grep \") "+geopotentialHeight+"\" "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $1}'";
	geopotentialHeightVarName=exec(tmp.c_str());
	tmp="grep \") "+relativeHumidity+"\" "+dpsDirectory+"/gfs"+startDate+".ctl | grep -v -e layer | awk '{print $1}'";
	relativeHumidityVarName=exec(tmp.c_str());
	
	std::cout<<"\n Variables' names\n\n";

	std::cout<<uComponentOfWind<<" [m/s]: "<<uComponentOfWindVarName<<std::endl;
	std::cout<<vComponentOfWind<<" [m/s]: "<<vComponentOfWindVarName<<std::endl;
	std::cout<<temperature<<" [K]: "<<temperatureVarName<<std::endl;
	std::cout<<geopotentialHeight<<" [gpm]: "<<geopotentialHeightVarName<<std::endl;
	std::cout<<relativeHumidity<<" [%]: "<<relativeHumidityVarName<<std::endl;

	tmp = "grep -i xdef "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $2}'";
	nX=exec(tmp.c_str());
	tmp = "grep -i xdef "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $4}'";
	loni=exec(tmp.c_str());
    	tmp = "grep -i xdef "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $5}'";
    	intX=exec(tmp.c_str());
    	tmp= "grep -i ydef "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $2}'";
    	nY=exec(tmp.c_str());
    	tmp = "grep -i ydef "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $4}'";
    	lati= exec(tmp.c_str());
    	tmp = "grep -i ydef "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $5}'";
    	intY= exec(tmp.c_str());
    	tmp = "grep -i zdef "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $2}'";
    	nlev= exec(tmp.c_str());
    	tmp = "grep -i tdef "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $2}'";
    	nt= exec(tmp.c_str());
    	tmp = "grep -i UNDEF "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print $2}'";
    	indef= exec(tmp.c_str());
    	tmp = "grep -i ydef "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print substr($3,2,1)}'";
    	linearY= exec(tmp.c_str());
    	tmp = "grep -i xdef "+dpsDirectory+"/gfs"+startDate+".ctl | awk '{print substr($3,2,1)}'";
    	linearX= exec(tmp.c_str());

	getConversionParams();
	
}

void convertGFSFilesToBin(){
	std::cout<<"Generating CTL File and Mapping GFS Files\n";
	FILE *f;
	std::string tmp = dpsDirectory+"/gfs"+startDate+".ctl";
	f=fopen(tmp.c_str(),"r");
	if(!f){
		std::cout<<"DP File is not found: "<<tmp<<"\n";
		std::string cmd = g2ctl+" " +dpsDirectory+"/"+gfsFilePattern+"\%f3 > "+dpsDirectory+"/gfs"+startDate+".ctl";
		int status1=system(cmd.c_str());
	}
	else{
		std::cout<<"\n CTL File've already been generated\n";
	}
	fclose(f);

	tmp = dpsDirectory+"/"+gfsFilePattern+"000.idx";
	f=fopen(tmp.c_str(),"r");
	if(!f){
		std::cout<<"IDX File is not found: "<<tmp<<"\n";
		std::string cmd = gribmap+" -i " +dpsDirectory+"/gfs"+startDate+".ctl";
		int status1=system(cmd.c_str());
	}
	else{
	}
		std::cout<<"\n IDX File've already been generated\n";
	fclose(f);

	getInitialData();

	if( linearY == "e" || linearY == "E" || linearX == "e" || linearX == "E" ){
		std::cout<<"\n\nX or Y spacing is not linear, use a type of regrid to convert the grid to linear.Quiting...\n\n";
		return;
	} 

	/*
	tmp = dpsDirectory+"/dims.txt";
	
	f=fopen(tmp.c_str(),"r");
	bool faro=false;
	if(f){
		faro=true;
	}
	fclose(f);
	if(faro){
		std::string cmd = "rm -f "+dpsDirectory+"/dims.txt";
		system(cmd.c_str());
	}
	*/
	
	std::string ctlValues=nX+" "+loni+" "+intX+" "+nY+" "+lati+" "+intY+" "+nlev+" "+nt+" "+indef+" "+linearY;
	std::cout<<ctlValues<<std::endl;
    	std::string varNames=uComponentOfWindVarName+" "+vComponentOfWindVarName+" "+temperatureVarName+" "+geopotentialHeightVarName+" "+relativeHumidityVarName;
    	std::string iniValues=zmax+" "+lat2i+" "+lat2f+" "+lon2i+" "+lon2f+" "+wind_u_z_limit+" "+wind_u_default_value+" "+wind_v_z_limit+" "+wind_v_default_value+" "+temp_z_limit+" "+temp_default_value+" "+geo_z_limit+" "+geo_default_value+" "+ur_z_limit+" "+ur_default_value;
    	std::string cmd = grads+" -bcpx  \"run "+geraDP+"/geraBIN.gs "+dpsDirectory+"/gfs"+startDate+".ctl "+ctlValues+" "+to_f90+" ctl "+ varNames+" "+iniValues+"\"";
	
	//Falta ejecutar este comando
	//system(cmd.c_str());
    //cd $dataFolder
	
}

void generateDPFilesFromBin(){
	std::cout<<"Generating DP Files...\n";
	std::string cmd = "ls -l "+dpsDirectory+"/to_dp.gra | awk '{print $5}'";
	std::string binaryFileSize = exec(cmd.c_str());
	std::cout<<binaryFileSize<<std::endl;
	cmd = geraDP+"/geraDP.x "+dpsDirectory+"/to_dp.gra "+binaryFileSize+"  "+dpsDirectory+"/";
}

void getSSTFiles(){
	std::cout<<"\n Checking if "<<startDate<<" folder exists\n";
	struct stat st;
	std::string cmd;
	std::string path = sstFolder;
	if(stat(path.c_str(),&st)!=0){
		cmd = "mkdir "+sstFolder;
		system(cmd.c_str());
	}

	std::string year =startDate.substr(0,4); 
	path = sstFolder+"/"+year;
	if(stat(path.c_str(),&st)!=0){
		std::cout<<"SST for "+year+" doesn't exist... Downloading new files \n";
		cmd = "mkdir "+sstFolder+"/"+year;
		system(cmd.c_str());
		cmd = "wget -nc -P "+sstFolder+"/"+year+" "+cptecSourceDataAddress+"/week-sst/sst"+year+".tar.gz";
		system(cmd.c_str());
		cmd = "ls "+sstFolder+"/"+year+" | wc -l";
		int year_tmp = stoi(year);
		while(exec(cmd.c_str())=="0"){
			year_tmp--;
			cmd = "wget -nc -P "+sstFolder+"/"+year+" "+cptecSourceDataAddress+"/week-sst/sst"+std::to_string(year_tmp)+".tar.gz";
			system(cmd.c_str());
			cmd = "ls "+sstFolder+"/"+year+" | wc -l";
		}
		cmd = "tar -zxvf "+sstFolder+"/"+year+"/sst"+std::to_string(year_tmp)+".tar.gz -C "+sstFolder+"/"+year;
		system(cmd.c_str());
		cmd = "rm -f "+sstFolder+"/"+year+"/sst"+std::to_string(year_tmp)+".tar.gz";
		system(cmd.c_str());
        	std::cout<<"\nSST Files downloaded successfully...\n";
	}

	//WHEADER File
	path = sstFolder+"/"+year+"/WHEADER";
	if(stat(path.c_str(),&st)!=0){
        	std::cout<<"WHEADER File don't exist... Downloading...\n";
		cmd = "wget -nc -P "+sstFolder+"/"+year+" "+cptecSourceDataAddress+"/week-sst/sst012.tar.gz";
		system(cmd.c_str());
		cmd = "tar -zxvf "+sstFolder+"/"+year+"/sst012.tar.gz -C "+sstFolder+"/"+year;
		system(cmd.c_str());
		cmd = "rm -f "+sstFolder+"/"+year+"/sst012.tar.gz";
		system(cmd.c_str());
		std::cout<<"WHEADER File downloaded successfully...\n";
	}
}

void getSoilMostureFiles(){
	std::cout<<"\n Checking if Soil Mosture file exits...\n";
	struct stat st;
	std::string cmd;
	std::string path;

	path = dataFolder + "/datain/UMIDADE"; 
	if(stat(path.c_str(),&st)!=0){
		cmd = "mkdir "+path;
		system(cmd.c_str());
	}

	path = soilMostureFolder;
	if(stat(path.c_str(),&st)!=0){
		cmd = "mkdir "+path;
		system(cmd.c_str());
	}
	
	std::string startDate_tmp = "2020040500";

	std::string date_tmp = startDate_tmp.substr(0,8);
	path += "/GL_SM.GPNR."+ startDate.substr(0,8)+ "00.vfm"; 
	std::string year = startDate_tmp.substr(0,4);
	if(stat(path.c_str(),&st)!=0){
		std::cout<<"Soil Mosture files don't exist... Downloading new files...\n";
		for( int i = 0 ; i<=12; i+=12 ){
			std::string hour;
			if(i==0){
				hour = "00";
			}
			else{
				hour = "12";
			}
			cmd = "wget -P "+soilMostureFolder+" "+cptecSourceDataAddress+"/soil-moisture/"+year+"/GPNR/GL_SM.GPNR."+date_tmp+hour+".vfm.gz";
			system(cmd.c_str());
			cmd = "gzip -dc < "+soilMostureFolder+"/GL_SM.GPNR."+date_tmp+hour+".vfm.gz > "+soilMostureFolder+"/GL_SM.GPNR."+startDate.substr(0,8)+hour+".vfm";
			system(cmd.c_str());
            		cmd = "rm -f "+soilMostureFolder+"/GL_SM.GPNR."+date_tmp+hour+".vfm.gz";
			system(cmd.c_str());
		}
	}
	else{
		std::cout<<"\nSoil Mosture Files downloaded successfully...\n";
	}
	
}

void getTopographyData(){
	
	std::cout<<"\n Checking if Topography file exits...\n";
	struct stat st;
	std::string cmd;
	std::string path;

	path = dataFolder + "/shared_datain"; 
	if(stat(path.c_str(),&st)!=0){
		cmd = "mkdir "+path;
		system(cmd.c_str());
	}
	path = dataFolder + "/shared_datain/SURFACE_DATA"; 
	if(stat(path.c_str(),&st)!=0){
		cmd = "mkdir "+path;
		system(cmd.c_str());
	}
	path = topographyFolder;
	if(stat(path.c_str(),&st)!=0){
		cmd = "mkdir "+path;
		system(cmd.c_str());
	}

	path = topographyFolder+"/ELHEADER";
	if(stat(path.c_str(),&st)!=0){
		std::cout<<"\n Topography files don't exist... Downloading HEADER...\n";
		cmd = "wget -P "+topographyFolder+" "+cptecSourceDataAddress+"/topo/topo1km.tar.gz";
		system(cmd.c_str());
		cmd = "tar -zxvf "+topographyFolder+"/topo1km.tar.gz -C "+topographyFolder;
		system(cmd.c_str());
        	cmd = "mv "+topographyFolder+"/topo1km/* "+ topographyFolder;
		system(cmd.c_str());
        	cmd = "rm -f "+topographyFolder+"/topo1km.tar.gz";
		system(cmd.c_str());
        	cmd = "rm -r "+topographyFolder+"/topo1km";
        	std::cout<<"\nTopography files downloaded successfully...\n";
	}
	else{
		std::cout<<"\n Topography Files downloaded successfully...\n";
	}

}

void getMODISNDVI(){
	
	std::cout<<"\n Checking if MODIS NDVI header exits...\n";
	struct stat st;
	std::string cmd;
	std::string path;

	path = ndviMODISFolder; 
	if(stat(path.c_str(),&st)!=0){
		cmd = "mkdir "+path;
		system(cmd.c_str());
	}

	path = ndviMODISFolder+"/NHEADER"; 
	if(stat(path.c_str(),&st)!=0){
		std::cout<<"MODIS NDVI HEADER don't exist... Downloading HEADER...";	
		cmd = "wget -P "+ndviMODISFolder+" "+cptecSourceDataAddress+"/ndvi-modis/NHEADER.tar.gz";
		system(cmd.c_str());
		cmd = "tar -zxvf "+ndviMODISFolder+"/NHEADER.tar.gz -C "+ndviMODISFolder;
		system(cmd.c_str());
        	cmd = "rm -f "+ndviMODISFolder+"/NHEADER.tar.gz";
		system(cmd.c_str());
	}
	std::string months[]={"jan","feb", "mar", "apr", "may", "jun", "jul" ,"aug", "sep", "oct", "nov", "dec"};
	
	for(int i=0;i<12;i++){
		path = ndviMODISFolder+"/"+months[i];
		if(stat(path.c_str(),&st)!=0){
			std::cout<<months[i]<<" folder doesn't exist... Downloading ...";	
			cmd = "wget -P "+ndviMODISFolder+" "+cptecSourceDataAddress+"/ndvi-modis/"+months[i]+".tar.gz";
			system(cmd.c_str());
			cmd = "tar -zxvf "+ndviMODISFolder+"/"+months[i]+".tar.gz -C "+ndviMODISFolder;
			system(cmd.c_str());
        		cmd = "rm -f "+ndviMODISFolder+"/"+months[i]+".tar.gz";
			system(cmd.c_str());
			std::cout<<"\n"<<months[i]<<" folder downloaded successfully...\n";
		}
	}

}

void getGLFAOINPE(){

	std::cout<<"\n Checking if GL FAO INPE files exit...\n";
	struct stat st;
	std::string cmd;
	std::string path;

	path = glfaoinpeFolder; 
	if(stat(path.c_str(),&st)!=0){
		std::cout<<"Downloading GLFAO files ...";	
		//cmd = "mkdir "+path;
		//system(cmd.c_str());
		cmd = "wget -P "+glfaoinpeFolder+" "+cptecSourceDataAddress+"/soil-fao/GL_FAO_INPE.tar.gz";
		system(cmd.c_str());
		cmd = "tar -zxvf "+glfaoinpeFolder+"/GL_FAO_INPE.tar.gz -C "+glfaoinpeFolder;
		system(cmd.c_str());
		cmd = "mv "+glfaoinpeFolder+"/soil-fao/* "+glfaoinpeFolder;
		system(cmd.c_str());
		cmd = "rm -rf "+glfaoinpeFolder+"/GL_FAO_INPE.tar.gz";
		system(cmd.c_str());
		cmd = "rm -rf "+glfaoinpeFolder+"/soil-fao";
	}
}

void getGLOGEINPE(){

	std::cout<<"\n Checking if GL OGE INPE files exit...\n";
	struct stat st;
	std::string cmd;
	std::string path;

	path = glogeinpeFolder; 
	if(stat(path.c_str(),&st)!=0){
		std::cout<<"Downloading GLOGEO files ...";	
		//cmd = "mkdir "+path;
		//system(cmd.c_str());
		cmd = "wget -P "+glogeinpeFolder+" "+cptecSourceDataAddress+"/prep-chem/surface_data/GL_OGE_INPE.tar.gz";
		system(cmd.c_str());
		cmd = "tar -zxvf "+glogeinpeFolder+"/GL_OGE_INPE.tar.gz -C "+glogeinpeFolder;
		system(cmd.c_str());
		cmd = "mv "+glogeinpeFolder+"/GL_OGE_INPE/* "+glogeinpeFolder;
		system(cmd.c_str());
		/*
		cmd = "rm -rf "+glfaoinpeFolder+"/GL_FAO_INPE.tar.gz";
		system(cmd.c_str());
		cmd = "rm -rf "+glfaoinpeFolder+"/soil-fao";
		*/
	}
}

void init(){

	//Building environment
	setFolderVariables();
	setValuesVariables();
	setVarNamesVariables();

	//Initial variables and arguments
	getDPFilenamesByStartDateAndMaxTime();

	checkIfDPFilesExistsAndAreCorrect();

	if(flag_dp_exists){
		downloadGFSFiles();
		//verifyDownloadedGFSFiles();
		convertGFSFilesToBin();
		//falta corregir
		//generateDPFilesFromBin();
	}
	else{
		std::cout<<"DP already generated\n";
	}

	getSSTFiles();
	getSoilMostureFiles();
	getTopographyData();
	getMODISNDVI();
	getGLFAOINPE();
	getGLOGEINPE();
	

}

//Example to input ie:./a.out 2020032000 24 0p25
int main(int argc,char *argv[]){

	int status=system("ls -l");
	if(argc==1){
		std::cout<<"Start Date is not fixed\n";
		return 1;
	}

	startDate=argv[1];
	if(argc>2){
		sscanf(argv[2],"%d",&maxTime);
	}
	else{
		maxTime=6;
	}

	if(argc>3){
		resolution=argv[3];
	}
	else{
		resolution="0p25";
	}

	std::cout<<"Defined values:: "<<startDate<<" "<<maxTime<<" "<<resolution<<"\n";

	init();

	return 0;
}

