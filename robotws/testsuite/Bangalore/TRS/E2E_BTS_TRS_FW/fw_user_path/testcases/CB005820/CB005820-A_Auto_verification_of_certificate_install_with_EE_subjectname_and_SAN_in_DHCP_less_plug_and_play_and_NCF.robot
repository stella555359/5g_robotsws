*** Settings ***
Documentation     [Procedure] "CB005820-A_Auto_verification of certificate install with EE subjectname & SAN in DHCP less plug and play & NCF"
...               [Date] "Date of creation 10-12-2021"
...               [Author] "Nupur K"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB005820"
...               [Funtion_Hash_Tags] "CMP,SAN,PNP"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] ASIB-9047
...               [Validation Date] 14-12-2021


Library           Collections
Resource          ${CURDIR}/../resources/common_keywords.robot
Library		      SSHLibrary


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops



*** Test Cases ***
[1]CB005820-verification of certificate install with EE subjectname & SAN in DHCP less plug and play
	Preconditions
	Set Autoconnection Parameters
	Verify End Entity Certificate Details

*** Keywords ***
Preconditions
	Run Keyword and Ignore Error     Restore all Certificate
	Reset   operation=reset_configuration     remove_operator_certificates=False      remove_user_account_credentials=False
	Sleep    180

Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}
	Sleep     10

Set Autoconnection Parameters
#	set autoconnection transport params     mPlaneIpAddress=${mPlane_IP_Address}      mPlaneIpPrefix=${mPlane_IP_Prefix}
#   ...         defaultGateway=${Gateway_IP}
#	...         identificationServerIpAddress=${Gateway_IP}        cmpServerIpAddress=${cmp_Server_IP}      cmpServerPort=${cmp_Server_Port}
#	...         caSubjectName=${CA_Subject_Name}    cmpDirectory=${cmp_Directory}      eeSubjectName=${eeSubjectName}
#	...         eeSubjectAltNames=${Subject_Alternate_Names}
#    ...      	timeout=180
    Set Autoconnection Transport Params       trs_ac_param_file=trs_profile.json 	 trs_ac_profile=ac_profile1	    timeout=180
    Sleep    180

Verify End Entity Certificate Details
	${certificate_details}=        Certificate Configure     operation=get_certificate_details        type=EndEntity     source=Operator
	...     timeout=120
	${Issued_To}=   Get from Dictionary      ${certificate_details}[0]       issuedTo
	${Issued_To}=    Remove String    ${Issued_To}    ${SPACE}
	Should be Equal       ${Issued_To}      ${eeSubjectName}

	${Subject_Alternate_Name}=   Get from Dictionary      ${certificate_details}[0]       subjectAlternateName
	@{BTS_SAN}=     Split String     ${Subject_Alternate_Name}           ,
    @{SAN_list}=      Create List
	FOR    ${SAN}     IN     @{Subject_Alternate_Names}
		Run Keyword IF       '${SAN}[subjectAltType]' == "DOMAIN"       Set Suite Variable    ${SAN_dict_Value}       DNS:${SAN}[subjectAltName]
        ...        ELSE        	 Set Suite Variable    ${SAN_dict_Value}       ${SAN}[subjectAltType]:${SAN}[subjectAltName]
   	   Append To List     ${SAN_list}	     ${SAN_dict_Value}
   	END
	Sort List     ${SAN_list}
    Lists Should Be Equal        ${SAN_list}     ${BTS_SAN}
