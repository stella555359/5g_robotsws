*** Settings ***
Documentation    Test suite for ASIR with TLS verificaton of feature CB010265
...              authors: Lukasz Skoczylas, Aleksandra Faliszek
...              contact: lukasz.skoczylas@nokia.com, aleksandra.faliszek@nokia.com

Library      taf.sbts.oam.coam.admin    WITH NAME    admin
Library      ./resources/CB010265_ET_keywords.py
Resource     ./resources/CB010265_keywords.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/NJ_Resources/Resources/robot/DevNJ_wireshark_resource.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
Suite Teardown  Common Suite Teardown

*** Variables ***
${delta_path}=                ${CURDIR}/resources/deltas
${ref_num}=                   62191
${pre_key}=                   secret
${DIR}=                       /home/asir78188/UPLOADS/ATL
${PHRASE_BLOCK}=              SM-2019;Unit block request for ASI-1/ASI_R-1/ANTMOD_R-1
${PHRASE_UNBLOCK}=            SM-2019;Unit unblock request for ASI-1/ASI_R-1/ANTMOD_R-1

*** Test Cases ***
[1][2.0] CB010265-A_CB008639-A_02_ASIR_NetAct_FP_Integration_with_NEIW
    [Setup]      Common Test Setup And Backup Sbts
    Install RSA cert
    logger.Log info To Console  Enable TLSv1.2 RSA
    Perform bts delta json commissioning  delta_file=${delta_path}/Delta_enable_TLSv1.2_RSA.json  interface=lmp  force_reconnect=${True}
    gnbru.Wait For Radio Unit To Be Online   radio_type=asirmod
    gnb_asir.Verify Status of all ASIR cells is Operational
    Integrate ASiR to emssim with TLSv1.2 RSA
    De-integrate ASiR to emssim
    [Teardown]   Common Test Teardown And Recover Sbts

[1][3.0] CB010265-A_CB005820-SR-C_TC01_ASiR_Integration_NetAct_Cert_with_SHA-1_Signature_Disable_Feature_Flag
    [Setup]      Common Test Setup And Backup Sbts
    Install RSA SHA1 cert
    logger.Log info To Console  Enable TLSv1.2 SHA1
    Perform bts delta json commissioning  delta_file=${delta_path}/Delta_enable_TLSv1.2_nonSHA1.json  interface=lmp  force_reconnect=${True}
    gnbru.Wait For Radio Unit To Be Online   radio_type=asirmod
    gnb_asir.Verify Status of all ASIR cells is Operational
    logger.Log info To Console  Integrate ASiR to emssim with TLSv1.2
    ASiR NE integration to EMSsim  ${cert_SHA1_path}
    Sleep   60s
    ${res} =     Verify ASiR NE integration to EMSsim
    Should Be True    ${res} >= ${1}
    logger.Log info To Console  Integrate ASiR to emssim with TLSv1.2 successfully
    De-integrate ASiR to emssim
    [Teardown]   Common Test Teardown And Recover Sbts

[1][3.0] CB010265-A_CB005820-SR-C_TC02_ASiR_Integration_NetAct_Cert_with_SHA-1_Signature_Enable_Feature_Flag
    [Setup]      Common Test Setup And Backup Sbts
    Install RSA SHA1 cert
    logger.Log info To Console  Enable TLSv1.2 SHA1
    Perform bts delta json commissioning  delta_file=${delta_path}/Delta_enable_TLSv1.2_SHA1.json  interface=lmp  force_reconnect=${True}
    gnbru.Wait For Radio Unit To Be Online   radio_type=asirmod
    gnb_asir.Verify Status of all ASIR cells is Operational
    logger.Log info To Console  Integrate ASiR to emssim with TLSv1.2
    ASiR NE integration to EMSsim  ${cert_SHA1_path}
    Sleep   60s
    ${res} =     Verify ASiR NE integration to EMSsim
    Should Be True    ${res} == ${0}
    logger.Log info To Console  Integrate ASiR to emssim with TLSv1.2 successfully
    De-integrate ASiR to emssim
    [Teardown]   Common Test Teardown And Recover Sbts

[1][1.0] CB010265-A_ET_06_CB005999_Re-configuration_of_CMP_parameters
    [Setup]      Common Test Setup And Backup Sbts
    ${path_to_wireshark_file}=  Start Tcpdump On gNB  options=-i any
    logger.Log info To Console  Install RSA cert
    Perform bts delta json commissioning  delta_file=${delta_path}/Delta_enable_TLSv1.2_RSA_CMP.json  interface=lmp  force_reconnect=${True}
    gnbru.Wait For Radio Unit To Be Online   radio_type=asirmod
    gnb_asir.Verify Status of all ASIR cells is Operational
    ${connection}    admin.Connect To
    admin.set_certificate_automatic_management  reference_number=${ref_num}     preshared_key=${pre_key}    connection=${connection}
    admin.cmp_initialize_certificate    connection=${connection}
    Integrate ASiR to emssim with TLSv1.2 RSA
    De-integrate ASiR to emssim
    Perform Configuration Parameter Recommissioning On gNB
    ...                                         dist_name=MRBTS-{}/MNL-1/CERTH-1/CMP-1
    ...                                         param_name=caSubjectName
    ...                                         operation=update
    ...                                         param_value=DC=div_krk, DC=net, CN=TA_Regression_2_Cert
    ...                                         skip_parameter_relation_errors=${false}
    ...                                         timeout=300
    admin.cmp_initialize_certificate    connection=${connection}
    Integrate ASiR to emssim with TLSv1.2 RSA
    De-integrate ASiR to emssim
    Stop Tcpdump On gNB
    Sleep   30s
    Convert pcap to XML        ${path_to_wireshark_file}    ip.addr == 10.83.180.65    ${CURDIR}/pcap_to_check.txt
    ${inside_pcap}=            OperatingSystem.Get File    ${CURDIR}/pcap_to_check.txt
    Should Contain             ${inside_pcap}    id-at-commonName=TA_Regression_1_Cert,dc=net,dc=div_krk
    Should Contain             ${inside_pcap}    id-at-commonName=TA_Regression_2_Cert,dc=net,dc=div_krk
    [Teardown]   Common Test Teardown And Recover Sbts

[1][1.0] CB010265-B_ET_27_ASiR_EMSsim_ATLlog_upload_with_Elliptic_curve_and_RSA_certification
    [Setup]      Common Test Setup And Backup Sbts
    Install RSA cert
    logger.Log info To Console  Enable TLSv1.2 RSA
    Perform bts delta json commissioning  delta_file=${delta_path}/Delta_enable_TLSv1.2_RSA.json  interface=lmp  force_reconnect=${True}
    gnbru.Wait For Radio Unit To Be Online   radio_type=asirmod
    gnb_asir.Verify Status of all ASIR cells is Operational
    Integrate ASiR to emssim with TLSv1.2 RSA
    ASiR block and unblock antenna
    Collect ATL logs
    De-integrate ASiR to emssim
    ${results_block_antenna}=    Search Phrase In Tar    ${DIR}    ${PHRASE_BLOCK}
    Should Not Be Empty    ${results_block_antenna}
    ${results_unblock_antenna}=    Search Phrase In Tar    ${DIR}    ${PHRASE_UNBLOCK}
    Should Not Be Empty    ${results_unblock_antenna}
    [Teardown]   Common Test Teardown And Recover Sbts
