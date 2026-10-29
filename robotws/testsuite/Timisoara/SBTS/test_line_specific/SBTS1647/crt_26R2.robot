*** Settings ***
Documentation  This suite is for Trunk SBTS-10647
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS26R2  SRAN  CLOUD_SRAN_L_10647_1ASIA_3ABIA_3AAFB_3AAIB  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  ca_CIT_general

Resource    ../../WebEM/test_resources/WebEM__System_Critical_Log_contents_via_MPlane.robot
Resource    ../../WebEM/test_resources/WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode.robot
Resource    ../../WebEM/test_resources/WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1647
${COLLECT_SNAPSHOT_FLAG}    always

*** Test Cases ***
[1]WebEM__System_Critical_Log_contents_via_MPlane
    [Tags]  QC_300326
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__System_Critical_Log_contents_via_MPlane.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__System_Critical_Log_contents_via_MPlane
    TC__WebEM__System_Critical_Log_contents_via_MPlane
    [Teardown]    Run Keywords    WebEM__System_Critical_Log_contents_via_MPlane.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    [Tags]  QC_300330
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    TC__WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    [Teardown]    Run Keywords    WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode
    [Tags]  QC_300329
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode.TC Setup
    ...    AND    Modify Resource Search Order
    ...    WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode
    TC__WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode
    [Teardown]    Run Keywords
    ...    WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a