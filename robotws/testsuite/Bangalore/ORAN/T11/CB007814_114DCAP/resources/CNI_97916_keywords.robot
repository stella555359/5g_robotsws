*** Settings ***
Documentation
...							CNI			: 97916
...							Author		: Rakshith B
...							Email Id	: Rakshith.b@nokia.com

Library						String
Library						ute_ue
Library						DateTime
Library						SSHLibrary
Library						Collections
Library						CNI_97916.py
Library						ute_fsmaccess
Library						OperatingSystem
Library						ta5g_pm_counters
Library           			taf.sw.scout   												WITH NAME   scout
Library						taf.sw.dcap.rd	 											WITH NAME	dcap
Library						taf.config.scf	 											WITH NAME	scf
Library						taf.transport.ssh											WITH NAME	ssh
Library						taf.collectors.core											WITH NAME	core
Library						taf.collectors.btslog										WITH NAME	btslog
Library						taf.ul.alarms_watchdog										WITH NAME	alarm
Library						taf.sbts.oam.coam.admin										WITH NAME	COAM
Library           			taf.hw.rf_attenuator.attenuator								WITH NAME	at
Library						ute_reporting_portal
Library						../../../resources/python/ta_ultracaller/
Resource					../../../resources/robot/reportingportal_Keywords.robot

*** Variables ***
${Mplane_IP}				10.58.239.120												# BTS Mplane IP
${UE_PC_IP}					10.45.150.230												# UE PC IP
${DCAP_host}				10.41.209.115												# DCAP server IP
${BTS_IP}					192.168.255.129												# LMP IP
@{Throughput_ul}			56															# UL throughput
@{Throughput_dl}			56															# DL throughput
@{Throughput_ul_2CC}		90															# UL throughput 2CC
@{Throughput_dl_2CC}		110															# DL throughput 2CC
@{Throughput_ul_3CC}		70															# DL throughput 3CC
@{Throughput_dl_3CC}		115															# DL throughput 3CC
@{Throughput_dl_3CC_64}		110															# DL throughput 3CC for 64QAM
${Tput_dl_2CC_deviation}	${15}														# DL 2CC throughput difference
${Tput_ul_2CC_deviation}	${10}														# UL 2CC throughput difference
${Tput_dl_3CC_deviation}	${15}														# DL 3CC throughput difference
${Tput_ul_3CC_deviation}	${10}														# UL 2CC throughput difference
${Tput_dl_deviation_Mod}	${2}														# DL 3CC throughput difference between 64 and 256QAM
${Tput_ul_deviation_Mod}	${0}														# UL 2CC throughput difference between 64 and 256QAM
${Tput_dl_2CC_with_block}	${5}														# DL 2CC throughput difference after cell block and unblock
${Tput_ul_2CC_with_block}	${5}														# UL 2CC throughput difference after cell block and unblock
@{Deviation_ul}				30															# Default deviation in ul [Due to enviroment issue]
@{Deviation_dl}				30															# Default deviation in dl [Due to enviroment issue]
${NBIOT_tput}				11Kbits/sec													# NBIOT throughput
${NBIOT_deviation}			20%															# NBIOT deviation
${NBIOT_loss}				20%															# Datagram loss range
${Data_transfer_timeout}	400															# Default timeout for data transfer
@{Direction_ul}				ul															# Direction for Uplink
@{Direction_dl}				dl															# Direction for downlink
${NBIOT_duration}			60s															# NBIOT call duration
@{UE_alias}					UE_1														# Default UE id to run single UE call
${NBIOT_UE}					NBIOT_UE													# NBIOT UE alias
@{capabilities}				Legacy_1													# Default UE capability to run single UE call
@{NBIOT_ue_capability}		NBIoT														# NBIOT UE alias
@{Data_transfer_protocol}	TCP															# Default data transfer protocol
${NBIOT_protocol}			udp															# NBIOT data transfer protocol
${counter_wait_time}		1000														# Sleep time for counter
${RAT}						LTE															# RAT type
${Pcell}					1															# Primary cell
${Pcell_port}				4															# Pcell attenuation port
@{Scell_2CC}				12															# 2CC CA cells
@{Scell_3CC}				12		21													# 3CC CA cells
@{Scell_port_2CC}			3															# Scell attenuation ports
@{Scell_port_3CC}			3		8													# Scell attenuation ports
${NBIOT_host_Cell}			1															# NBIOT host cell
@{NBIOT_Cells}				4															# NBIOT host cells
${NBIOT_Cell_configured}	201															# NBIOT configured cell
&{Cells_configured}			1=282369	12=282380	21=282389							# Cell configured for CA
&{BTS_INFO}					host=${Mplane_IP}	port=${port}							# BTS details
@{Lte_custom_filters}		cp_4g														# DCAP log
${Port}						443															# Port value for DCAP connection
${Windows_user}				inbabtslabuser												# Windows PC default user name
${Windows_pass}				BT5l@bus3rl0g1n												# Windows PC default password
${Emil_path}				C://Program Files//Emil										# EMIL path in UEPC
${Uepc_Log_path}			C://Users//inbabtslabuser//Documents//Automation_logs		# Log path in UEPC
${Default_DCAP_duration}	15															# DCAP dcap log collection duration
${Dcap_log_timeout}			900															# DCAP log collection timeout
${Message_col}				${4}														# Message content colum in emil csv file
${Content_col}				${24}														# Content content colum in emil csv file
${Commission_timeout}		500															# Full commissioning timeout
${Update_timeout}			60m															# Timeout for software update
${Build_download_timeout}	30m															# Timeout to download build
${Artifactory}				https://artifactory-espoo2.int.net.nokia.com/artifactory	# Artifactory link
${Wget_link}				${Artifactory}/mn-cosi-sran-central-public-local/build		# Wget link
${File_extension}			_release_BTSSM_downloadable_A54.zip							# Build extension used in download and upgrade build
${Download_path}			/home/ute/Downloads											# Software download path in testpc
${SCF_PATH}					${CURDIR}/Configuration										# Default SCF path
${Default_SCF_file}			${SCF_PATH}/LTE_T_Mobile_8_3_Configuration.xml				# Default SCF file
${NBIOT_SCF_file}			${SCF_PATH}/LTE_NBIOT_Configuration.xml						# NBIOT SCF file
${2CC_SCF_file}				${SCF_PATH}/LTE_2CC_Configuration.xml						# 2CC SCF file
${3CC_SCF_file}				${SCF_PATH}/LTE_3CC_Configuration.xml						# NBIOT SCF file
${Connection}				Active_connection											# Alias for COAM connection
${Greater}					>=															# Arithmetic operation
${Equal}					==															# Arithmetic operation
${Call_retry}				3															# Retry attempts if call fails
${VM_space}					${80}														# Max space usage in VM
${Temp_space}				${80}														# Max space usage in VM temporary folder
${Dcap_status}				None														# DCAP status
${attenuator_host}			10.45.153.216												# Attenuator IP
${attenuator_port}			${3001}														# Attenuator port
@{at_channel}				${1}	${2}	${3}	${4}	${5}	${6}	${7}		# Attenuator channel
...							${8}	${9}	${10}	${11}	${12}	${13}	${14}
...							${15}	${16}
${at_vendor} 				TOPYOUNG 													# Attenuator vendor
${at_model}					TAS_16T16_0_2G6_90_1S_DEJS									# Attenuator model
${Update_to_QC}				FALSE
${Test_build}				SBTS_Build
${Proxy_path}				C://Users//inbabtslabuser//Documents
${qc_domain}				MN_RAN
${qc_project}				RAN_VRF
${ca}						VRF_RRM

*** Keywords ***
[1]LTE1332_Verification_of_2CC_UL_CA_and_2CC_DL_CA_with_64QAM
	[Documentation]				Verify 2CC CA in DL with 256QAM and UL with 64 QAM
	Log to console				\n---Testcase Main step---
	Configure setup				${2CC_SCF_file}
	Initialise counters
	Change modulation scheme	64QAM	UL
	Change modulation scheme	256QAM	Dl
	${Pcell_tput_dl_1}			${Pcell_tput_ul_1}		Start data transfer in Pcell
	${Scell_tput_dl_1}			${Scell_tput_ul_1}		Start data transfer in Pcell and Scell		2CC
	Run keyword and ignore error	Verify throughput			${Pcell_tput_dl_1}		${Scell_tput_dl_1}			${Tput_dl_2CC_deviation}
	Run keyword and ignore error	Verify throughput			${Pcell_tput_ul_1}		${Scell_tput_ul_1}			${Tput_ul_2CC_deviation}
	Check and verify 2CC counters		1	0
	[Teardown]	  Admin Teardown

[2]LTE3605_Verification_of_DL_4x4_MIMO_3CC_CA_10_layers_256_QAM_and_2CC_UL_CA
	[Documentation]			Verify 3CC CA in DL and 2CC CA in UL with 256 QAM
	Log to console			\n---Testcase Main step---
	Configure setup			${3CC_SCF_file}
	Initialise counters
	Parameter value change	${LNBTS_dist}/LNCEL-${Pcell}/CAREL-1	maxNumOfSuppMimoLayer	4-layer
	Parameter value change	${LNBTS_dist}/CADPR-0					maxNumMimoLayerFdd 		10
	${Pcell_tput_dl_1}		${Pcell_tput_ul_1}		Start data transfer in Pcell
	${Scell_tput_dl_1}		${Scell_tput_ul_1}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${Scell_tput_dl_1}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${Scell_tput_ul_1}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters	1		0
	Change modulation scheme		64QAM	Dl
	Change modulation scheme		64QAM	UL
	Set test variable		${Throughput_dl_3CC}	${Throughput_dl_3CC_64}
	${Scell_tput_dl_2}		${Scell_tput_ul_2}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput		${Scell_tput_dl_2}		${Scell_tput_dl_1}		${Tput_dl_deviation_Mod}
	Run keyword and ignore error	Verify throughput		${Scell_tput_ul_2}		${Scell_tput_ul_1}		${Tput_ul_deviation_Mod}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${Scell_tput_dl_2}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${Scell_tput_ul_2}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters	2		1
	[Teardown]	  Admin Teardown

