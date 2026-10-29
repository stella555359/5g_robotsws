*** Settings ***

Documentation
...     [Author]                "Madhumitha R"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:02:2023"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CA_IPv6_SR002750"
...     [Funtion_Hash_Tags]     "6 operators with dedicated SeGW for different Operators with dedicated PKI and Cross-Signed CA_IPv6_SR002750"
...     [Procedure]             "6 operators with dedicated SeGW for different Operators with dedicated PKI and Cross-Signed CA_IPv6_SR002750"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/resources/common_CNI_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***

[1]TRS_Transport Separation for 6 operators with dedicated SeGW for different Operators with dedicated PKI and Cross-Signed CA_IPv6_SR002750

    Restore Vendor Certificates
    Sleep     120
	Perform Commissioning    scf_file=${Ipsec_scf}    skip_parameter_relation_errors=${True}     verify_bts_status=${False}     timeout=8000
    Sleep    600
	Manual_Installation_of_Cert
    Sleep    260
    Verify Ipsec Tunnels Status
    Disabling Ipsec
    Verify X2Link status is up