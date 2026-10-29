*** Settings ***
Documentation     [Procedure] "CB008154-SR-A-A8_auto_delete_of_old_ta_certs_when_the_autoCertDelete_flag_is_disabled_or_enabled_with_IPv4_and_IPv6"
...               [Date] "Date of creation 09-04-2022"
...               [Author] "Kavya M"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "CB008154-SR-A-A8"
...               [Funtion_Hash_Tags] "CMP"
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] ASIK-9050
...               [Validation Date] 11-04-2022

Variables         ta_e2e_bts_trs_fw
Library           Collections
Resource           ../resources/common_keywords.robot
Resource           ../resources/Admin_Common_Library.robot
Resource           ${CURDIR}/resources/CB008154_Common_Keywords.robot

Library		      SSHLibrary
Library           ute_pdu


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]CB008154-Verification_of_Expired_Certificates_and_Duplicate_Certifcate
     Restore all Certificate
     Perform Commissioning       scf_file=${CB008154_Configuration_autoCertDelete}     verify_bts_status=False     timeout=600
     Sleep      160
    Install expiry certificate with p12 file
    Install expiry certificate with PEM format
    Install additional CA certificate
    Install Root CA Certificate with invalid p12 file
    Install Intermediate CA Certificate with invalid pem file
    Install Certificate Chain where Intermediate CA is missing
    Install Certificate where algorithm is invalid
    Install Certificate where intermediate CA certificate is exceeded above 8K
