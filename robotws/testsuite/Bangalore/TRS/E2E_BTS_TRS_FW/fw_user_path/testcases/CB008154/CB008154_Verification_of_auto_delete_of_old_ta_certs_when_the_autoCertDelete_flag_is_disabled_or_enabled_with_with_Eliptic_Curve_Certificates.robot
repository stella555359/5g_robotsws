*** Settings ***
Documentation     [Procedure] "CB008154_Auto_delete_of_old_ta_certs_when_the_autoCertDelete_flag_is_disabled_or_enabled_with_with_Eliptic_Curve"
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
[1]CB008154-Verification_of_auto_delete_of_old_ta_certs_when_the_autoCertDelete_flag_is_disabled_or_enabled_with_IPv4_and_IPv6
   Restore all Certificate
   Perform Commissioning       scf_file=${CB008154_Configuration_autoCertDelete}     verify_bts_status=False     timeout=600
   Sleep      360
   Verify Installation of Certificate
   Install New Root CA Certificate      ${certificate1}
   Verify Installation of Certificate
   Check for Additional TA Certificates

   Perform Recommissioning     type=param  param_path=CERTH-1:autoCertDelete   value=true    timeout=100     operation=update
   Sleep   30
   Install New Root CA Certificate     ${certificate2}
   Verify Installation of Certificate
   Check for Additional TA Certificates

   Restore all Certificate
   Perform Recommissioning     type=param  param_path=CERTH-1:autoCertDelete   value=false    timeout=100     operation=update
   Perform Recommissioning     type=delta      delta_file=${Config_cb008154_manual_install}     timeout=120    operation=delete
   sleep   60
   Certificate Configure   operation=install_certificate     cert_file=${Cert1p12}    cert_type=BtsTrustChain     cert_format=P12
   ...   password=${Cert1password}
   Check for Additional TA Certificates
   Certificate Configure   operation=install_certificate     cert_file=${Cert2p12}    cert_type=BtsTrustChain     cert_format=P12
   ...   password=${Cert2password}
   Check for Additional TA Certificates

   Perform Recommissioning     type=param  param_path=CERTH-1:autoCertDelete   value=true     timeout=100     operation=update
   Restore all Certificate
   Certificate Configure   operation=install_certificate     cert_file=${Cert1p12}    cert_type=BtsTrustChain     cert_format=P12
   ...   password=${Cert1password}
   Check for Additional TA Certificates
   Certificate Configure   operation=install_certificate     cert_file=${Cert2p12}    cert_type=BtsTrustChain      cert_format=P12
   ...   password=${Cert2password}
   Check for Additional TA Certificates
