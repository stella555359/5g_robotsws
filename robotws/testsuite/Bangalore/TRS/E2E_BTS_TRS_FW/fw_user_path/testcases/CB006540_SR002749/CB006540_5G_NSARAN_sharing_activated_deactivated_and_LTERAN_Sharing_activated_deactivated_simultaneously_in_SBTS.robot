*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to Verification of flow control"
	...		[Date]					"08-15-2021"
	...		[Author]				"Madhu Chinthakindi"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"RANSHARING"
	...   	[Feature_ID]         	"5GC001464","CB006540","SR002749"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"5gSBTS_9047"
	...   	[Config] 				"cfg file varible should with given as regEx metion, refer testcases_variable.json for the same"

Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/CB006540_SR002749_Common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops

*** Test Cases ***
[1]TRS_CB006540_5G_NSARAN_sharing_activated_deactivated_and_LTERAN_Sharing_activated_deactivated_simultaneously_in_SBTS.
	[Documentation]		"The test case to verify call stability with and without feature"
	Perform Commissioning             verify_bts_status=${False}		timeout=600
	Verify Bts Status 		req_rat=lte	 	should_be_onair=${True}
	Verify RMOD is up
	Perform NR-LTE onAir
	Read IP Parameters
	Verify Call		call_log_feature_disable
    Enable 5GNSA Ransharing
    Enable LTE Ransharing
	Restart BTS and verify coming up
	Verify Call		call_log_feature_enable

***Keywords***
Re initiate call setup
	[Documentation]		"The test keyword is to verify reinitiate call by terminating previous call"
	Perform Call setup 		${basic_nsa_call}
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status 		req_rat=lte	 	should_be_onair=${True}
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status 		req_rat=5g	 	should_be_onair=${True}

Enable 5GNSA Ransharing
	[Documentation]		"The test keyword is to verify enable NSA ransharing and verify 5gRat behaviour"
    Perform Recommissioning        type=delta        delta_file=${featureEnable}        timeout=600
	verify 5Grat rest

Restart BTS and verify coming up
	[Documentation]		"The test keyword is to restart bts and verify airphone and iphy detection"
	Reset 	    operation=reset_bts     should_be_onair=${False}
	Verify RMOD is up
	${5gOnAirStatus}=         Run Keyword And Return Status      Verify Bts Status 		req_rat=5g	 	should_be_onair=${True}
	${lteOnAirStatus}=         Run Keyword And Return Status     Verify Bts Status 		req_rat=lte	 	should_be_onair=${True}
	Run Keyword If     	${5gOnAirStatus}== False    	RebootAirphone
	Run Keyword If     	${5gOnAirStatus}== False    	RebootIphy
	Execute Cus Command		config update
	Execute Cus Command		config remote update
	Verify RMOD is up
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status 		req_rat=lte	 	should_be_onair=${True}
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status 		req_rat=5g	 	should_be_onair=${True}

RebootAirphone
	[Documentation]		"The test keyword is to restart Airphone"
   Setup Remote Access		remote_device=airphone         alias=airphone_reset
   Remote Command Execute		command=reboot
   [Teardown]    Teardown Remote Access         alias=airphone_reset

RebootIphy
	[Documentation]		"The test keyword is to restart Iphy"
   Setup Remote Access		remote_device=iphy         alias=iphy_reset
   Remote Command Execute		command=reboot
   [Teardown]    Teardown Remote Access         alias=iphy_reset

verify 5Grat rest
	[Documentation]		"The test keyword is to verify whether 5G rat rest "
	${rmodStatus}=         Run Keyword And Return Status		Verify RMOD is up
	Run Keyword If     	${rmodStatus}== False    	RebootAirphone
	${rmodStatus}=         Run Keyword And Return Status		Verify RMOD is up
	Run Keyword If  ${rmodStatus}==False        Reset bts and perform cus update
	Verify RMOD is up
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status 		req_rat=5g	 	should_be_onair=${False}
	Wait Until Keyword Succeeds		15 min		30 sec 		Verify Bts Status		req_rat=LTE	 	should_be_onair=${True}

