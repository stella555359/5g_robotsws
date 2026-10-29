*** Settings ***
Documentation     [Procedure] "CB005820-A_Auto_Verification of CMP Key update automatically using Eesubjectname and Eesubjectaltname"
...               [Date] "Date of creation 16-12-2021"
...               [Author] "Nupur K"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB005820"
...               [Funtion_Hash_Tags] "CMP SAN"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] ASIB-9047
...               [Validation Date] 11-12-2021


Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Library		      SSHLibrary


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops



*** Variables ***
${Time_Diff}       10 min

*** Test Cases ***
[1]CB005820-Verification of CMP Key update automatically using Eesubjectname via admin
	Restore all Certificate
	Perform Recommissioning		type=delta	   delta_file=${CMP_KeyUpdate_Eesubjectname}      timeout=300
	Sleep   180
	Verify End Entity Certificate Installation
	Get CMP Parameters from Admin
	Schedule NE Certificate Time In WebEM
	Verify KUR Operation

*** Keywords ***
Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}
	Sleep     10

Verify End Entity Certificate Installation
	Get CMP Parameters from Admin
    Get Installed Certificate Details
	Should Be Equal      ${eeSubjectName}       ${Issued_To}
    Lists Should Be Equal        ${SAN_list}     ${BTS_SAN}     ignore_order=True

Get CMP Parameters from Admin
	${cmp_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}
    Set Suite Variable      ${cmp_dict}     ${cmp_dict}
	${eeSubjectName}=       Get From Dictionary    dictionary=${cmp_dict}    key=eeSubjectName
	${eeSubjectAltNames}=    Get From Dictionary    dictionary=${cmp_dict}    key=eeSubjectAltNames
	@{SAN_list}=      Create List
	FOR    ${SAN}     IN     @{eeSubjectAltNames}
	   Run Keyword IF       '${SAN}[subjectAltType]' == "DOMAIN"       Set Suite Variable    ${SAN_dict_Value}       DNS:${SAN}[subjectAltName]
        ...        ELSE        	 Set Suite Variable    ${SAN_dict_Value}       ${SAN}[subjectAltType]:${SAN}[subjectAltName]
   	   Append To List     ${SAN_list}	     ${SAN_dict_Value}
   	END
	Sort List     ${SAN_list}
    Set Suite Variable    	  ${SAN_list}       ${SAN_list}
	Set Suite Variable    	  ${eeSubjectName}       ${eeSubjectName}

Get Installed Certificate Details
	${certificate_details}=        Certificate Configure     operation=get_certificate_details         type=EndEntity     source=Operator
	...      timeout=120
#	${request_message}=         Get from Dictionary      ${certificate_details}      requestMessage
	Set Suite Variable       ${request_message}         ${certificate_details}
	${Issued_To}=   Get from Dictionary      ${request_message}[0]       issuedTo
	${Issued_To}=    Remove String    ${Issued_To}    ${SPACE}
	Set Suite Variable      ${Issued_To}        ${Issued_To}

	${Subject_Alternate_Name}=   Get from Dictionary      ${request_message}[0]       subjectAlternateName
	@{BTS_SAN}=     Split String     ${Subject_Alternate_Name}        ,
	Set Suite Variable      ${BTS_SAN}        ${BTS_SAN}

Schedule NE Certificate Time In WebEM
	Execute command on ENodeB       date -u
	@{DateTime}=     Split String     ${stdout}       ${SPACE}
	Run Keyword and Ignore Error       Remove Values From List      ${DateTime}     ${EMPTY}
	${ScheduleTime}=    Add Time To Time     ${DateTime}[3]     ${Time_Diff}      timer	 exclude_millis=yes
	${Time_Split}=  Split String From Right    ${ScheduleTime}    :    max_split=1
	${Time_to_Schedule}=    Get From List     ${Time_Split}    0
	Log    	${Time_to_Schedule}
	Perform Recommissioning        type=param           param_path=CMP-1:neCertUpdateTimeSchedule     operation=update
	...    value=${Time_to_Schedule}    timeout=300

Verify KUR Operation
	Traffic Capture Start   		capture_device=vm_eth3_interface     alias=cmp_kur
	Sleep     ${Time_Diff}
	${cmp_pcap}=    Traffic Capture Stop    	alias=cmp_kur
	${mplaneIp} =    Get Parameter    param_path=${Mplane_Ip_path}
	${server_host}=       Get From Dictionary    dictionary=${cmp_dict}    key=serverHost
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_kur           filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_kup           filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_certConf     filter_file_name=${traffic_filter_file_name}
	Analyse pcap    pcap_filename=${cmp_pcap}      analysis=cmp_pkiconf      filter_file_name=${traffic_filter_file_name}
