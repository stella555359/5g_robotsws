*** Settings ***
Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CNI118677"
...     [Funtion_Hash_Tags]     "Verification_of_Overlapping_of_Ipv4_address_with_other_operator_applicationaddress_With_and_without_IPSEC"
...     [Procedure]             "Verification_of_Overlapping_of_Ipv4_address_with_other_operator_applicationaddress_With_and_without_IPSEC"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/resources/common_CNI_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** variables ***

${Cplane_Ip}    10.71.248.83
${AMF_IP}      10.103.225.198
${count}        50


*** Test Cases ***

[1]CNI118677_Verification_of_Overlapping_of_Ipv4_address_with_other_operator_applicationaddress_With_and_without_IPSEC

    Restore Vendor Certificates
    Sleep     120
	Perform Commissioning    scf_file=${Ipsec_scf}    skip_parameter_relation_errors=${True}      verify_bts_status=${False}     timeout=800
    Sleep    300
	Manual_Installation_of_Cert
    Sleep    260
    Verify Ipsec Tunnels Status
    Verify S1Link status is up
    Verify Alarm        faultid=${fault_Num}        should_exist=${True}       occurrences=1
    Perform Recommissioning     type=delta      delta_file=${DELETE_RULE}   skip_parameter_relation_errors=${True}    timeout=600     alias=default
    Sleep    260
    Verify Alarm        faultid=${fault_Num}        should_exist=${True}       occurrences=2
    Verify S1Link status is Down
	Perform Recommissioning     type=delta      delta_file=${ADD_RULE}      skip_parameter_relation_errors=${True}     timeout=600    alias=default
    Sleep    260
    Verify Alarm        faultid=${fault_Num}        should_exist=${True}       occurrences=1
    Sleep    90
    Verify S1Link status is up