[3]LTE3605_Verification_of_3CC_DL_CA_before_and_after_the_PCell_and_SCell_block_unblock
	[Documentation]			Verify 3CC DL CA after cell block and unblock
	Log to console			\n---Testcase Main step---
	Configure setup			${3CC_SCF_file}
	Initialise counters
	Change modulation scheme			64QAM		Dl
	Change modulation scheme			64QAM		UL
	Set test variable		${Throughput_dl_3CC}	${Throughput_dl_3CC_64}
	${Pcell_tput_dl_1}		${Pcell_tput_ul_1}		Start data transfer in Pcell
	${Scell_tput_dl_1}		${Scell_tput_ul_1}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${Scell_tput_dl_1}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${Scell_tput_ul_1}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters		1	0
	Block and unblock cells	${Scell_3CC}
	${Scell_tput_dl_2}		${Scell_tput_ul_2}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${Scell_tput_dl_2}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${Scell_tput_ul_2}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters		2	1
	${Cell}		Create list	${Pcell}
	Block and unblock cells	${Cell}
	${Scell_tput_dl_3}		${Scell_tput_ul_3}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${Scell_tput_dl_3}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${Scell_tput_ul_3}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters		3	2
	[Teardown]	  Admin Teardown

[4]LTE3605_Verification_of_3CC_DL_CA_before_and_after_the_RMOD_BBMOD_and_LTE_RAT_resets
	[Documentation]			Verify 3CC DL CA after RMOB, BBMOD and LTE rat reset
	Log to console			\n---Testcase Main step---
	Configure setup			${3CC_SCF_file}
	Initialise counters
	Change modulation scheme			64QAM		Dl
	Change modulation scheme			64QAM		UL
	Set test variable		${Throughput_dl_3CC}	${Throughput_dl_3CC_64}
	${Pcell_tput_dl_1}		${Pcell_tput_ul_1}		Start data transfer in Pcell
	${Scell_tput_dl_1}		${Scell_tput_ul_1}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${Scell_tput_dl_1}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${Scell_tput_ul_1}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters		1	0
	Reset RMOD				${Pcell}	1
	${Scell_tput_dl_2}		${Scell_tput_ul_2}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${Scell_tput_dl_2}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${Scell_tput_ul_2}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters		2	1
	Reset BBMOD				2	${Pcell}	1
	${Scell_tput_dl_3}		${Scell_tput_ul_3}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${Scell_tput_dl_3}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${Scell_tput_ul_3}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters		3	2
	Reset RAT				LTE		1
	${Scell_tput_dl_4}		${Scell_tput_ul_4}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${Scell_tput_dl_4}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${Scell_tput_ul_4}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters		4	3
	[Teardown]	  Admin Teardown

[5]LTE1092_Verification_of_2CC_UL_CA_and_2CC_DL_CA_and_block_unblock_the_PCell_and_SCell_one_after_another
	[Documentation]			Verify 3CC DL CA and 2CC Ul CA after blocking and unblocking Pcell/Scell
	Log to console			\n---Testcase Main step---
	Configure setup			${2CC_SCF_file}
	Initialise counters
	${Pcell_tput_dl_1}		${Pcell_tput_ul_1}		Start data transfer in Pcell
	${Scell_tput_dl_1}		${Scell_tput_ul_1}		Start data transfer in Pcell and Scell		2CC
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${Scell_tput_dl_1}		${Tput_dl_2CC_deviation}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${Scell_tput_ul_1}		${Tput_ul_2CC_deviation}
	Check and verify 2CC counters		1	0
	${maxtp_dl}				${maxtp_ul}				Start data transfer with block and unblock
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${maxtp_dl}			${Tput_dl_2CC_with_block}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${maxtp_ul}			${Tput_ul_2CC_with_block}
	Run keyword and continue on failure		Check 2CC counters		2
	#Check and verify 2CC counters		2	1
	${Scell_tput_dl_2}		${Scell_tput_ul_2}		Start data transfer in Pcell and Scell		2CC
	Run keyword and ignore error	Verify throughput		${Pcell_tput_dl_1}		${Scell_tput_dl_2}		${Tput_dl_2CC_deviation}
	Run keyword and ignore error	Verify throughput		${Pcell_tput_ul_1}		${Scell_tput_ul_2}		${Tput_ul_2CC_deviation}
	Check and verify 2CC counters		3	2
	[Teardown]	  Admin Teardown

[6]LTE3071_LTE3509_Verification_of_creation_and_deletion_of_inband_NBIoT_cells_and_DL_UL_data_transmission_in_NBIoT_cell
	[Documentation]			Verification of DL UL data transmission in NBIOT UE after adding and deleting inband NBIOT cells
	Log to console			\n---Testcase Main step---
	Configure setup			${SCF_PATH}/LTE_Without_NBIOT_Configuration.xml
	Initialise NBIOT counters
	ute_ue.Require Ue		${NBIOT_UE}	   capabilities=${NBIOT_ue_capability}
	Start data transfer in legacy UE
	Configure setup			${NBIOT_SCF_file}
	Start DL and UL data transfer in NBIOT and Legacy UE
	Verify BLER and MCS
	Check and verify NBIOT counters		1	0
	[Teardown]	  Admin Teardown

[7]LTE3071_LTE3509_Verification_of_Inband_NBIoT_call_and_LTE_WB_call_before_and_after_the_lock_unlock_of_host_cell
	[Documentation]			Verification of DL UL data transmission in NBIOT UE and legacy UE after locking and unloxking host cell
	Log to console			\n---Testcase Main step---
	Configure setup			${NBIOT_SCF_file}
	Initialise NBIOT counters
	ute_ue.Require Ue		${NBIOT_UE}	   capabilities=${NBIOT_ue_capability}
	Start DL and UL data transfer in NBIOT and Legacy UE
	Check and verify NBIOT counters		1			0
	${Cell}		Create list				${Pcell}
	Lock and unlock cells in loop		${Cell}		loop=5
	Start DL and UL data transfer in NBIOT and Legacy UE
	Verify BLER and MCS
	Check and verify NBIOT counters		2	1
	[Teardown]	  Admin Teardown

[8]LTE3071_LTE3509_Verification_of_inband_NBIoT_call_and_LTE_WB_call_before_and_after_the_RMOD_BBMOD_and_LTE_RAT_reset_and_site_reset
	[Documentation]		Verification of DL UL data transmission in NBIOT UE after RMOD, BBMOD and LTE rat reset
	Log to console		\n---Testcase Main step---
	Configure setup		${NBIOT_SCF_file}
	Initialise NBIOT counters
	ute_ue.Require Ue	${NBIOT_UE}	   capabilities=${NBIOT_ue_capability}
	Start DL and UL data transfer in NBIOT and Legacy UE
	Check and verify NBIOT counters		1	0
	Reset RMOD			${Pcell}		1
	Start DL and UL data transfer in NBIOT and Legacy UE
	Check and verify NBIOT counters		2	1
	Reset BBMOD			2	${Pcell}	1
	Start DL and UL data transfer in NBIOT and Legacy UE
	Check and verify NBIOT counters		3	2
	Reset site
	Start DL and UL data transfer in NBIOT and Legacy UE
	Check and verify NBIOT counters		4	0
	Reset RAT			LTE				1
	Start DL and UL data transfer in NBIOT and Legacy UE
	Check and verify NBIOT counters		5	4
	[Teardown]	  Admin Teardown

[9]LTE3071_LTE3509_Verification_of_NBIoT_call_before_and_after_software_upgrade_and_rollback
	[Documentation]			Verification of DL UL data transmission in NBIOT UE after software upgrade and rollback
	Log to console			\n---Testcase Main step---
	Configure setup			${NBIOT_SCF_file}
	Initialise NBIOT counters
	ute_ue.Require Ue		${NBIOT_UE}	   capabilities=${NBIOT_ue_capability}
	Start DL and UL data transfer in NBIOT and Legacy UE
	Check and verify NBIOT counters		1	0
	Rollback BTS software
	Configure setup			${NBIOT_SCF_file}
	Start DL and UL data transfer in NBIOT and Legacy UE
	Check and verify NBIOT counters		2	0
	Check build file and Upgrade build		${Active_build}
	Start DL and UL data transfer in NBIOT and Legacy UE
	Verify BLER and MCS
	Check and verify NBIOT counters		3	0
	[Teardown]		Run keywords	Check build file and Upgrade build		${Active_build}		AND		Admin Teardown

[10]LTE3605_Verification_of_3CC_DL_CA_2CC_UL_CA_before_and_after_the_software_upgrade_and_rollback
	[Documentation]				Verify 3CC DL CA and 2CC UL CA after software upgrade and rollback
	Log to console				\n---Testcase Main step---
	Configure setup				${3CC_SCF_file}
	Initialise counters
	Parameter value change		${LNBTS_dist}/LNCEL-${Pcell}/CAREL-1	maxNumOfSuppMimoLayer	4-layer
	Parameter value change		${LNBTS_dist}/CADPR-0					maxNumMimoLayerFdd 		10
	Change modulation scheme	64QAM	UL
	Change modulation scheme	64QAM	Dl
	Set test variable			${Throughput_dl_3CC}	${Throughput_dl_3CC_64}
	${Pcell_tput_dl_1}			${Pcell_tput_ul_1}		Start data transfer in Pcell
	${Scell_tput_dl_1}			${Scell_tput_ul_1}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput			${Pcell_tput_dl_1}		${Scell_tput_dl_1}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput			${Pcell_tput_ul_1}		${Scell_tput_ul_1}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters		1	0
	Parameter value change	  	${LNBTS_dist}/CADPR-0	maxNumMimoLayerFdd	12
	${Pcell_tput_dl_2}			${Pcell_tput_ul_2}		Start data transfer in Pcell
	${Scell_tput_dl_2}			${Scell_tput_ul_2}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput			${Scell_tput_dl_1}		${Scell_tput_dl_2}		${2}
	Run keyword and ignore error	Verify throughput			${Scell_tput_ul_1}		${Scell_tput_ul_2}		${2}
	Check and verify 3CC counters		2	1
	Rollback BTS software
	Configure setup				${3CC_SCF_file}
	${Scell_tput_dl_3}			${Scell_tput_ul_3}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput			${Pcell_tput_dl_2}		${Scell_tput_dl_3}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput			${Pcell_tput_ul_2}		${Scell_tput_ul_3}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters		3	0
	Check build file and Upgrade build					${Active_build}
	${Scell_tput_dl_4}			${Scell_tput_ul_4}		Start data transfer in Pcell and Scell		3CC
	Run keyword and ignore error	Verify throughput			${Pcell_tput_dl_2}		${Scell_tput_dl_4}		${Tput_dl_3CC_deviation}
	Run keyword and ignore error	Verify throughput			${Pcell_tput_ul_2}		${Scell_tput_ul_4}		${Tput_ul_2CC_deviation}
	Check and verify 3CC counters		4	0
	[Teardown]		Run keywords	Check build file and Upgrade build		${Active_build}		AND		Admin Teardown

