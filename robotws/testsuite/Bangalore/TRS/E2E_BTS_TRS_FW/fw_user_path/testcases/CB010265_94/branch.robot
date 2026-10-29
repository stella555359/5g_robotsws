*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:06:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CB010265"
...     [Funtion_Hash_Tags]     "Verification of PKI distribution, SAN and autocertdelete parameter for Auto IR and KUR after Software Upgrade"
...     [Procedure]             "Verification of PKI distribution, SAN and autocertdelete parameter for Auto IR and KUR after Software Upgrade"

Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***

[1]CB010265_TRS_A_Verification of functionality of PKI distribution, SAN and autocertdelete parameter for Auto IR and KUR after Software Upgrade

    Perform Commissioning       scf_file=${scf_25r3}     verify_bts_status=False     timeout=600     alias=default
	Sleep   180
	Verify Installation of Cerificate from Primary CMP Server
	Check for Additional TA Certificates
	Verify Installation of Cerificate from Secondary CMP Server
	Check for Additional TA Certificates
	Verify Installation of Cerificate from Primary CMP Server
	Check for Additional TA Certificates

*** Keywords ***
Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
    Run Keyword And Ignore Error certificate configure       operation=delete_cert    all_certs=${True}
	Sleep     10

Verify Installation of Cerificate from Primary CMP Server
	Perform Recommissioning     type=delta      delta_file=${primary_cmp_server_cert}     timeout=1200
	sleep   300
	Certificate Configure       operation=install_cmp_certificate   timeout=60
	sleep   30
	Get CMP Certificate Name from Admin	primary
	Get Operator Certificates    All
	List Should Contain Value     ${operator_certs}    ${caSubjectName}

Verify Installation of Cerificate from Secondary CMP Server
	Perform Recommissioning     type=delta      delta_file=${secondary_cmp_server_cert}     timeout=1200
	sleep   300
	Certificate Configure       operation=install_cmp_certificate   timeout=120
	sleep   30
	Get CMP Certificate Name from Admin        secondary
	Get Operator Certificates    All
	List Should Contain Value     ${operator_certs}    ${caSubjectName}

Get CMP Certificate Name from Admin
	[Arguments]    ${server}
	${cmp_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}
	Run Keyword If    '${server}' == 'secondary'     Set Suite Variable       ${key}          secondaryCaSubjectName
    ...       ELSE     Set Suite Variable       ${key}          caSubjectName
    ${caSubjectName}=       Get From Dictionary    dictionary=${cmp_dict}    key=${key}
	Set Suite Variable    	  ${caSubjectName}       ${caSubjectName}

Get Operator Certificates
	[Arguments]    ${type}
	${Certificate_list}=      Certificate Configure     operation=get_certificate_list   type=${type}     timeout=120
	Log     ${Certificate_list}
    @{operator_certs}=     Create List
	FOR   ${Certificate}  IN   @{Certificate_list}
	      Log        ${Certificate}
          ${vendor}=     Get From Dictionary     ${Certificate}        source
          ${cert_name}=    Get From Dictionary      ${Certificate}     issuedTo
          ${Result}=    Remove String    ${cert_name}    ${SPACE}
          Run Keyword If   '${vendor}' == 'Operator'    Append To List    ${operator_certs}    ${Result}
    Set Suite Variable      ${operator_certs}         ${operator_certs}
    END
Upgrade BTS software to latest software
	[Arguments]    ${profile}
	${Build_name}=       Run     ls -lrt /home/ute/builds/${profile}/ | awk 'END{print}' | awk '{print $9}'
	Perform Software Download And Update      package=/home/ute/builds/${profile}/${Build_name}        activate_sw=true      update_timeout=1200
    Sleep    500

Rollback BTS Software
	Rollback Software       timeout=600
	Sleep    360

Check for Additional TA Certificates
	Get Operator Certificates      TA
	${len}=      Get Length        ${operator_certs}
	Should Be Equal As Numbers     ${len}      1