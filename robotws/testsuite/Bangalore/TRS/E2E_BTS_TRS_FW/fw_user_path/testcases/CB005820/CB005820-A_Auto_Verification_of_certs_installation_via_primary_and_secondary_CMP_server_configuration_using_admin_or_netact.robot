*** Settings ***
Documentation     [Procedure] "CB005820-Verification of certs installation via primary and secondary CMP server configuration using admin"
...               [Date] "Date of creation 31-10-2021"
...               [Author] "Nupur K"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB005820-SR-A-c"
...               [Funtion_Hash_Tags] "CMP"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] 3293
...               [Validation Date] 31-10-2021



Resource          ${CURDIR}/../resources/common_keywords.robot
Library           ${CURDIR}/../resources/cmp.py


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Variables ***

*** Test Cases ***
[1]CB005820-Verification of certs installation via primary and secondary CMP server configuration using admin
	Preconditions	
	Trigger CMP IR for Primary CMP and Verify Auto IR
	Trigger CMP IR for Secondary CMP and Verify Auto IR
	Trigger CMP IR for Primary and Verify Manual IR	
	Trigger CMP IR for Secondary and Verify Manual IR

*** Keywords ***
Preconditions
	Run Keyword and Ignore Error        Restore all Certificate
	Read Mplane IP

Read Mplane IP	
	${mplaneIp} =    Get Parameter    param_path=${Mplane_Ip_path}
    Set Suite Variable    ${mplaneIp}    ${mplaneIp}

Read CMP IP details
	[Arguments]    ${Server}
	${cmp_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}     
	Run Keyword If    '${Server}' == 'Secondary'     Set Suite Variable       ${server_host_key}    secondaryServerHost   
    ...       ELSE    Set Suite Variable       ${server_host_key}    serverHost  
	${server_host}=       Get From Dictionary    dictionary=${cmp_dict}    key=${server_host_key}
	Set Suite Variable       ${server_host}    	${server_host} 
	${polling_timeout}=      Get From Dictionary    dictionary=${cmp_dict}       key=cmpPollingTimeout
	Set Suite Variable       ${polling_timeout}    	${polling_timeout} 

Trigger CMP IR for Primary CMP and Verify Auto IR
    Traffic Capture Start    capture_device=vm_eth3_interface    alias=primary
    Perform Recommissioning      type=delta     delta_file=${Correct_Primary_Incorrect_Secondary}     timeout=300
	Sleep   60
    Read CMP IP details       Primary
#	Certificate Configure     operation=install_cmp_certificate       timeout=120
	${cmp_pcap}=    Traffic Capture Stop    alias=primary
	Verify IR Operation     ${cmp_pcap}
	Restore all Certificate
	[TEARDOWN]       Run Keyword and Ignore Error       ${cmp_pcap}=    Traffic Capture Stop    alias=primary
	
Trigger CMP IR for Secondary CMP and Verify Auto IR
	Traffic Capture Start    capture_device=vm_eth3_interface     alias=secondary
    Perform Recommissioning      type=delta     delta_file=${Incorrect_Primary_Correct_Secondary}     timeout=300
	Sleep   60
	Read CMP IP details        Secondary
#	Certificate Configure     operation=install_cmp_certificate       timeout=120
	${cmp_pcap}=    Traffic Capture Stop    alias=secondary
	Verify IR Operation      ${cmp_pcap}
	Restore all Certificate
	[TEARDOWN]       Run Keyword and Ignore Error       ${cmp_pcap}=    Traffic Capture Stop    alias=secondary

Verify IR Operation
	[Arguments]    ${cmp_pcap}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_ir         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_ip         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_certConf         filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_pkiconf         filter_file_name=${traffic_filter_file_name}
	
Trigger CMP IR for Primary and Verify Manual IR	
    Traffic Capture Start    capture_device=vm_eth3_interface    alias=primary_polling
	Perform Recommissioning      type=delta     delta_file=${Correct_Primary_InCorrect_Secondary_Polling}     timeout=300
#	Sleep   60
	Read CMP IP details       Primary
#	Run Keyword And Ignore Error    certificate configure    operation=install_cmp_certificate    timeout=5
    Wait Until Keyword Succeeds    2 min    10    Verify cmp status    CMP_InitializationWaiting
#    Verify cmp status     CMP_InitializationWaiting
    accept certificate    ${mplaneIp}
	Sleep    10
#    Wait Until Keyword Succeeds    ${polling_timeout}    10    verify cmp status    CMP_InitializationOK
    Wait Until Keyword Succeeds     4 min    10    verify cmp status    CMP_InitializationOK
    ${cmp_pcap}=    Traffic Capture Stop    alias=primary_polling
	Restore all Certificate
	[TEARDOWN]    Run Keyword and Ignore Error        ${cmp_pcap}=    Traffic Capture Stop    alias=primary_polling

Trigger CMP IR for Secondary and Verify Manual IR
	Traffic Capture Start    capture_device=vm_eth3_interface    alias=secondary_polling
	Perform Recommissioning      type=delta     delta_file=${InCorrect_Primary_Correct_Secondary_Polling}     timeout=300
#	Sleep   60
	Read CMP IP details       Secondary
#	Run Keyword And Ignore Error    certificate configure    operation=install_cmp_certificate    timeout=5
    Wait Until Keyword Succeeds    2 min    10    Verify cmp status    CMP_InitializationWaiting
#    Verify cmp status     CMP_InitializationWaiting
    accept certificate    ${mplaneIp}
	Sleep    10
    ${polling_timeout}=      Evaluate       ${polling_timeout}+240
    Wait Until Keyword Succeeds    ${polling_timeout}    10    verify cmp status    CMP_InitializationOK
    ${cmp_pcap}=    Traffic Capture Stop    alias=secondary_polling
	Restore all Certificate
	[TEARDOWN]    Run Keyword and Ignore Error        ${cmp_pcap}=    Traffic Capture Stop    alias=secondary_polling

Verify cmp status
    [Arguments]    ${CMP_status_check}
    ${cmp_state_var} =    Query Admin Infomodel    query=get object ${cmp_r_moc_path}
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}
	
Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}
	Sleep     10
