*** Settings ***
Documentation
...				[Author]         "Abhishek Patil"
...				[Maintenance]    "TRS I & V Tools Bangalore Team"
...				[Scenario]	 	 "Private PnP with SAN creation"

...				[Description] 		Check Dynamic SAN fucntionality with Certificate validation.

Library			ta_emss
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}../../resources/common_keywords.robot

Suite Setup		Run Keywords		Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops


*** Variables ***
${val}                                  4

*** Test Cases ***
[1][1.0] CB008160_Check behaviour of BTS while used DNS should supported for dynamic SAN & IP address type

    Generate Scf	target_file=/home/ute/Backup_scf1.xml
    Run Keyword And Expect Error        *Whenever CMP-1 having \${error_msg} *    Perform error scenario
	Perform Recommissioning    type=delta    delta_file=Act_Cert_False.xml    timeout=300
    Sleep    30
	Certificate Configure    operation=install_cmp_certificate    timeout=300
    Sleep    30
	${certificate_details}=     Certificate Configure 		operation=get_certificate_details		type=TrustAnchor   source=Operator
    Check number of SAN
    Certificate Configure    operation=restore_vendor_certificate    timeout=100
	Perform Recommissioning    type=delta    delta_file=Act_Cert_True.xml    timeout=100
    Sleep    100
    verify alarm        faultid=61510     should_exist=${True}
    Perform Recommissioning    type=param    param_path=MRBTS-1/MNL-1/CERTH-1/CMP-1:caSubjectName     operation=update
    ...        value=CN=CB012562_ET_CA     timeout=300
    Sleep    100
    Certificate Configure    operation=install_cmp_certificate    timeout=600
    Sleep    30
	${certificate_details}=     Certificate Configure 		operation=get_certificate_details		type=TrustAnchor   source=Operator
	Check number of SAN

*** Keywords ***
Check number of SAN
	${Subject_Alt_Name}=     Get Parameter      param_path=${Sub_Alt_Name_Path}
	${Configured_SAN_No}=		Get Parameter      param_path=${SAN_Path}
	Setup Remote Access    remote_device=bts
	${output}=    Remote Command Execute    command=openssl x509 -text -noout -in /ffs/run/trs_data/active/keystorage/certs/cert.pem
	Log    ${output}
	${SAN}=		Get Lines Containing String    ${output}    ${Subject_Alt_Name}
	${SAN_Number}=   	Get Count	${SAN}    ${Subject_Alt_Name}
	Should Be Equal    	${Configured_SAN_No}		${SAN_Number}

Perform error scenario
    Perform Recommissioning   type=delta    delta_file=IP_address_subject_alt_type.xml
    ...    skip_parameter_relation_errors=${False}    timeout=300