Admin Setup
	[Documentation]			Create connection to BTS, check BTS status, start watching alarms, create testcase folder and start BTS log
	Log to console			\n---Test setup---
	COAM.setup_admin		bts_host=${BTS_IP}		alias=${connection}	 admin_api_log_dir=${OUTPUT_DIR}
	Testcase setup
	Start alarm monitoring
	Check BTS is OnAir
	Create testcase folder
	Start BTS logs
	Set initial Attenuation

Testcase setup
	[Documentation]			Setup testcase default values
	Set testcase values
	Create dcap session
	Set counter values

Set testcase values
	[Documentation]		Set variable for testcase
	${BTS_details}		COAM.get_bts_info		connection=${connection}
	Log					${BTS_details}
	Set global variable	${BTS_ID}				${BTS_details['mrbtsID']}
	Set global variable	${Cell_dist}			/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${BTS_ID}/LNCEL_R
	Set global variable	${BBMOD_dist}			/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R
	Set global variable	${MRBTS_dist}			MRBTS-${BTS_ID}
	Set global variable	${LNBTS_dist}			${MRBTS_dist}/LNBTS-${BTS_ID}
	${sw_version}		COAM.get_sw_version		connection=${connection}
	Set Suite Metadata	Software version		${sw_version}
	Set Suite variable	${sw_version}
	${Active_build}		Check current software
	Set Suite variable	${Active_build}

Start alarm monitoring
	[Documentation]		Start monitoring alarm in BTS
	${Active_alarm}		COAM.get_active_alarms	  			connection=${connection}
	LOG					${Active_alarm}
	${allowed_alarms}	Expected alarm
	alarm.Watch alarms	allowed_alarms=${allowed_alarms}	connection_kwargs=${connection}	   log_dir=${OUTPUT_DIR}

Prepare environment
	[Documentation]		Prepare environement
	Log to console		\n---Suite setup---
	Check space			${OUTPUT_DIR}	${VM_space}
	Run					rm -rf /tmp
	Check space			/tmp/ 			${Temp_space}
	Kill QNavigator
	Check UE status
	Backup SCF
	Get Hostname
	Verify build

Check space
	[Documentation]	Check space in VM
	[Arguments]		${path}				${value}
	${output}		Run					df -hP ${path} | awk '{print $5}' |tail -1|sed 's/%$//g'
	${result}		Convert To Integer	${output}
	${status}		Evaluate			${result}<${value}
	Log to Console	\nUsage in path ${path} is ${output}%
	Run keyword if	'${status}'=='False'	Run keywords	Log to console		\nDisk space should be less than ${value}%
	...														AND					Fail

Kill QNavigator
	[Documentation]		Kill Qnavigator application in UE PC
	${output}			Execute command in UE PC		ps -W | awk '/Qnavigator_V1.6.9.1.exe/,NF=1' | xargs kill -f

Check UE status
	[Documentation]				Check UE status and start NAA
	Check UE available
	Start NAA application
	Check proxy

Check UE available
	[Documentation]		Check if UE is available
	Log to console		\Checking if UE is active
    ${output}			Execute command in UE PC		adb devices | tail -n +2
	${Result}			Run keyword and return status	Should contain	${output}		device
	Run keyword if 		'${Result}'=='False'			Run keywords	Log to console	\nUE not found, please check !!!
	...																	AND		Fail

Start NAA application
	[Documentation]		Start NAA application in UE
	Log to console		\nStarting NAA application in UE
    ${output}			Execute command in UE PC			 adb shell monkey -p com.nokia.android.application 1

Check proxy
	[Documentation]		Check if proxy is running
	Kill Proxy
	Start Proxy

Kill Proxy
	[Documentation]				Kill proxy
	Log to console				\nKilling proxy in UEPC
	Execute command in UE PC	ps -W | awk '/proxy.exe/,NF=1' | xargs kill -f
	sleep						10

Start Proxy
	[Documentation]				Start proxy
	Log to console				\nStarting proxy using Batch file
	Execute command in UE PC	cd ${Proxy_path} && ./Start_proxy.bat
	sleep						10
	${output}					Execute command in UE PC		ps -W | awk '/proxy.exe/,NF=1'
	${Result}					Run keyword and return status	Should Not Be Empty		${output}
	Run keyword if 				'${Result}'=='False'			Run keywords	Log to console	\nUnable to start Proxy in UE PC, Please check manually !!!
	...																	AND		Fail

Verify build
	[Documentation]		Verify build in BTS
	Run keyword if		"${Test_build}" == "SBTS_Build"		Log to console		Test build not specified, Build verification will be skipped
	...		ELSE		Check test build

Check test build
	[Documentation]			Compare BTS build
	COAM.setup_admin		bts_host=${BTS_IP}				alias=${connection}	admin_api_log_dir=${OUTPUT_DIR}
	${Build}				Check current software
	Run keyword if 			"${Test_build}" != "${Build}"	Run keywords		Log to console		Please check the software in BTS	AND		Fail
	[Teardown]				COAM.teardown_admin				connection=${connection}

Execute command in UE PC
	[Documentation]		Execute command in UE PC
	[Arguments]			${command}
	Log to console		\Executing command "${command}" in machine "${UE_PC_IP}"
	Wait Until Keyword Succeeds	   3 times	   5
	...		ssh.Connect_to		${UE_PC_IP}		${Windows_user}		${Windows_pass}    alias=UE_PC_CMD		timeout=60
    ${output}			ssh.Execute		${command}			connection=UE_PC_CMD
    Log					${output}
	[Teardown]			ssh.Disconnect		connection=UE_PC_CMD
	[Return]			${output}

Backup SCF
	[Documentation]				Back the SCF before execution
	COAM.setup_admin			bts_host=${BTS_IP}				alias=${connection}					admin_api_log_dir=${OUTPUT_DIR}
	Log to console				\nBacking up current SCF to file ${OUTPUT_DIR}/SCF/Pre_execution_scf.xml
	${Pre_execution_scf_file}	COAM.Get Current Scf File		local_dir_path=${OUTPUT_DIR}/SCF	file_name=Pre_execution_scf.xml
	...							connection=${connection}
	Set Suite variable			${Pre_execution_scf_file}
	COAM.teardown_admin			connection=${connection}

Set initial Attenuation
	[Documentation]			Set initial attenuation values
	at.setup_attenuator		ip_addr=${attenuator_host}  port=${attenuator_port}		attenuation_port_numbers=@{at_channel}
	...  					vendor=${at_vendor}			model=${at_model}
	${set attenuation}		Create List		1,90	2,90	3,90	4,0		5,90	6,90	7,90	8,90	9,90	10,90
	...										11,90	12,90	13,90	14,90	15,90	16,90
	Change attenuation	${set attenuation}

Change attenuation
	[Arguments]			${port_val_list}
	[Documentation]		Set the attenuation of specified port
	Log to console      \nChanging attenuator values to default :\n${port_val_list}
	FOR    ${val}    IN    @{port_val_list}
		${channel_num}			${value}			Split String	${val}	,	1
		Set Attenuator value	${channel_num}		${value}
	END

Set Attenuator value
	[Arguments]			${channel_num}			${value}
	[Documentation]		Set the attenuation of specified port
	${channel_num}		Convert To Integer		${channel_num}
	${value}			Convert To Integer		${value}
	${set_value}		at.read_attenuation		port=${${channel_num}}
	at.set_attenuation  port=${channel_num} 	value=${value}		confirm=${True}
	${set_value}		at.read_attenuation		port=${${channel_num}}
	Should Be Equal As Strings					${set_value}  ${value}

Restore environment
	[Documentation]			Restore original SCF
	Log to console			\nRestoring setup to original SCF
	COAM.setup_admin		bts_host=${BTS_IP}			alias=${connection}	 admin_api_log_dir=${OUTPUT_DIR}
	${BTS_details}			COAM.get_bts_info	 		connection=${connection}
	Log						${BTS_details}
	Set global variable		${BTS_ID}					${BTS_details['mrbtsID']}
	#Configure setup		${Pre_execution_scf_file}
	Configure setup			${Default_SCF_file}
	COAM.teardown_admin		connection=${connection}

Configure setup
	[Documentation]		Perform commissioning
	[Arguments]			${SCF_file}
	Log to console		\nCommissioning site with SCF : ${SCF_file}
	COAM.Perform Commissioning		bts_id=${BTS_ID}		scf_file=${SCF_file}			skip_parameter_relation_errors=True
	...								should_activate=True	timeout=${Commission_timeout}	connection=${connection}
	Log to console		\nWaiting for BTS status to be OnAir
	Wait Until Keyword Succeeds	   15 times	   60	 Check BTS is OnAir

Start BTS logs
	[Documentation]					Starts BTS log in testpc
	Log to console					\nStarting BTS log
	Run								killall btslog
	btslog.create_btslog_collector	name=btslog
	core.setup_collectors			names=btslog
	core.set_suite_alias			btslog
	core.start_collectors			names=btslog

Stop BTS logs and check
	[Documentation]		Stops BTS log and check for crash
	${status}			Run keyword and return status		Stop BTS log
	Run Keyword If		'${status}'=='True'					Verify BTS log
	...		ELSE		Log   Syslog collection failed!!!	ERROR

Stop BTS log
	[Documentation]				Stops BTS log
	Log to console				\nCollecting BTS log
	core.stop_collectors		names=btslog
	core.collect_collectors		names=btslog	target_dir=${OUTPUT_DIR}
	core.teardown_collectors	names=btslog

