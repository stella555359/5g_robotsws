*** Settings ***
Documentation   [Procedure] "CB005820-A_Auto_Verification of certificates & crl with upgrade rollback & configuration reset error warning scenarios"
...             [Date] "Date of creation 31-10-2021"
...             [Author] "Nupur K"
...             [QC_Path] "QC_Path in Test Plan"
...             [QC_ID] "QC_ID in Test Lab for reporting"
...             [Feature_ID] "CB005820-SR-A-d"
...             [Funtion_Hash_Tags] "CMP"
...             [Validation_status] Validated and Passed
...             [Validated_TestLine] ASIL-003
...             [Validation Date] 31-10-2021

Resource          ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test Cases ***
[1]CB005820-Verification of certificates & crl with upgrade rollback & configuration reset error warning scenarios
	Perform Commissioning       scf_file=${Configuration_scf_basic}     verify_bts_status=False     timeout=400     alias=default
	Sleep   300
    Perform Recommissioning     type=delta   delta_file=${Configuration_delta_CMP_CRL_upgrade_rollback}      timeout=300
    Sleep   120
	Install Certificate and verify installation
	Upgrade BTS software to latest software       ${profile}
	Check Persistency of Certificate after Upgrade
	Rollback BTS Software
	Install New Certificate and verify installation
	Check Persistency of Certificate after rollback

*** Keywords ***
Get CMP Parameters from Admin
    ${cmp_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}
    Set Suite Variable      ${cmp_dict}     ${cmp_dict}
    ${eeSubjectName}=       Get From Dictionary    dictionary=${cmp_dict}    key=eeSubjectName
    Set Suite Variable        ${eeSubjectName}       ${eeSubjectName}

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

Install Certificate and verify installation
   Perform Recommissioning      type=param     param_path=CMP-1:caSubjectName     operation=update     value=${Certificate_1}    timeout=300
	Sleep   60
	Certificate Configure     operation=install_cmp_certificate       timeout=120
	Get Operator Certificates
	List Should Contain Value     ${operator_certs}    ${Certificate_1}
	Verify Installation of Cert with End Entity Subject Name

Restore all Certificate
	certificate configure    operation=restore_vendor_certificate
	Sleep 		10
	certificate configure    operation=delete_cert  all_certs=${True}
	Sleep     10

Upgrade BTS software to latest software
	[Arguments]    ${profile}
	${Build_name}=       Run     ls -lrt /home/ute/builds/${profile}/ | awk 'END{print}' | awk '{print $9}'
	Perform Software Download And Update      package=/home/ute/builds/${profile}/${Build_name}        activate_sw=true      update_timeout=1800
    Sleep    360

Check Persistency of Certificate after Upgrade
	Get Operator Certificates
	List Should Contain Value     ${operator_certs}    ${Certificate_1}
	Verify Installation of Cert with End Entity Subject Name

Install New Certificate and verify installation
	Perform Recommissioning      type=param     param_path=CMP-1:caSubjectName     operation=update     value=${Certificate_2}    timeout=300
	Sleep   30
	Certificate Configure     operation=install_cmp_certificate       timeout=120
    Sleep   30
	Get Operator Certificates
	List Should Contain Value     ${operator_certs}    ${Certificate_1}
	List Should Contain Value     ${operator_certs}    ${Certificate_2}
	Verify Installation of Cert with End Entity Subject Name

Rollback BTS Software
	Rollback Software       timeout=300
	Sleep    360

Check Persistency of Certificate after rollback
	Get Operator Certificates
	List Should Contain Value     ${operator_certs}    ${Certificate_1}
	List Should Contain Value     ${operator_certs}    ${Certificate_2}
	Verify Installation of Cert with End Entity Subject Name

Get Operator Certificates
	${Certificate_list}=      Certificate Configure     operation=get_certificate_list         type=TA      timeout=120
	Log     ${Certificate_list}
    @{operator_certs}=     Create List
	FOR   ${Certificate}  IN   @{Certificate_list}
	      Log        ${Certificate}
          ${vendor}=     Get From Dictionary     ${Certificate}        source
          ${cert_name}=    Get From Dictionary      ${Certificate}     issuer
          ${Result}=    Remove String    ${cert_name}    ${SPACE}
          Run Keyword If   '${vendor}' == 'Operator'    Append To List    ${operator_certs}    ${Result}
    END
    Set Suite Variable      ${operator_certs}         ${operator_certs}