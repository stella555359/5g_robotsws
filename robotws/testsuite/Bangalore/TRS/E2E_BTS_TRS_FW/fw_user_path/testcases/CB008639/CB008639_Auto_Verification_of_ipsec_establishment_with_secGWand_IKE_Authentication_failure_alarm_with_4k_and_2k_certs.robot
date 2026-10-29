*** Settings ***
Documentation
...              [Procedure] "CB008639_Auto_Verification of ipsec establishment with secGWand IKE Authentication failure alarm with 4k and 2k certs"
...              [Date] "Date of creation 22-01-2023"
...              [Author] "Nupur K"
...              [QC_Path] "QC_Path in Test Plan"
...              [QC_ID] "QC_ID in Test Lab for reporting"
...              [Feature_ID] "CB008639"
...              [Funtion_Hash_Tags] "CMP,IPSEC, 4K"
...              [Validation_status] Validated and Passed
...              [Validated_TestLine] 5G_ASIL_TL003
...              [Validation Date] 23-01-2023

Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]CB008639_Auto_Verification of ipsec establishment with secGWand IKE Authentication failure alarm with 4k and 2k certs
    Perform Commissioning       scf_file=${Configuration_scf_basic}     verify_bts_status=False     timeout=400
	Sleep   300
    Perform Recommissioning     type=delta   delta_file=${Configuration_delta_CB008639_Ipsec}      timeout=300
    Sleep   120
	Install 4K Certificate and Verify Installation
	Perform Recommissioning		 type=param      param_path=IPSECC-1:ipSecEnabled	operation=update	value=true	timeout=120
	Install Certificate in Strongswan
    Sleep   30
	Verify IPSEC Tunnel status
    Perform Recommissioning      type=param      param_path=IKEP-1:connectionEstablishmentMode    operation=update    value=RESPONDER   timeout=120
    Execute command on ENodeB     ipsec status
    Should Not Match Regexp     ${stdout}   .*ESTABLISHED.*
    Perform Recommissioning      type=param      param_path=IKEP-1:connectionEstablishmentMode    operation=update    value=INITIATOR_AND_RESPONDER
	...   timeout=120
    Verify IPSEC Tunnel status
    Verify Duplicate Packets
	Perform Recommissioning		 type=param      param_path=IPSECC-1:ipSecEnabled	operation=update	value=false	 timeout=120
	Execute command on ENodeB     ipsec status
	Should Not Match Regexp		${stdout}	.*ESTABLISHED.*
	[TEARDOWN]     Postconditions

*** Keywords ***
Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}
	Sleep     10

Verify Duplicate Packets
    SSHLibrary.Open connection    ${config.Strongswan_ip}
    SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
    ${output}=    Execute Command     ping 10.0.1.2 -c 20
    Should Not Contain     ${output}    (DUP!)
    [TEARDOWN]      SSHLibrary.Close Connection

Verify IPSEC Tunnel status
	Execute command on ENodeB     ipsec status
	Should Match Regexp		${stdout}	.*ESTABLISHED.*

Install Certificate in Strongswan
	SSHLibrary.Open connection    ${config.Strongswan_ip}
	SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
	Execute Command     sudo rm -rf ${cert_PrivateKey}
	Execute Command     sudo rm -rf ${cert_Btspem}
	Execute Command 	sudo ln -s ${4K_cert_PrivateKey} ${cert_PrivateKey}
	Execute Command 	sudo ln -s ${4K_cert_Btspem} ${cert_Btspem}
	Execute Command 	sudo ipsec restart
	[TEARDOWN] 		SSHLibrary.Close Connection

Install 4K Certificate and Verify Installation
	Certificate Configure     operation=install_cmp_certificate       timeout=120
	Sleep   60
	Get CMP Parameters from Admin
	Get Installed Certificate Details
	Should Be Equal      ${caSubjectName}       ${Issued_By}

Get CMP Parameters from Admin
	${cmp_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}
    Set Suite Variable      ${cmp_dict}     ${cmp_dict}
	${caSubjectName}=       Get From Dictionary    dictionary=${cmp_dict}    key=caSubjectName
	Set Suite Variable    	  ${caSubjectName}       ${caSubjectName}

Get Installed Certificate Details
	${certificate_details}=        Certificate Configure     operation=get_certificate_details         type=EndEntity     source=Operator
	...   timeout=120
	Set Suite Variable       ${request_message}         ${certificate_details}
	${Issued_By}=   Get from Dictionary      ${request_message}[0]       issuer
	${Issued_By}=    Remove String    ${Issued_By}    ${SPACE}
	Set Suite Variable      ${Issued_By}        ${Issued_By}

Verify IPSEC Tunnel status with End Entity Subject Name
	Execute command on ENodeB     ipsec status
	Should Match Regexp		${stdout}	.*ESTABLISHED.*
	Should Match Regexp		${stdout}	.*${Issued_To}.*

Postconditions
	SSHLibrary.Open connection    ${config.Strongswan_ip}
	SSHLibrary.Login    ${config.Strongswan_user}    ${config.Strongswan_passwd}
	Execute Command 	sudo ipsec stop
	SSHLibrary.Close Connection