Verify BTS log
	[Documentation]		Verify BTS log
	${check}			Check_bts_logs			${OUTPUT_DIR}/btslog
    Run Keyword If		'${check}'!='True'		Run keywords	Log   Unexpected prints found in syslog !!!    ERROR
	...													AND		FAIL

Create dcap session
	[Documentation]		Establish DCAP session
	dcap.connect_to		host=${DCAP_host}	  port=${port}	  rd_version=dcapv3	secure=True	username=utfuser	password=utfadmin!

Dcap Start Trace
	[Documentation]			Start DCAP logs with custom filter
	Log to console			\nStarting DCAP trace
	Set global variable		${Dcap_status}		Started
	${output}				Wait Until Keyword Succeeds		3 times		300		dcap.start_trace
	...																			duration=${Default_DCAP_duration}
	...																			bts=${BTS_INFO}
	...																			enb_custom_profile=@{lte_custom_filters}
	...																			wait_for_activation=True
	#Sleep					60								reason=Wait for DCAP start
	${val}					Get Dictionary Keys				${output}
	${START_TRACE_ID}		Get from Dictionary				${output}	${val}[0]
	Set Suite Variable		${START_TRACE_ID}
	Log to console			\nDCAP log collection has been started in the BTS

Dcap Stop Trace and Get results
	[Documentation]		Stops DCAP and collect logs
	Stop DCAP trace
	${Dcap_log}			Collect DCAP logs
	[Return]			${Dcap_log}

Stop DCAP trace
	[Documentation]		Stop DCAP trace
	[Arguments]			${Stop_timeout}=100
	Log to console		\nStopping DCAP trace ID ${START_TRACE_ID}
	dcap.stop_trace		trace_id=${START_TRACE_ID}		timeout=${Stop_timeout}
	Log to console		\nDCAP logging stopped
	Set global variable	${Dcap_status}					Done

Collect DCAP logs
	[Documentation]		Collect DCAP logs
	Log to console		\nDownloading DCAP logs
	${Dcap_log}			dcap.get_results		result_id=${START_TRACE_ID}	   target_dir=${OUTPUT_DIR}/DCAP_Logs	 timeout=${dcap_log_timeout}
	Set global variable	${Dcap_status}			Collected
	[Return]			${Dcap_log}

Expected alarm
	[Documentation]			Alarms which are ignored on runtime
	${allowed_alarm_1}		Create alarm	alarm_id=7220		fault_id=61524		fault_name=SSH enabled
	${allowed_alarm_2}		Create alarm	alarm_id=7220	  	fault_id=4654		fault_name=Ethernet port security is disabled
	${allowed_alarm_3}		Create alarm	alarm_id=7220	  	fault_id=61649		fault_name=LMP access via port 443
	${allowed_alarm_4}		Create alarm	alarm_id=7220	  	fault_id=4655		fault_name=Service account root access is enabled
	${allowed_alarm_5}		Create alarm	alarm_id=7220	  	fault_id=61652		fault_name=R&D Service Port enabled
	${allowed_alarm_6}		Create alarm						fault_id=4592		fault_name=BTS Reset Cause
	${allowed_alarm_7}		Create alarm					  	fault_id=49			fault_name=Cell blocked
	${allowed_alarm_8}		Create alarm	alarm_id=7652	  	fault_id=4458		fault_name=SSH Login Configuration failed			#SSD HW issue
	${allowed_alarm_9}		Create alarm					  	fault_id=6261
	...						fault_name=Failure in internal BTS connection or connection to 3rd party tool
	${allowed_alarm_10}		Create alarm					  	fault_id=6278		fault_name=MFBI cell configuration conflict
	${allowed_alarm_11}		Create alarm					  	fault_id=6327		fault_name=Setup of X2 connectivity to gNB failed
	${allowed_alarm_12}		Create alarm						fault_id=6203		#fault_name=Transport layer connection failure in X2 interface
	${allowed_alarms}		Create list		${allowed_alarm_1}	${allowed_alarm_2}	${allowed_alarm_3}	${allowed_alarm_4}
	...										${allowed_alarm_5}	${allowed_alarm_6}	${allowed_alarm_7}	${allowed_alarm_8}
	...										${allowed_alarm_9}	${allowed_alarm_10}	${allowed_alarm_11}		${allowed_alarm_12}
	[Return]				${allowed_alarms}

Admin Teardown
	[Documentation]				Check for alarm and delete COAM connection
	Log to console				\n---Test teardown---
	Check BTS is OnAir
	Check alarm
	alarm.stop_watching_alarms
	Collect snapshot from BTS
	Stop BTS logs and check
	COAM.teardown_admin			connection=${connection}

Create testcase folder
	[Documentation]		Create testcase folder in testpc
	${val}				Run Keyword And Return Status		LOG	  ${OUTPUT_DIR}/${Folder}/${TEST NAME}
	Run Keyword If		${val} == False	   					Get Date
	create directory	${OUTPUT_DIR}/DCAP_Logs

Get Date
	[Documentation]			Get date to create testcase folder
	${date}					Get Current Date	result_format=%d_%m_%Y_%H%M%S_%f
	${date}					Convert to String	${date}
	Set global variable		${Folder}			${date}

Check BTS is OnAir
	[Documentation]		Check the BTS current status
	${bts_status}		COAM.get_bts_statuses	 connection=${connection}
	Should Be Equal As Strings	  ${bts_status["proceduralState"]}		OnAir
	Run Keyword If		'${bts_status["proceduralState"]}'=='OnAir'		LOG	  BTS procedural state is now: ${bts_status["proceduralState"]}
	...	   ELSE			Fail
	Log to console		\nBTS procedural state : ${bts_status["proceduralState"]}
	Wait Until Keyword Succeeds		30 times	10		Check cell status

Wait for BTS OnAir
	[Documentation]		Check Site onAir
	Log to console		\nWaiting for BTS to be OnAir
	FOR	   ${value}	   IN RANGE	   10
		${bts_status}		COAM.get_bts_statuses	 connection=${connection}
		Exit For Loop IF	'${bts_status["proceduralState"]}'=='OnAir'
		Sleep				1m	  reason=Wait for BTS status OnAir
	END
	${bts_status}		COAM.get_bts_statuses	 connection=${connection}
	Run Keyword If		'${bts_status["proceduralState"]}'=='OnAir'	   LOG	  BTS procedural state is now: ${bts_status["proceduralState"]}
	...	   ELSE			fail
	Log to console		\nBTS procedural state : ${bts_status["proceduralState"]}
	Wait Until Keyword Succeeds		30 times	10		Check cell status

Check cell status
	[Documentation]		Check all cell status
	${cells}			COAM.get_cells_info		cell_type=lte	timeout=10	 connection=${connection}	 detailed_output=False
	FOR	   ${cell_dist}	   IN	 @{cells}
		Check cell details		 ${cell_dist['id']['internal']}
	END

Check cell details
	[Documentation]				Check cell details
	[Arguments]					${cell}
	...							${locking_status}=unlocked	${operational_status}=enabled	${usage_status}=Active	${blocking_status}=Unblocked
	${cell_status}				COAM.get_cell_specific_info	   cell_id=${cell}	  connection=${connection}
	${administrativeState}		Set Variable	${cell_status['status']['administrativeState']}
	Run keyword And Continue On Failure	   Should Be Equal	  ${administrativeState.upper()}	${locking_status.upper()}
	${operationalState}			Set Variable	${cell_status['status']['operationalState']}
	Run keyword And Continue On Failure	   Should Be Equal	  ${operationalState.upper()}	 ${operational_status.upper()}
	${usageState}				Set Variable	${cell_status['status']['usageState']}
	#Run keyword And Continue On Failure	Should Be Equal	   ${usageState.upper()}	${usage_status.upper()}
	Log							${usage_status.upper()}
	${blockingState}			Set Variable	${cell_status['status']['blockingState']}
	Run keyword And Continue On Failure	   Should Be Equal	  ${blockingState.upper()}	  ${blocking_status.upper()}

Check alarm
	[Documentation]		Check BTS alarm
	${Active_alarm}		COAM.get_active_alarms	  connection=${connection}
	LOG					${Active_alarm}
	${status}			Run keyword and continue on failure		alarm.check_detected_alarms
	#Run Keyword If		'${status}'!='True'					Log		Unexpected alarm is detected !!!		ERROR

Collect snapshot from BTS
	[Documentation]		Download BTS snapshot
	[Arguments]			${Name}=Snapshot.zip
	Log to console		\nCollecting snapshot from BTS
	${status}			Run keyword and return status		COAM.Collect Snapshot	target_file_name=${OUTPUT_DIR}/Snapshot/${Name}
	...																				coverage=Full
	...																				force=True
	...																				timeout=1000
	...																				connection=${connection}
	Run Keyword If		'${status}'=='False'				Log   					Snapshot collection failed !!!			ERROR

