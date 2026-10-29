***Settings***
Documentation
	...		[Procedure]				"The test case is planned to validate delta modification of mplane parameters"
	...		[Date]					"07-07-17"
	...		[Author]				"Abhishek Gupta"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"MPLANE"

##Force Tags    SM TRSIV Test 1        SBTS00        SBTS19A        QCD_MN_CDS        QCP_SRAN_BTS_IV        CR2
#Force Tags    QCD_MN_RAN        QCP_RAN_ET
Force Tags    SBTS00    SBTS22R3


variables       ta_e2e_bts_trs_fw
Library		Collections
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Test Cases ***
[1][2.0] TRS_Delta_changes_of_M_Plane_Parameters_SR001003
    Perform Commissioning       scf_file=${basic_asoe}   verify_bts_status=False     timeout=600
    Sleep   200
	Get IPs
	Perform Recommissioning 	type=param	 param_path=${mplane_dscp_moc_path}    value=36	  skip_parameter_relation_errors=${True}
    ... 	timeout=300   operation=update
	Sleep	120
	Traffic Capture Start		capture_device=vm_eth3_interface		alias=initial_mplane
	Setup Oamops	bts_host=${mplane_ip}		alias=initial_mplane
	${mplane_initial_dscp} = 	Get Parameter		param_path=${mplane_dscp_moc_path}	alias=initial_mplane
	${filename}=		Traffic Capture Stop		 alias=initial_mplane
	Analyse Pcap 		pcap_filename=${filename}		 analysis=verify_initial_mplane_dscp		filter_file_name=${traffic_filer_file_name}
#	Perform Recommissioning      type=delta    delta_file=${mplane_delta_file_path}      timeout=300     alias=initial_mplane
    Sleep   120
	${mplane_new_ip} = 	Get Parameter		param_path=${mplane_ip_moc_path}		## Using default session
	Traffic Capture Start		capture_device=vm_eth3_interface		alias=new_mplane
	Setup Oamops                 bts_host=${mplane_new_ip}		alias=new_mplane
	${mplane_modified_dscp} = 	Get Parameter		param_path=${mplane_dscp_moc_path}	alias=new_mplane
	${filename}=		Traffic Capture Stop		 alias=new_mplane
	Analyse Pcap 		pcap_filename=${filename}		 analysis=verify_modified_mplane_dscp		filter_file_name=${traffic_filer_file_name}

    Reset Bts    should_be_onair=false    timeout=600
    Sleep    300
    Get IPs
    Perform Recommissioning     type=param   param_path=${mplane_dscp_moc_path}    value=36   skip_parameter_relation_errors=${True}
    ...    timeout=300   operation=update
    Sleep   120
    Traffic Capture Start       capture_device=vm_eth3_interface     alias=initial_mplane
    Setup Oamops    bts_host=${mplane_ip}       alias=initial_mplane
    ${mplane_initial_dscp} =    Get Parameter       param_path=${mplane_dscp_moc_path}  alias=initial_mplane
    ${filename}=        Traffic Capture Stop         alias=initial_mplane
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_initial_mplane_dscp        filter_file_name=${traffic_filer_file_name}

#    Perform Recommissioning      type=delta    delta_file=${mplane_delta_file_path}      timeout=300     alias=initial_mplane
    Sleep   120

    ${mplane_new_ip} =  Get Parameter       param_path=${mplane_ip_moc_path}        ## Using default session
    Traffic Capture Start       capture_device=vm_eth3_interface     alias=new_mplane
    Setup Oamops                 bts_host=${mplane_new_ip}      alias=new_mplane
    ${mplane_modified_dscp} =   Get Parameter       param_path=${mplane_dscp_moc_path}  alias=new_mplane
    ${filename}=        Traffic Capture Stop         alias=new_mplane
    Analyse Pcap        pcap_filename=${filename}        analysis=verify_modified_mplane_dscp       filter_file_name=${traffic_filer_file_name}
    [Teardown]  Close All Operations

*** Keywords ***
Get IPs
	${mplane_ip} = 	Get Parameter		param_path=${mplane_ip_moc_path}
	Set Suite Variable		${mplane_ip}		${mplane_ip}
	${lte_cplane1} = 	Get Parameter		rat=lte			param_path=${lte_cplane1_ip_moc_path}
	Set Suite Variable		${lte_cplane1}		${lte_cplane1}

All Calls
	Call Setup	lte=device_1:data	wcdma=device_1:data	gsm=device_1:voice	parallel=${True}
	Call Start	lte=device_1:data	profile=udp_ul
	Call Start	lte=device_1:data	profile=udp_dl
	Call Start	wcdma=device_1:data	profile=udp_ul
	Call Start	wcdma=device_1:data	profile=udp_dl
	Call Start	gsm=device_1:voice
	Sleep	15
	Run Keyword And Ignore Error		Call Stop	lte=device_1:data	profile=udp_ul
	Run Keyword And Ignore Error		Call Stop	lte=device_1:data	profile=udp_dl
	Run Keyword And Ignore Error		Call Stop	wcdma=device_1:data	profile=udp_ul
	Run Keyword And Ignore Error		Call Stop	wcdma=device_1:data	profile=udp_dl
	Run Keyword And Ignore Error		Call Stop	gsm=device_1:voice

Close All Operations
	Run Keyword And Ignore Error		Teardown Oamops		alias=initial_mplane
	Run Keyword And Ignore Error		Teardown Oamops		alias=new_mplane
	Run Keyword And Ignore Error		Traffic Capture Stop		 alias=initial_mplane
	Run Keyword And Ignore Error		Traffic Capture Stop		 alias=new_mplane