Reset bts and perform cus update
    Reset 	    operation=reset_bts     should_be_onair=${False}
    Execute Cus Command  config update
    Execute Cus Command  config remote update


Enable LTE Ransharing
	[Documentation]		"The test keyword is to verify whether LTE rat rest "
    Perform Recommissioning     type=param        param_path=${actTransportSeparationLte}     operation=update    value=false     timeout=300
   	verify BTS restart

verify BTS restart
	[Documentation]		"The test keyword is to verify whether BTS went down"
	${rmodStatus}=         Run Keyword And Return Status		Verify RMOD is up
	Run Keyword If  ${rmodStatus}==False        Reset bts and perform cus update
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status 		req_rat=5g	 	should_be_onair=${False}
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status 		req_rat=lte	 	should_be_onair=${False}


Perform NR-LTE onAir
	[Documentation]		"The test keyword is to bringup BTS onAir by performing call setup profile"
	Call Setup      5g=${MeNBin_Feature}:data   parallel=${False}    verify_attach=${False}   attach=${False}    ipv4_or_6=ipv4		timeout=800
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status 		req_rat=5g	 	should_be_onair=${False}
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status 		req_rat=lte	 	should_be_onair=${False}

Verify Call
	[Documentation]		"The test keyword is to verify NSA Calls"
	[Arguments]      ${wireshark_profile}
	Set Suite Variable	${wireshark_profile}		${wireshark_profile}
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status   	req_rat=5g 		should_be_onair=${True}
	Traffic Capture Start   capture_device=vm_eth3_interface     alias=${wireshark_profile}
	Perform Call setup 		${basic_nsa_call}
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status 		req_rat=lte	 	should_be_onair=${True}
	Wait Until Keyword Succeeds		15 min		30 sec		Verify Bts Status 		req_rat=5g	 	should_be_onair=${True}
	Execute Call Script 	${Call_scripts_basic_nsa_call}
	${pcap_file}=       Traffic capture stop	alias=${wireshark_profile}
	Set Suite Variable       ${pcap_file}
	verify attach
	[Teardown]    Run Keyword And Ignore Error   	Stop traffic and detach UE

verify attach
	[Documentation]		"The test keyword is to verify successful attach"
	Analyse Pcap 		pcap_filename=${pcap_file}		 analysis=verify_attach_req				filter_file_name=${traffic_filter_file_name}
	Analyse Pcap 		pcap_filename=${pcap_file}		 analysis=verify_attach_accept			filter_file_name=${traffic_filter_file_name}
	Analyse Pcap 		pcap_filename=${pcap_file}		 analysis=verify_attach_complete		filter_file_name=${traffic_filter_file_name}
	Analyse Pcap 		pcap_filename=${pcap_file}		 analysis=verify_Erab_Indication		filter_file_name=${traffic_filter_file_name}
	Analyse Pcap 		pcap_filename=${pcap_file}		 analysis=verify_Erab_Confirm			filter_file_name=${traffic_filter_file_name}

Read IP Parameters
	[Documentation]		"The test keyword is to read LTE ip parameters"
	${lte1_cplane1} = 	Get Parameter		param_path=${lte_cplane1_ipv4_moc_path}
	${mme_ip1} = 		Get Parameter		param_path=${lte_mme_ipv4_moc_path}
	Set Suite Variable	${lte1_cplane1}		${lte1_cplane1}
	Set Suite Variable	${mme_ip1}		${mme_ip1}

Verify Firewall rules
	[Documentation]		"The test keyword is to verify firewall rules"
    Setup Remote Access    remote_device=bts
    ${firewall_rules}=        Remote Command Execute      command=${firewallCmd}
	Should Contain       ${firewall_rules}        ${lte_uplane_rule}
	Should Contain       ${firewall_rules}        ${lte_cplane_rule}
	Should Contain       ${firewall_rules}        ${5g_uplane_rule}
	Should Contain       ${firewall_rules}        ${x2cplane_rule}
    [Teardown]    Teardown remote Access