Attach ue and start data transfer
	[Documentation]		Keyword to start data transfer and check throughput
	[Arguments]			${UE_alias}	   ${capabilities}	${throughput_dl}	${throughput_ul}	${timeout}	  ${check_tpt}=True		${CA}=None
	...					${check_cell}=True		${set_cell}=False		${wait_for_transfer}=True	${DCAP}=False	${Attenuate_CA_cells}=False
	Run Keyword If		'${DCAP}'=='True'		Dcap Start Trace
	Run Keyword If		'${Attenuate_CA_cells}'=='True'		Attenuate CA cells		90	${CA}
	Check proxy
	ta_ultracaller.Require UE	ue_alias=${UE_alias}	capabilities=${capabilities}
	ta_ultracaller.Detach UE	ue_alias=${UE_alias}
	Log to console		\nExecuting testcase in UE : ${capabilities}
	Log to console		\nSwitching Aeroplane Mode On/OFF
	ta_ultracaller.Attach UE	ue_alias=${UE_alias}
	${result}			ta_ultracaller.validate_ue_info		ue_alias=${UE_alias}	info=CELL_ID	expected_value=
	Run Keyword If		'${set_cell}'=='True'		Set Pcell and Scells		${result}
	${Attach_cell}		Get From Dictionary			${Cells_configured}			${Pcell}
	Run Keyword If		'${check_cell}'=='True' 	ta_ultracaller.validate_ue_info		ue_alias=${UE_alias}	info=CELL_ID
	...					expected_value=${Attach_cell}
	Run Keyword If		'${Attenuate_CA_cells}'=='True'		Attenuate CA cells		10	${CA}
	Log to console		\nStarting UL and DL data transfer
	ta_ultracaller.start_datatransfer	 ${UE_alias}	${data_transfer_protocol}	direction=${direction_dl}		tputcheck=No
	ta_ultracaller.start_datatransfer	 ${UE_alias}	${data_transfer_protocol}	direction=${direction_ul}
	Log to console		\nWaiting for data transfer
	Log					${check_tpt}
	Run Keyword If		'${wait_for_transfer}'=='True'	  Run Keywords		ta_ultracaller.await_data_transfer_finish	${UE_alias}	${direction_ul}
	...					${timeout}	AND	   Sleep	${timeout}		AND		Log to console		\nData transfer completed
	Run Keyword If		'${Attenuate_CA_cells}'=='True'		 Attenuate CA cells		90	${CA}
	${value_dl}			Run Keyword If	'${wait_for_transfer}'=='True'	Run keyword and continue on failure		ta_ultracaller.Calculate Thrughtput
	...					ue_alias=${UE_alias}	direction=${direction_dl}		thrughtput=${throughput_dl}	deviation=${deviation_dl}
	${value_ul}			Run Keyword If	'${wait_for_transfer}'=='True'	Run keyword and continue on failure		ta_ultracaller.Calculate Thrughtput
	...					ue_alias=${UE_alias}	direction=${direction_ul}		thrughtput=${throughput_ul}	deviation=${deviation_ul}
	${maxtp_dl}			Run keyword and continue on failure		Run Keyword If	'${wait_for_transfer}'=='True'	Get from dictionary
	...																			${value_dl['${UE_alias[0]}']}	maxtput
	${maxtp_ul}			Run keyword and continue on failure		Run Keyword If	'${wait_for_transfer}'=='True'	Get from dictionary
	...																			${value_ul['${UE_alias[0]}']}	maxtput
	Run Keyword If		'${wait_for_transfer}'=='True'		ta_ultracaller.Detach UE	ue_alias=${UE_alias}
	${Dcap_log}			Run Keyword If		'${Dcap_status}'=='Started'			Dcap Stop Trace and Get results
	Run Keyword If		'${Dcap_status}'=='Collected'	Run keyword and continue on failure	Verify CA in EMIL	${Dcap_log}		${CA}
	[Teardown]			Run keyword and ignore error	Run Keyword If		'${Dcap_status}'=='Started'		Stop DCAP trace		Stop_timeout=30
	[Return]			${maxtp_dl}		${maxtp_ul}

Attenuate CA cells
	[Documentation]		Change cell attenuation value
	[Arguments]			${Value}	${CA}
	Log to console		\nAttenuating cells ${Scell_port_${CA}} to ${Value}
	FOR    ${val}    IN    @{Scell_port_${CA}}
		Set Attenuator value	${val}		${Value}
	END

Set Pcell and Scells
	[Documentation]		Set value of primary and secondary cells
	[Arguments]			${result}
	Log to console		\nSetting Pcell and Scell for CA
	Set test variable	${Pcell_val}	${result['${UE_alias}[0]']['location']['signalInfo']['CID']}
	Set test variable	${Pcell}	${Cells_configured['${Pcell_val}']}
	${val}				Get Dictionary Values		${Cells_configured}
	Run keyword and continue on failure		Should contain		${val}		${Pcell}
	${Scell}			Get Dictionary Values	${Cells_configured}		sort_keys=False
	Remove Values From List		${Scell}	${Pcell}
	Set global variable	${Pcell}
	Set global variable	${Scell}

Parameter value change
	[Documentation]		Change parameter value in SCF and commision it
	[Arguments]			${dist_name}	 ${parameter}	 ${value}
	Log to console		\nChanging BTS parameter ${parameter} to ${value} [Dist: ${dist_name}]
	${current_value}	Get Current Parameter Value	   ${dist_name}	   ${parameter}
	LOG					${current_value}
	Run Keyword If		'${current_value.upper()}'!='${value.upper()}'	COAM.Perform Parameter Recommissioning	  dist_name=${dist_name}
	...					parameter=${parameter}		operation=update	value=${value}	  skip_parameter_relation_errors=True
	...					connection=${connection}
	...		ELSE		Log to console		\nCurrent ${parameter} value is already set to ${value}, No need to peform commissioning
	${current_value}	Get Current Parameter Value	   ${dist_name}	   ${parameter}
	LOG					${current_value}
	Should Be Equal As Strings	  ${current_value.upper()}	  ${value.upper()}

Get Current Parameter Value
	[Documentation]		Get current parameter value
	[Arguments]			${dist_name}				${param_name}
	${temp_scf_file}	COAM.Get Current Scf File	local_dir_path=/tmp	file_name=temp_scf.xml	  timeout=60	connection=${connection}
	scf.Load Scf		${temp_scf_file}
	${param_value}		scf.get_value_from_scf		dist_name=${dist_name}	p_name=${param_name}
	[Return]			${param_value}

Start data transfer with block and unblock
	[Documentation]							Start data transfer with block and unblock of Pcell
	Attach ue and start data transfer		${UE_alias}	${capabilities}		${throughput_dl_2CC}		${throughput_ul_2CC}
	...										${Data_transfer_timeout}		wait_for_transfer=False		Attenuate_CA_cells=True		CA=2CC
	Attenuate CA cells		5	2CC
	Sleep					30
	${Cell}		Create list	${Pcell}
	Block and unblock cells	${Cell}
	Sleep					30
	Block and unblock cells	${Scell_2CC}
	Sleep					${Data_transfer_timeout}
	Attenuate CA cells		90	2CC
	${value_dl}				Run keyword and continue on failure		ta_ultracaller.Calculate Thrughtput
	...																ue_alias=${UE_alias}	direction=${direction_dl}
	...																thrughtput=${throughput_dl}	   deviation=${deviation_dl}
	${value_ul}				Run keyword and continue on failure		ta_ultracaller.Calculate Thrughtput
	...																ue_alias=${UE_alias}	direction=${direction_ul}
	...																thrughtput=${throughput_ul}	   deviation=${deviation_ul}
	${maxtp_dl}				Get from dictionary		${value_dl['${UE_alias[0]}']}	   maxtput
	${maxtp_ul}				Get from dictionary		${value_ul['${UE_alias[0]}']}	   maxtput
	[Return]				${maxtp_dl}				${maxtp_ul}

Counter value
	[Documentation]			Check counter value of BTS
	[Arguments]				${counter_name}			${cell}
	Log to console			\nChecking BTS counter ${counter_name}
	${result}				COAM.get_pm_counters	counter_ids=${counter_name}	timeout=1000	connection=${connection}
	Log						${result}
	${Dict_val}				Get_counter_list		${result}					${counter_name}	${cell}
	${counter_value_list}	Get Dictionary Values	${result${Dict_val}}
	${Total_Count}			Get value of Counter	${counter_value_list}
	[Return]				${Total_Count}

Get value of Counter
	[Documentation]		Get total value from list
	[Arguments]			${Counter_value}
	Set test Variable	${i}	${0}
	FOR	   ${value}	   IN	 @{Counter_value}
		${i}	Evaluate	${i} + ${value}
	END
	[Return]	${i}

Set counter values
	[Documentation]			Set counter expected values
	...						M8010C114 and M8010C115 are set to 0 because of environment issue
	&{Counters_val}			Create Dictionary	M8011C171=${10}		M8011C172=${10}		M8012C174=${8000}	M8011C67=${10}		M8011C68=${10}
	...											M8012C151=${5000}	M8012C22=${8000}	M8012C25=${5000}	M8010C114=${0}		M8010C115=${0}
	...											M8051C53=${10}		M8051C54=${10}		M8051C118=${10}		M8066C14=${60000}	M8066C15=${60000}
	...											M8066C16=${150000}	M8066C17=${40000}	M8001C149=${0}		M8001C152=${0}		M8001C299=${0}
	...											M8001C300=${0}		M8012C23=${5000}	M8012C26=${4000}	M8051C60=${10}		M8001C494={1}
	...											M8001C495=${1} 		M8001C496=${1} 		M8001C282=${1}
	@{2CC_Counters}			Create list			M8012C151	M8012C174	M8011C67	M8011C68	#M8001C494 	M8001C495	M8001C496	M8001C282
	@{3CC_Counters}			Create list			M8012C151	M8012C22	M8012C25	M8010C114	M8010C115
	@{NBIOT_Counters}		Create list			M8066C14	M8066C15	M8066C16	M8066C17
	@{overload_counters}	Create list			M8001C149	M8001C152	M8001C299	M8001C300
	@{UE_counters}			Create list			M8012C23	M8012C26	M8051C60
	Set Suite variable		&{Counters_val}
	Set Suite variable		@{2CC_Counters}
	Set Suite variable		@{3CC_Counters}
	Set Suite variable		@{NBIOT_Counters}
	Set Suite variable		@{overload_counters}
	Set Suite variable		@{UE_counters}

Initialise counters
	[Documentation]		Initialize 2CC and 3 CC counters
	${value}			Get Dictionary Keys		${Cells_configured}
	FOR		${cell}	IN	 @{value}
		Set counter as zero		${cell}		@{2CC_Counters}
		Set counter as zero		${cell}		@{3CC_Counters}
	END

Initialise NBIOT counters
	[Documentation]			Initialize NBIOT counters
	Set counter as zero		${NBIOT_Cell_configured}		@{NBIOT_Counters}
	Set counter as zero		${NBIOT_host_Cell}				@{UE_counters}
	Set counter as zero		${NBIOT_host_Cell}				@{overload_counters}

Set counter as zero
	[Documentation]	Set counetrs to zero
	[Arguments]		${cell}		@{Counters}
	FOR		${value}	IN	 @{Counters}
		Set test Variable	 ${${value}_${cell}_${0}}	 ${0}
	END

