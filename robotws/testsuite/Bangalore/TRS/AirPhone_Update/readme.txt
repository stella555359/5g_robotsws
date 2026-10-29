"Automation of Airphone Software Upgrade for APoABIL and APoABIO"

Preconditions:
1. Airphone IP (192.168.200.129) should be reachable for VM.
2. gNB IP (192.168.255.129) should be reachable from VM.
3. YAFT should be present in /home/ute/ Directory.
4. VM should have space to Download Airphone Software and Required Files.


Procedure:
1. Usage of "airphone_update.py"
   --smod (Mention gNB SMOD) [Mandatory]
   --bbmod (Mention BBMOD for gNB SMOD) [Mandatory] (No need to mention for ASOE SMOD)
   --build_version (Mention gNB build Version ex.SBTS00, SBTS22R4) [Mandatory]
   --ap_version (Mention Airphone Software Version) [Mandatory]
   --cell (Mention Cell Type - FDD/TDD) [Mandatory]
   --deployment (Mention Cell Deployment Type - NSA/SANSA) [Mandatory]
   --configuration (Mention gNB Configuration - FS/L1b.) [Mandatory]
   --port (Mention Port - SEI/EIF/SEI1/SEI2) [Optional] (for ASIK gNB -> EIF is default Port, for ASIL gNB -> SEI1 is default port)
   --ncell (Number of cells - 1cell/2cell) [Optional] (Defualt is 1cell)
   --ap_unit (Mention Airphone Unit - ASIK or ASIL) [Optional] (Defualt is ASIK)
   
2. Usage of "airphone_update_ap.py"   
   --smod (Mention gNB SMOD) [Mandatory]
   --bbmod (Mention BBMOD for gNB SMOD) [Mandatory] (No need to mention for ASOE SMOD)
   --build_version (Mention gNB build Version ex.SBTS00, SBTS22R4) [Mandatory]
   --ap_version (Mention Airphone Software Version) [Mandatory]
   --cell (Mention Cell Type - FDD/TDD) [Mandatory]
   --deployment (Mention Cell Deployment Type - NSA/SANSA) [Mandatory]
   --configuration (Mention gNB Configuration - FS/L1b.) [Mandatory]
   --port (Mention Port - SEI/EIF/SEI1/SEI2) [Optional] (for ASIK gNB -> EIF is default Port, for ASIL gNB -> SEI1 is default port)
   --ncell (Number of cells - 1cell/2cell) [Optional] (Defualt is 1cell)
   --ap_unit (Mention Airphone Unit - ASIK or ASIL) [Optional] (Defualt is ASIK)

3. Usage of "airphone_update_gnb.py"
   --smod (Mention gNB SMOD) [Mandatory]
   --bbmod (Mention BBMOD for gNB SMOD) [Mandatory] (No need to mention for ASOE SMOD)
   --build_version (Mention gNB build Version ex.SBTS00, SBTS22R4) [Mandatory]
   --ap_version (Mention Airphone Software Version) [Mandatory]
   --cell (Mention Cell Type - FDD/TDD) [Mandatory]
   --deployment (Mention Cell Deployment Type - NSA/SANSA) [Mandatory]
   --configuration (Mention gNB Configuration - FS/L1b.) [Mandatory]
   --port (Mention Port - SEI/EIF/SEI1/SEI2) [Optional] (for ASIK gNB -> EIF is default Port, for ASIL gNB -> SEI1 is default port)
   --ncell (Number of cells - 1cell/2cell) [Optional] (Defualt is 1cell)
   --ap_unit (Mention Airphone Unit - ASIK or ASIL) [Optional] (Defualt is ASIK)
   
   
Examples:
1. If gNB is ASIK+ABIL and AP is ASIK+ABIL with SEI Port (FDD 1cell Configuration)
    python airphone_update.py --smod ASIK --bbmod ABIL --build_version SBTS00 --ap_version 4.0.23093 --cell FDD --deployment SANSA --configuration FS --port SEI

