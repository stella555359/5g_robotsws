*** Settings ***
Documentation     [Procedure] "CB005999-A_Auto_Verification of CMP Key update automatically using Eesubjectname and Eesubjectaltname"
...               [Date] "Date of creation 27-06-2022"
...               [Author] "Eswarlal Abhishake T"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB005999"
...               [Funtion_Hash_Tags] "CMP SAN"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] ASIL-3723
...               [Validation Date] 11-12-2021


variables         ta_e2e_bts_trs_fw
Resource         taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot
Library           SSHLibrary
Resource    	  ${CURDIR}/../resources/common_keywords_5999.robot
Resource          ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]CB005999_Verification of static and dynamic SAN configuration for ECDSA certficates
    Restore all Certificate
	Perform Recommissioning		type=delta		delta_file=${ECDSA_SAN_config}		skip_parameter_relation_errors=${True}		timeout=400
    Sleep   60
	Read CMP Parameters 	ECDSA
    Certificate Configure       operation=install_cmp_certificate      key_pool_type=ECDSA       timeout=100
    Sleep  60
    Certificate Configure       operation=cmp_update_key      key_pool_type=ECDSA       timeout=100
    Sleep  60
    Get CMP Parameters from Admin
	Schedule NE Certificate Time In WebEM
    Get Installed Certificate Details
    Verify End Entity Certificate Installation

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
	${cmp_dict} =    Query Admin Infomodel    query=get object ${cmpecdsa_ip_path}
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
	${certificate_details}=        Certificate Configure     operation=get_certificate_details
	...         type=EndEntity     source=Operator   	timeout=120
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
	Perform Recommissioning        type=param           param_path=CMPECDSA-1:neCertUpdateTimeSchedule
	...     operation=update     value=${Time_to_Schedule}    timeout=300