Verify Emil logs
	[Documentation]		Convert emil file and verify
	[Arguments]			${values}	${Dcap_log}
	Convert Emil File To Csv		${Dcap_log}
	FOR		${check}	IN	 @{values}
		${result}		Parse_Emil_Csv_File_For_Message		path=${OUTPUT_DIR}/DCAP_Logs/Extracted/		msg=${check}
		...													msg_col=${message_col}						con_col=${content_col}
		Run keyword And Continue On Failure					Should Be True								${result}
	END
	[Teardown]			Remove Directory					${OUTPUT_DIR}/DCAP_Logs/Extracted			recursive=True

Convert Emil File To Csv
	[Documentation]		Convert Emil logs collected from DCAP
	[Arguments]			${Dcap_log}
	Log to console		\nConverting Emil logs and verifying
	${Log_path}			Set Variable		${OUTPUT_DIR}/DCAP_Logs
	${source_paths}		Set Variable		${Log_path}/Extracted/
	Create directory	${source_paths}
	Extract_zip			${Dcap_log}			${source_paths}
	${check}			OperatingSystem.List Directory	  ${source_paths}
	FOR	   ${value}	   IN	 @{check}
		${date}		Set Variable		${value}
		Exit For Loop
	END
	${it}				OperatingSystem.List Directory	${source_paths}/${date}
	Wait Until Keyword Succeeds	   3 times	   3
	...		ssh.Connect_to		${UE_PC_IP}		${Windows_user}		${Windows_pass}    alias=mcg_vm		timeout=60
	FOR	   ${out_index}	   IN	 @{it}
		Run keyword And Ignore Error	Start Emil To Convert Emil File To Csv	  source_path=${source_paths}/${date}
		...		source_file=${out_index}/
	END
	${output}			ssh.Execute		command=rm -v -f ${uepc_Log_path}//*	   connection=mcg_vm		timeout=30s
	LOG					${output}
	[Teardown]			ssh.Disconnect	connection=mcg_vm

Start Emil To Convert Emil File To Csv
	[Documentation]			Upload Emil logs to MCG PC and convert emil to csv file
	[Arguments]				${source_path}	   ${source_file}
	${source_emil_files}	OperatingSystem.List Directory	  ${source_path}/${source_file}
	ssh.Execute				command=mkdir ${uepc_Log_path}	  connection=mcg_vm
	FOR	   ${source_emil_file}	  IN	@{source_emil_files}
		${status}			Run keyword and return status		Should contain		${source_emil_file}		.emil
		Run Keyword If		${status}==True		Convert to Emil		${source_path}		${source_file}		 ${source_emil_file}
	END

Convert to Emil
	[Arguments]				${source_path}	   ${source_file}		${source_emil_file}
	ssh.upload_file		local_path=${source_path}/${source_file}/${source_emil_file}	remote_path=${uepc_Log_path}//${source_emil_file}
	...					connection=mcg_vm
	Run keyword and ignore error	ssh.Execute	   command=ps -W | awk '/Emil.exe/,NF=1' | xargs kill -f	  connection=mcg_vm		timeout=30s
	${src_file}			Set Variable	${uepc_Log_path}//${source_emil_file}
	${cmd}				Set Variable	cd "${emil_path}" && ./Emil.exe ${src_file} -tocsvrnd -autoclose -destination ${uepc_Log_path}
	LOG					${cmd}
	${output}			ssh.Execute	   command=${cmd}	   connection=mcg_vm		timeout=5m
	LOG					${output}
	${csvfile}			String.Replace String	 string=${source_emil_file}	   search_for=.emil	   replace_with=.csv
	ssh.download_file	remote_path=${uepc_Log_path}//${csvfile}	local_path=${source_path}/${source_file}/${csvfile}		connection=mcg_vm

Lock cells
	[Documentation]		Lock the specified cell
	[Arguments]			${cell_list}
	FOR	   ${cell}	  IN	@{cell_list}
		Log to console		\nLocking cell : ${cell}
		Run keyword and ignore error	COAM.lock			dist_name=${Cell_dist}-${cell}	timeout=180				connection=${connection}
		Wait Until Keyword Succeeds		12 times		10		Check cell details		${Cell_dist}-${cell}			locking_status=locked
		...																			operational_status=disabled		usage_status=Idle
		...																			blocking_status=Unblocked
	END

Block cells
	[Documentation]		Block the specified cell
	[Arguments]			${cell_list}
	FOR	   ${cell}	  IN	@{cell_list}
		Log to console		\nBlocking cell : ${cell}
		Run keyword and ignore error	COAM.block_cell		dist_name=${Cell_dist}-${cell}	timeout=180				connection=${connection}
		Wait Until Keyword Succeeds		12 times		10		Check cell details		${Cell_dist}-${cell}			locking_status=unlocked
		...																			operational_status=disabled		usage_status=Idle
		...																			blocking_status=Blocked
	END

Unlock cells
	[Documentation]		Unlock specified cell
	[Arguments]			${cell_list}
	FOR	   ${cell}	  IN	@{cell_list}
		Log to console		\nUnlocking cell : ${cell}
		COAM.unlock			dist_name=${Cell_dist}-${cell}	timeout=180				connection=${connection}
	END
	Log to console					\nWaiting for cell to be onAir
	Wait Until Keyword Succeeds		30 times	10			Check cell details		${Cell_dist}-${cell}

Unblock cells
	[Documentation]		Unblock specified cell
	[Arguments]			${cell_list}
	FOR	   ${cell}	  IN	@{cell_list}
		Log to console		\nUnblocking cell : ${cell}
		COAM.unblock_cell	 dist_name=${Cell_dist}-${cell}		timeout=180		connection=${connection}
	END
	Log to console					\nWaiting for cell to be onAir
	Wait Until Keyword Succeeds		30 times	10	  	Check cell details		${Cell_dist}-${cell}

Bar cells
	[Documentation]		Change CA cells to barred status
	[Arguments]			${cells}
	FOR	   ${cell}	IN	@{cells}
		Parameter value change		${LNBTS_dist}/LNCEL-${cell}/SIB-0			cellBarred		barred
	END

Unbar cells
	[Documentation]		Change CA cells to unbarred status
	[Arguments]			${cells}
	FOR	   ${cell}	IN	@{cells}
		Parameter value change		${LNBTS_dist}/LNCEL-${cell}/SIB-0			cellBarred		notBarred
	END

Block and unblock cells
	[Documentation]		Block and Unblock specified cell
	[Arguments]			${cell_list}	${loop}=1
	Log to console		\nBlocking and unblocking cell for ${loop} iteration
	FOR		${value}	   IN RANGE	   ${loop}
		Block cells			${cell_list}
		Unblock cells		${cell_list}
	END

Lock and unlock cells in loop
	[Arguments]			${cell_list}	${loop}=1
	[Documentation]		Lock and Unlock specified cell
	Log to console		\nIteration: ${loop}
	FOR	   ${value}	   IN RANGE	   ${loop}
		Lock and unlock cells		${cell_list}
	END

Lock and unlock cells
	[Arguments]			${cell_list}
	[Documentation]		Lock and Unlock specified cell
	Log to console		\nLocking and unlocking cell : ${cell_list}
	Lock cells			${cell_list}
	[Teardown]			Unlock cells		${cell_list}

Check build file and Upgrade build
    [Documentation]     Check the build file and download to testpc
	[Arguments]			${Active_build}
    ${current_sw}    	Check current software
    Run keyword if		"${current_sw}" != "${Active_build}"    Update BTS software		${Active_build}
    ...    ELSE			Log to console    \nPlanned software is already active in BTS ${BTS_IP}

Update BTS software
	[Documentation]			Upgrade software build in BTS
	[Arguments]				${Active_build}
	Check file in vm		${Active_build}
	Log to console			\nUpdating software in BTS ${BTS_IP} to ${Active_build}
	COAM.update_software	sw_package=${download_path}/${Active_build}${File_extension}	should_activate=True
	...						timeout=${update_timeout}	 connection=${connection}
	Log to console			\nSoftware update completed, rebooting BTS ${BTS_IP} and waiting for reconnection
	Sleep					5m		reason=Wait for reboot and reconnection
	#COAM.reset_admin		connection=${connection}
	Log to console			\nWaiting for BTS status to be OnAir
	Wait Until Keyword Succeeds	   15 times	   60	 Check BTS is OnAir
	${current_sw}			Check current software
	Run keyword if			"${current_sw}" == "${Active_build}"	Log to console	  \nSoftware update successfull
	...		ELSE			Log to console	  \nSoftware update failed
	Should Be Equal As Strings	  ${current_sw}	   ${Active_build}
	Log to console			\nDeleting build file ${Active_build}${File_extension}
	RUN						rm ${download_path}/${Active_build}${File_extension}

Rollback BTS software
	[Documentation]			Rollback BTS to passive partition
	Log to console			\nSoftware rollback started
	COAM.rollback_software	timeout=${update_timeout}	 connection=${connection}
	Log to console			\nSoftware rollback completed, waiting for reconnection
	Sleep					5m		reason=Wait for reboot and reconnection
	#COAM.reset_admin		connection=${connection}
	Log to console			\nWaiting for BTS status to be OnAir
	Wait Until Keyword Succeeds	   15 times	   60	 Check BTS is OnAir
	${current_sw}			Check current software
	Run keyword if			"${current_sw}" != "${Active_build}"	Log to console		\nSoftware rollback successfull
	...						ELSE		Log to console			\nSoftware rollback failed
	Should Not Be Equal As Strings		${current_sw}			${Active_build}

Check file in vm
	[Documentation]		Check the build file in testpc
	[Arguments]			${Build}
	${files}			OperatingSystem.List Files In Directory		${download_path}
	${val} 				Set variable								False
	FOR	   ${file}	  IN	@{files}
		${val}	Run keyword if	"${file}" == "${Build}${File_extension}"	Set variable	True
		...		ELSE			Set variable	 False
		Run keyword if			"${file}" == "${Build}${File_extension}"	Log to console	\nBuild file ${file} is already present in vm
		Exit For Loop If		${val} == True
	END
	Run keyword if				${val} == False	   Download build		${Build}

