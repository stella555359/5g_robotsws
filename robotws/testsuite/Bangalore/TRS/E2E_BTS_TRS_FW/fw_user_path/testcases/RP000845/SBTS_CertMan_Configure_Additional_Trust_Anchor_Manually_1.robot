*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Bibhukinkar Behera"
...     [Maintenance]   "TRS ET Bangalore Team"
...     [Procedure]     "The test case is planned to validate Automatic trigger_CMPIR and trigger CRL using Source IP address"
...     [Date]          "13-09-2022"
...     [Feature_ID]    "RP000845"
...     [Requirement ID]    "WBTS_TRS_20224"
...     [Config_Comments]    "This script requires basic SCF loading with CMP and CRL server configuration."
...     [Funtion_Hash_Tags]     "CMP"
...     [RunTime Parameters]    "bts_id used is 2010"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops



*** Test Cases ***

[1][2.0] RP000845_CertMan Configure Additional Trust Anchor Manually

    Perform Commissioning     scf_file=${RP000845_config}     verify_bts_status=True     timeout=400     alias=default
    Sleep    200
    Run Keyword And Ignore Error	certificate configure    operation=delete_cert	all_certs=${True}
    Sleep       200
    Install Root Certificates
    Sleep       200
    Install Additonal TA Certificates
    Sleep      200
    Delete Additional TA Certificates
    Sleep       200
    Install Concatenated CA Cetificate

*** Keywords ***
Install Root Certificates
    certificate configure    operation=install_certificate    cert_file=${caCert_valid}    cert_type=BtsTrustChain
...     cert_format=P12    password=${password}
    Log    Certificate Installed successfully

Install Additonal TA Certificates
    certificate configure    operation=install_certificate    cert_file=${ta_certificate}    cert_type=AdditionalCa
...     cert_format=PEM
    Log    TA Certificate Installed successfully

Delete Additional TA Certificates
    Certificate Configure    operation=delete_cert   type=${ta_cert}    subject=${ta_sub}   source=${source}
    Log    Certificate Deleted Successfully

Install Concatenated CA Cetificate
    certificate configure    operation=install_certificate    cert_file=${Conca_ca_cert}    cert_type=AdditionalCa
...      cert_format=PEM
    Log    TA Certificate Installed successfully
