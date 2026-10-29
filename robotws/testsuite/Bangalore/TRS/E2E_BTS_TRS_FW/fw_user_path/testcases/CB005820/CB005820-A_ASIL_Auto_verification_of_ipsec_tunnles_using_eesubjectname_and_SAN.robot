*** Settings ***
Documentation     [Procedure] "CB005820-A_Auto_verification of ipsec tunnles using eesubjectname and SAN"
...               [Date] "Date of creation 22-12-2021"
...               [Author] "Nupur K"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB005820-A"
...               [Funtion_Hash_Tags] "CMP,IPSEC and SAN"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] 5G_ASIL_TL003
...               [Validation Date] 23-12-2021

Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]CB005820-Verification of ipsec tunnles using eesubjectname and SAN
	Restore all Certificate
    Perform Commissioning       scf_file=${Configuration_scf_basic}     verify_bts_status=False     timeout=400     alias=default
	Sleep   300
    Perform Recommissioning     type=delta   delta_file=${Configuration_delta_IPSEC_Tunnels}      timeout=300
    Sleep   120
    Install Certificate in BTS and Strongswan
	Sleep    10
	Verify IPSEC Tunnel status
	Install Certificate with End Entity Subject Name
	Verify Installation of Cert with End Entity Subject Name
	Verify IPSEC Tunnel status with End Entity Subject Name
	[TEARDOWN]     Postconditions

*** Keywords ***
Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}
	Sleep     10

Install Certificate in BTS and Strongswan
	Certificate Configure     operation=install_certificate     cert_file=${SHA256_cert}     cert_type=BtsTrustChain     cert_format=P12
	...    password=Nokia
	SSHLibrary.Open connection    ${config.Strongswan_ip}
	SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
	Execute Command     sudo rm -rf ${cert_PrivateKey}
	Execute Command     sudo rm -rf ${cert_Btspem}
	Execute Command 	sudo ln -s ${SHA256_cert_PrivateKey} ${cert_PrivateKey}
	Execute Command 	sudo ln -s ${SHA256_cert_Btspem} ${cert_Btspem}
	Execute Command 	sudo ipsec restart
	[TEARDOWN] 		SSHLibrary.Close Connection

Verify IPSEC tunnel status
    Execute command on ENodeB    ipsec status
	Log     ${stdout}
	Should Match Regexp		${stdout}	.*ESTABLISHED.*

Install Certificate with End Entity Subject Name
	Perform Recommissioning      type=delta     delta_file=${cmp_eesubjectname}     timeout=300
	Sleep   60
	Certificate Configure     operation=install_cmp_certificate       timeout=120
	Sleep   60

Get CMP Parameters from Admin
	${cmp_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}
    Set Suite Variable      ${cmp_dict}     ${cmp_dict}
	${eeSubjectName}=       Get From Dictionary    dictionary=${cmp_dict}    key=eeSubjectName
	Set Suite Variable    	  ${eeSubjectName}       ${eeSubjectName}

Get Installed Certificate Details
	${certificate_details}=        Certificate Configure     operation=get_certificate_details         type=EndEntity     source=Operator
	...    timeout=120
	Set Suite Variable       ${request_message}         ${certificate_details}
	${Issued_To}=   Get from Dictionary      ${request_message}[0]       issuedTo
	${Issued_To}=    Remove String    ${Issued_To}    ${SPACE}
	Set Suite Variable      ${Issued_To}        ${Issued_To}

Verify Installation of Cert with End Entity Subject Name
	Get CMP Parameters from Admin
    Get Installed Certificate Details
	Should Be Equal      ${eeSubjectName}       ${Issued_To}

Verify IPSEC Tunnel status with End Entity Subject Name
	Execute command on ENodeB     ipsec status
	Should Match Regexp		${stdout}	.*ESTABLISHED.*
	Should Match Regexp		${stdout}	.*${Issued_To}.*

Postconditions
	SSHLibrary.Open connection    ${config.Strongswan_ip}
	SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
	Execute Command 	sudo ipsec stop
	SSHLibrary.Close Connection