Download build
	[Documentation]	Download build to test pc
	[Arguments]		${Build}
	${Branch}		Split string	${Build}	_
	Log to console	\nPlanned build branch is ${Branch}[0]
	Log to console	\nPlanned build is ${Build}
	${File}			Setvariable		${Build}${File_extension}
	${cmd}			set variable	wget -o ${OUTPUT_DIR}/wget_download_log.txt ${wget_link}/${Branch}[0]/${Build}/${File}
	Log to console	\nDownloading build ${Build} to path ${Download_path}, it may take some while
	Log to console	\nRunning command : ${cmd}
	${rc}			Run And Return Rc			cd ${Download_path} && timeout ${Build_download_timeout} ${cmd}
	${output}		OperatingSystem.Get File	${OUTPUT_DIR}/wget_download_log.txt
	Log				${output}
	Run Keyword If	${rc} == ${0}		Log to console		\nDownload successfull
	...		ELSE	Run keywords		RUN					rm ${Download_path}/${Build}${File_extension}
	...		AND		Log to console		\n${output}
	...		AND		Log to console		\n\nDownload failed
	Should be equal	${rc}	${0}

Check current software
	[Documentation]		Check current software in BTS
	${Build}			COAM.get_sw_version		connection=${connection}
	@{sw_list}			String.Split String		${Build}	 _
	${status}			Run Keyword And Return Status		Should Be True		${sw_list[2]}==9999
	${current_trunk_sw}	Run Keyword If		'${status}'=='True'		Replace String		${Build}		${sw_list[0]}	  SBTS00
	...					ELSE				Set variable	${Build}
	Log to console		\nCurrent software in BTS ${BTS_IP} is ${Build}
	[Return]			${current_trunk_sw}

Start and verify Pcell and Scell data transfer
	[Documentation]		Start data transfer and check throughput
	[Arguments]			${CA}					${value}=${0}
	${Pcell_tput_dl}	${Pcell_tput_ul}		Start data transfer in Pcell
	${Scell_tput_dl}	${Scell_tput_ul}		Start data transfer in Pcell and Scell		${CA}
	Verify throughput	${Scell_tput_dl}		${Pcell_tput_dl}		${value}
	Verify throughput	${Scell_tput_ul}		${Pcell_tput_ul}		${value}
	[Return]			${Scell_tput_dl}		${Scell_tput_ul}

Verify throughput
	[Documentation]	Verify throughput
	[Arguments]		${Pcell_tput}	${Scell_tput}	${value}
	${status_1}		Evaluate		${Scell_tput}-${Pcell_tput}
	${status_2}		Evaluate		${status_1}>${value}
	Run keyword and continue on failure		Should be True		${status_2}

Start data transfer in Pcell
	[Documentation]	Start data transfer in primary cell by locking secondary cell
	${Value_dl}		${Value_ul}		Start data transfer in legacy UE
	[Return]		${Value_dl}		${Value_ul}

Start data transfer in legacy UE
	[Documentation]	Start legacy UE data transfer
	[Arguments]		${tput_dl}=${throughput_dl}	${tput_ul}=${throughput_ul}	${DCAP_val}=False	${set_cell_value}=False
	...				${Attenuate_cells}=False	${CA}=None
	${Value_dl}		${Value_ul}		Wait Until Keyword Succeeds	${Call_retry} times     30 	Attach ue and start data transfer
	...				${UE_alias}		${capabilities}	${tput_dl}	${tput_ul}	${Data_transfer_timeout}	DCAP=${DCAP_val}
	...				set_cell=${set_cell_value}		Attenuate_CA_cells=${Attenuate_cells}	CA=${CA}
	[Return]		${Value_dl}		${Value_ul}

Start data transfer in Pcell and Scell
	[Documentation]	Start data transfer to check CA
	[Arguments]		${CA}
	${Value_dl}		${Value_ul}	Start data transfer in legacy UE	tput_dl=${throughput_dl_${CA}}	tput_ul=${throughput_ul_${CA}}
	...																DCAP_val=True	Attenuate_cells=True		CA=${CA}
	[Return]		${Value_dl}	${Value_ul}

Start DL and UL data transfer in NBIOT and Legacy UE
	[Documentation]		Start data transfer in NBIOT and legacy UE
	Start data transfer in legacy UE
	Wait Until Keyword Succeeds    ${Call_retry} times     30 	Start NBIOT data transfer

Start NBIOT data transfer
	[Documentation]			Start data transfer in NBIOT UE
	#Block cells				${NBIOT_Cells}
	#Restart NBIOT UE
	Attach NBIOT UE			${NBIOT_UE}
	NBIOT Data transfer		ul
	NBIOT Data transfer		dl
	Log to console			\nWaiting for data transfer
	#ute_ue.await data transfer finish		ul_${NBIOT_UE}
	#ute_ue.await data transfer finish		dl_${NBIOT_UE}
	Sleep					${NBIOT_duration}			reason=Wait for data transfer
	${status}				Run keyword and Return status		NBIOT throughput check		ul
	Run Keyword If			'${status}'=='False'		Log   NBIOT UL data transfer failed !!!    WARN
	${status}				Run keyword and Return status		NBIOT throughput check		dl
	Run Keyword If			'${status}'=='False'		Log   NBIOT DL data transfer failed !!!    WARN
	#[Teardown]				Unblock cells	${NBIOT_Cells}

NBIOT Data transfer
	[Documentation]					Start data transfer in NBIOT UE
	[Arguments]						${direction}				${NBIOT_UE}=${NBIOT_UE}
	Log to console					\nStarting ${direction} data transfer in ${NBIOT_UE} for ${NBIOT_duration} duration
	ute_ue.start data transfer		${direction}_${NBIOT_UE}	${NBIOT_UE}	   ${direction}	   duration=${NBIOT_duration}
	...								protocol=${NBIOT_protocol}	throughput=${NBIOT_tput}

NBIOT throughput check
	[Documentation]		Check NBIOT throughput
	[Arguments]			${direction}	${NBIOT_UE}=${NBIOT_UE}
	Log to console		\nChecking ${direction} throughput in ${NBIOT_UE}
	${exec_status}		${value}	Run keyword and ignore error	verify throughput with datagram loss
	...																dt_name=${direction}_${NBIOT_UE}	max_allowed_datagram_loss=${NBIOT_loss}
	Run Keyword If		'${exec_status}' == 'FAIL'		Log to console	   \nDatagram loss ${direction}: ${exec_status} => ${value}
	ute_ue.verify average throughput with deviation		${direction}_${NBIOT_UE}	   ${NBIOT_tput}		${NBIOT_deviation}

Attach NBIOT UE
	[Documentation]		Attach NBIOT UE
	[Arguments]			${UE}		${attempt}=3
	ute_ue.Detach Ue 	${UE}
	FOR	   ${i}	   IN RANGE	   ${attempt}
		Log to console		\nAttempting to attach NBIOT UE, Loop : ${i}
		${status}			Run keyword and return status	ute_ue.Attach ue		${UE}
		Exit For Loop If	${status}
		sleep				60s								reason= Wait for NBIOT command to complete
	END
	Should be True			${status}
	Send command to UE		${NBIOT_UE}		at+cgpaddr

Detach NBIOT UE
	[Documentation]			Detach NBIOT UE
	Log to console			\Detach NBIOT UE
	ute_ue.detach ue		${UE}
	sleep					10s					reason= Wait for NBIOT command to complete

Restart NBIOT UE
	[Documentation]			Restart NBIOT UE using AT command
	Log to console			\nRestarting NBIOT UE
	Sleep					60s				reason= Wait before NBIOT restart
	Send command to UE		${NBIOT_UE}		at+cfun=1,1		#Restart NBIOT UE
	Sleep					100s			reason= Wait for NBIOT restart

Send command to UE
	[Documentation]		Send command to NBIOT UE
	[Arguments]			${alias}
	...					${at_cmd}
	...					${timeout}=20
	Log to console		\nSending command ${at_cmd} to ${alias}
	${out_result}		ute_ue.Send At Cmd To Ue	alias=${alias}
	...												at_cmd=${at_cmd}
	...												timeout=${timeout}
	LOG					${out_result}
	[Return]			${out_result}

Verify BLER and MCS
	Log			\nVerification skipped

Verify CA in EMIL
	[Documentation]		verify CA in EMIL logs
	[Arguments]			${Dcap_log}		${CA}
	Set global variable	${Dcap_status}	Verification started
	${CA_validate}		Set variable	UL Primary Cell|UL Secondary Cell|DL Primary Cell|DL Secondary Cell1
	@{check_2CC}		Create list
	...		rrcConnectionReconfiguration::sCellToAddModList,physCellId-r10 367|${CA_validate}
	@{check_3CC}		Create list
	...		rrcConnectionReconfiguration::sCellToAddModList,physCellId-r10 267,physCellId-r10 367|${CA_validate}|DL Secondary Cell2
	Verify Emil logs	${check_${CA}}	${Dcap_log}
	Set global variable	${Dcap_status}	Verified

Reset RMOD
	[Documentation]		Reset RMOD of BTS
	[Arguments]			${cell}		${count}
	FOR	   ${index}		IN RANGE	${count}
		Log to console		\nPerform RMOD reset, Loop : ${index}
		${cell_status}		COAM.get_cell_specific_info	   cell_id=${Cell_dist}-${cell}	  connection=${connection}
		${Full_dist_name}	Set variable	${cell_status['carrierList'][1]['antennaLineId']['internal']}
		${dist}	${Antenna}	Split String	${Full_dist_name}	/PHYANT		1
		COAM.reset_unit		dist_name=${dist}	reset_type=Warm	   timeout=300s	   connection=${connection}
		Log to console		\nWaiting for cell to be onAir
		Wait Until Keyword Succeeds		30 times	10		Check cell details		${Cell_dist}-${cell}
		Wait Until Keyword Succeeds		30 times	10		Check cell status
	END

Reset BBMOD
	[Documentation]		Reset BBMOD of BTS
	[Arguments]			${BBMOD}		${cell}		${count}
	FOR	   ${index}		IN RANGE		${count}
		Log to console		\nPerform BBMOD reset, Loop : ${index}
		COAM.reset_unit		dist_name=${BBMOD_dist}-${BBMOD}	reset_type=Warm	   timeout=300s	   connection=${connection}
		Log to console		\nWaiting for cell to be onAir
		Wait Until Keyword Succeeds		30 times	10		Check cell details		${Cell_dist}-${cell}
		Wait Until Keyword Succeeds		30 times	10		Check cell status
	END

