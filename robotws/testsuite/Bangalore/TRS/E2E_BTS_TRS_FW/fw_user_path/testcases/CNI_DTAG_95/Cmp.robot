*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CNI118677"
...     [Funtion_Hash_Tags]     "Configure_Overlapping_of_Ipv4_address_with_CMP_Server_address_and_verify_Installtion_of_certs"
...     [Procedure]             "Configure_Overlapping_of_Ipv4_address_with_CMP_Server_address_and_verify_Installtion_of_certs"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_CNI_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***

[1]CNI118677_Configure_Overlapping_of_Ipv4_address_with_CMP_Server_address_and_verify_Installtion_of_certs

	Restore Vendor Certificates
	Perform Commissioning    scf_file=${Cmp_scf}    skip_parameter_relation_errors=${True}      verify_bts_status=${False}     timeout=800
    Sleep    300
	Perform Recommissioning     type=delta      delta_file=${ADD_RULE_cmp}   skip_parameter_relation_errors=${True}   timeout=600    alias=default
    Sleep    160
    Verify Addition Of Rule(1500) in BOARD
	Verification_Of_cmpInitializeCertificate
    Verify Alarm        faultid=${fault_ID}        should_exist=${False}
    Perform Recommissioning     type=delta      delta_file=${DELETE_RULE_cmp}
    ...    skip_parameter_relation_errors=${True}     timeout=600     alias=default
    Sleep    300
    Run Keyword and Ignore Error       Verification_Of_cmpInitializeCertificate
    Verify Alarm        faultid=${fault_ID}        should_exist=${True}
    Verify Deletion Of Rule(1500) in BOARD