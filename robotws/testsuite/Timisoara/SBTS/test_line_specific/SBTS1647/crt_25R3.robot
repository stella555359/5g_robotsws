*** Settings ***
Documentation  This suite is for Branch 25R3 SBTS-10647
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R3  SRAN  CLOUD_SRAN_L_10647_1ASIA_3ABIA_3AAFB_3AAIB  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  ca_CIT_general

Resource    ../../WebEM/test_resources/WebEM__UAM_Update_alias_and_password_for_local_users.robot
Resource    ../../WebEM/test_resources/WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.robot
Resource    ../../WebEM/test_resources/WebEM__Change_of_MPlane_address_and_commissioning_report.robot
Resource    ../../WebEM/test_resources/WebEM__System_Critical_Log_contents_via_MPlane.robot
Resource    ../../WebEM/test_resources/WebEM__Check_the_CSV_file_with_PRB_measurements.robot
Resource    ../../FM/test_resources/FM__FHNET_reset_counter_exceeded.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1647
${COLLECT_SNAPSHOT_FLAG}    always

*** Test Cases ***

[1]WebEM__UAM_Update_alias_and_password_for_local_users
    [Tags]  QC_210210
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS_RESCUE_CONSOLE_TIMEOUT}    700

    ...    AND    WebEM__UAM_Update_alias_and_password_for_local_users.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__UAM_Update_alias_and_password_for_local_users
    TC__WebEM__UAM_Update_alias_and_password_for_local_users
    [Teardown]    Run Keywords    WebEM__UAM_Update_alias_and_password_for_local_users.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Tags]  QC_210211
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    TC__WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Teardown]    Run Keywords    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Change_of_MPlane_address_and_commissioning_report
    [Tags]	QC_210219
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TEMPORARY_MPLANE_IP}    10.15.236.143

    ...    AND    WebEM__Change_of_MPlane_address_and_commissioning_report.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Change_of_MPlane_address_and_commissioning_report
    TC__WebEM__Change_of_MPlane_address_and_commissioning_report
    [Teardown]    Run Keywords    WebEM__Change_of_MPlane_address_and_commissioning_report.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__System_Critical_Log_contents_via_MPlane
    [Tags]  QC_210217
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__System_Critical_Log_contents_via_MPlane.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__System_Critical_Log_contents_via_MPlane
    TC__WebEM__System_Critical_Log_contents_via_MPlane
    [Teardown]    Run Keywords    WebEM__System_Critical_Log_contents_via_MPlane.TC Teardown
    ...    AND    Restore Resource Search Order

[1]WebEM__Check_the_CSV_file_with_PRB_measurements
    [Tags]  QC_210216
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOMMISSIONING_TIMEOUT}    300s
    ...    AND    Set Test Variable    ${WCDMA_TIMEOUT}    300s
    ...    AND    WebEM__Check_the_CSV_file_with_PRB_measurements.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Check_the_CSV_file_with_PRB_measurements
    TC__WebEM__Check_the_CSV_file_with_PRB_measurements
    [Teardown]    Run Keywords    WebEM__Check_the_CSV_file_with_PRB_measurements.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FHNET_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}     1200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}      1200

    ...    AND    FM__FHNET_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FHNET_reset_counter_exceeded
    TC__FM__FHNET_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FHNET_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***


Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a