Reset Unit
	[Documentation]	Reset any Unit of BTS
	[Arguments]		${unit}		${count}
	${cell_status}	COAM.get_cell_specific_info	   cell_id=${Cell_dist}-${cell}	  connection=${connection}
	FOR	   ${index}	   IN RANGE	   ${count}
		Log to console			\nPerform ${unit} reset, Loop : ${index}
		Perform unit reset		${unit}
		Sleep					60s
	END

Perform unit reset
	[Documentation]	Permform RMOB/BBMOD reset
	[Arguments]		${unit}
	${units}		COAM.get_ids_for_all		${unit}				connection=${connection}
	Log to console	\nPerforming ${unit} reset\n
	FOR	   ${item}	  IN	@{units}
		COAM.reset_unit	   dist_name=${item}	reset_type=Warm		timeout=300s	   connection=${connection}
	END
	Wait for BTS OnAir

Reset RAT
	[Documentation]	Perform LTE/NR reset
	[Arguments]		${RAT}		${count}
	FOR	   ${index}	   IN RANGE	   ${count}
		Log to console	\nPerform ${RAT} rat reset, Loop : ${index}
		COAM.rat_reset	${RAT}	  timeout=600s	  connection=${connection}
		Wait for BTS OnAir
	END

Reset site
	[Documentation]		Restart BTS
	[Arguments]			${count}=1
	FOR	   ${index}	   IN RANGE	   ${count}
		Log to console		\nPerform BTS reset, Loop : ${index}
		COAM.reset			reset_coverage=Site		wait_for_reconnection=True		timeout=300s		connection=${connection}
		#COAM.reset_admin	connection=${connection}
		Wait for BTS OnAir
	END

Check and verify 2CC counters
	[Documentation]			Collect and verify 2CC counters
	[Arguments]				${current}				${previous}
	Run keyword and continue on failure				Check 2CC counters			${current}
	${status}		Run keyword and Return status	Verify 2CC counters			${current}		${previous}
	Run keyword and continue on failure				Should be True				${status}
	Run Keyword If	'${status}'!='True'				Collect snapshot from BTS	Name=Snapshot_loop_${current}.zip

Check and verify 3CC counters
	[Documentation]			Collect and verify 3CC counters
	[Arguments]				${current}				${previous}
	Run keyword and continue on failure				Check 3CC counters			${current}
	${status}		Run keyword and Return status	Verify 3CC counters			${current}		${previous}
	Run keyword and continue on failure				Should be True				${status}
	Run Keyword If	'${status}'!='True'				Collect snapshot from BTS	Name=Snapshot_loop_${current}.zip

Check and verify NBIOT counters
	[Documentation]				Collect and verify NBIOT related counters
	[Arguments]					${current}			${previous}
	Run keyword and continue on failure				Check NBIOT counters		${current}
	${status}		Run keyword and Return status	Verify NBIOT counters		${current}		${previous}
	Run keyword and continue on failure				Should be True				${status}
	Run Keyword If	'${status}'!='True'				Collect snapshot from BTS	Name=Snapshot_loop_${current}.zip

Check 2CC counters
	[Documentation]		Collect 2CC counters
	[Arguments]			${count}			${delay}=${counter_wait_time}
	#Log to console		\nSleeping until next counter interval
	ta5g_pm_counters.wait_for_next_full_pm_interval
	Log					${delay}
	#Sleep				${delay}			reason=Wait for next counter interval
	Check counters		${2CC_Counters}		${Pcell}		${count}
	#Check counters		${2CC_Counters}		${Scell_2CC}[0]		${count}

Check 3CC counters
	[Documentation]		Collect 3CC counters
	[Arguments]			${count}			${delay}=${counter_wait_time}
	#Log to console		\nSleeping until next counter interval
	ta5g_pm_counters.wait_for_next_full_pm_interval
	Log					${delay}
	#Sleep				${delay}			reason=Wait for next counter interval
	Check counters		${3CC_Counters}		${Pcell}		${count}
	#Check counters		${3CC_Counters}		${Scell_3CC}[0]		${count}
	#Check counters		${3CC_Counters}		${Scell_3CC}[1]		${count}

Check NBIOT counters
	[Documentation]		Collect NBIOT counters
	[Arguments]			${count}				${delay}=${counter_wait_time}
	#Log to console		\nSleeping until next counter interval
	ta5g_pm_counters.wait_for_next_full_pm_interval
	Log					${delay}
	#Sleep				${delay}			reason=Wait for next counter interval
	Check counters		${NBIOT_Counters}		${NBIOT_Cell_configured}	${count}
	Check counters		${UE_counters}			${NBIOT_host_Cell}			${count}
	Check counters		${overload_counters}	${NBIOT_host_Cell}			${count}

Check counters
	[Documentation]		Check counters
	[Arguments]	   		${counter}		${cell}		${count}
	FOR		${check}	IN	 @{counter}
		${value}	Run keyword and continue on failure		Counter value	${check}	${cell}
		Run keyword and continue on failure		Set test Variable	${${check}_${cell}_${count}}	 ${value}
	END

Verify 2CC counters
	[Documentation]		Verify 2CC counters
	[Arguments]			${val_1}			${val_2}
	Verify counters		${2CC_Counters}		${Pcell}		${val_1}	${val_2}
	#Verify counters	${2CC_Counters}		${Scell_2CC}[0]		${val_1}	${val_2}

Verify 3CC counters
	[Documentation]		Verify 3CC counters
	[Arguments]			${val_1}			${val_2}
	Verify counters		${3CC_Counters}		${Pcell}		${val_1}	${val_2}
	#Verify counters	${3CC_Counters}		${Scell_3CC}[0]		${val_1}	${val_2}
	#Verify counters	${3CC_Counters}		${Scell_3CC}[1]		${val_1}	${val_2}

Verify NBIOT counters
	[Documentation]		Verify NBIOT counters
	[Arguments]			${val_1}				${val_2}
	Verify counters		${NBIOT_Counters}		${NBIOT_Cell_configured}	${val_1}	${val_2}
	Verify counters		${UE_counters}			${NBIOT_host_Cell}			${val_1}	${val_2}
	Verify counters		${overload_counters}	${NBIOT_host_Cell}			${val_1}	${val_2}	operator=${Equal}

Verify counters
	[Documentation]		Verify counters
	[Arguments]			${Counters}		${cell}		${val_1}	${val_2}	${operator}=${Greater}
	FOR	   ${counter}	 IN	   @{Counters}
		${Value}	Evaluate	${${counter}_${cell}_${val_1}} - ${${counter}_${cell}_${val_2}}
		${status}	Evaluate	${Value} ${operator} ${Counters_val.${counter}}
		Run keyword and continue on failure		Should be True		${status}
	END

Change modulation scheme
	[Documentation]				Change modulation scheme
	[Arguments]					${Value}							${direction}
	Parameter value change		${LNBTS_dist}/LNCEL-${Pcell}		actModulationScheme${direction}		${Value}
	Parameter value change		${LNBTS_dist}/LNCEL-${Scell_3CC}[0]		actModulationScheme${direction}		${Value}
	Parameter value change		${LNBTS_dist}/LNCEL-${Scell_3CC}[1]		actModulationScheme${direction}		${Value}

Link SCOUT SCF to Configuration ID for Reporting
	[Documentation]			Link Scout
    [Arguments]				${node_id}=${0}			${node_type}=gnb    ${tl_name_only}=${Hostname}
    ${node_type_Name}		Run Keyword If			"${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF			"${node_type}"=="enb"	Set Variable  	eNB
    ...     ELSE			Fail    				Wrong node_type '${node_type}'! allowed: enb|gnb
	Log						${node_id}
    Log To Console			\nSCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}	Set Variable			${tl_name_only}
    ${external_scf_id}		Request Scout SCF		${scout_testline_name}
    ${TC_ID}				Set Variable			ute:id:${external_scf_id}
    Set Tags				${TC_ID}
	Set Suite variable		${external_scf_id}

Request Scout SCF
	[Documentation]			Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW
    [Arguments]				${scout_testline_name}
    scout.setup_scout		scout_testline_name=${scout_testline_name}
    ${external_scf_id}		scout.request_scf   use_scout_internal_id=True
    [Teardown]				scout.teardown_scout_api
    [Return]				${external_scf_id}

Report to QC
	Wait Until Keyword Succeeds		2min    10s      Link SCOUT SCF to Configuration ID for Reporting
	Set QC Id
	Run keyword if					"${Update_to_QC}" == "TRUE"		Update to Reporting portal

Update to Reporting portal
	[Documentation]		Report the status to QC
	Log to console		\nUpdating result to QC as ${TEST STATUS}
	${Res}		Run keyword if	"${TEST STATUS}" == "PASS"		Set variable	passed
	...			ELSE			Set variable	 failed
	${Link}		Report To Rp	name=${TEST NAME}		result=${Res}			ca=${ca}
	...																			testline=${Hostname}	build=${Active_build}	qc_domain=${qc_domain}
	...																			qc_project=${qc_project}		qc_id=${QC_ID}			label=
	...																			tool=WebEM				kpi_results=			links=
	...																			tc_execution_id=${external_scf_id}
	Log to console		\nReportal portal link : \n${Link}

Get Hostname
	[Documentation]		Get hosename of test machine
	${output}			Run			hostname
	${Hostname}			String.Replace String	 string=${output}	   search_for=-	   replace_with=_
	Set Suite variable	${Hostname}

Set QC Id
	[Documentation]		Get QC ID of testcase
	@{sw_list}			String.Split String		${Active_build}	 _
	${status}			Run Keyword And Return Status		Should Be True		${sw_list[2]}==9999
	${Tag}				Run Keyword If		'${status}'=='True'					Set Variable    FL00
    ...     			ELSE    			Set Variable   						${sw_list[0]}
	${QC_ID}    		Get from Dictionary	${${TEST_NAME}}						QC_ID_${Tag}
	Set Suite variable	${QC_ID}
	Set Tags    		${QC_ID}