2. If gNB is ASOE and AP is ASIK+ABIL (FDD 2cell Configuration)
    python airphone_update.py --smod ASOE --build_version SBTS00 --ap_version 4.0.23093 --cell FDD --deployment SANSA --configuration FS --ncell 2cell
	
3. If gNB is ASIB+ABIL and AP is ASIK+ABIL (FDD 1cell Configuration)
	python airphone_update.py --smod ASIB --bbmod ABIL --build_version SBTS00 --ap_version 4.0.23093 --cell FDD --deployment SANSA --configuration FS 
	
4. If gNB is ASIL+ABIO and AP is ASIK+ABIL with SEI2 Port (FDD 1cell Configuration)
	python airphone_update.py --smod ASIL --bbmod ABIO --build_version SBTS00 --ap_version 4.0.23093 --cell FDD --deployment SANSA --configuration FS --port SEI2
	
5. If gNB is ASIM+ABIO and AP is ASIK+ABIL  (FDD 2cell Configuration)
	python airphone_update.py --smod ASIM --bbmod ABIO --build_version SBTS00 --ap_version 4.0.23093 --cell FDD --deployment SANSA --configuration FS --ncell 2cell
	
6. If gNB is ASOE and AP is ASIL+ABIO (TDD 2cell Configuration)
    python airphone_update.py --smod ASOE --build_version SBTS00 --ap_version 4.0.23093 --cell TDD --deployment SANSA --configuration FS --ncell 2cell --ap_unit ASIL
	
7. If gNB is ASIB+ABIO and AP is ASIL+ABIO (TDD 1cell Configuration)
	python airphone_update.py --smod ASIL --bbmod ABIO --build_version SBTS00 --ap_version 4.0.23093 --cell TDD --deployment SANSA --configuration FS --ap_unit ASIL
	
8. If gNB is ASIL+ABIO and AP is ASIL+ABIO (FDD 2cell Configuration)
	python airphone_update.py --smod ASIL --bbmod ABIO --build_version SBTS00 --ap_version 4.0.23093 --cell FDD --deployment SANSA --configuration FS --ap_unit ASIL --ncell 2cell
	
9. If gNB is ASIM+ABIO and AP is ASIL+ABIO  (TDD 2cell Configuration)
	python airphone_update.py --smod ASIM --bbmod ABIO --build_version SBTS00 --ap_version 4.0.23093 --cell TDD --deployment SANSA --configuration FS --ap_unit ASIL --ncell 2cell
	
10. If gNB is ASIM+ABIP and AP is ASIK+ABIL  (FDD 1cell Configuration)
	 python airphone_update.py --smod ASIM --bbmod ABIP --build_version SBTS00 --ap_version 4.0.23093 --cell FDD --deployment SANSA --configuration FS 	
	 

11. For Full Rack Setup -> 	 If gNB is ASIB+ABIL and AP is ASIK+ABIL (FDD 1cell Configuration)
    For gNB Update : python airphone_update_gnb.py --smod ASIB --bbmod ABIL --build_version SBTS00 --ap_version 4.0.23093 --cell FDD --deployment SANSA --configuration FS
	For AP Update : python airphone_update_ap.py --smod ASIB --bbmod ABIL --build_version SBTS00 --ap_version 4.0.23093 --cell FDD --deployment SANSA --configuration FS
	
12. For Full Rack Setup -> 	 If gNB is ASIL+ABIL and AP is ASIK+ABIL (FDD 1cell Configuration)
    For gNB Update : python airphone_update_gnb.py --smod ASIL --bbmod ABIL --build_version SBTS00 --ap_version 4.0.23093 --cell FDD --deployment SANSA --configuration FS
	For AP Update : python airphone_update_ap.py --smod ASIL --bbmod ABIL --build_version SBTS00 --ap_version 4.0.23093 --cell FDD --deployment SANSA --configuration FS	