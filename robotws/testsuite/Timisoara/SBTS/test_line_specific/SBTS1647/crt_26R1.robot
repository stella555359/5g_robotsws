*** Settings ***
Documentation  This suite is for 26R1 SBTS-10647
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  26R1  SRAN  CLOUD_SRAN_L_10647_1ASIA_3ABIA_3AAFB_3AAIB  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  ca_CIT_general

Resource    ../../WebEM/test_resources/WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.robot
Resource    ../../WebEM/test_resources/WebEM__UAM_Update_alias_and_password_for_local_users.robot
Resource    ../../WebEM/test_resources/WebEM__Change_of_MPlane_address_and_commissioning_report.robot
Resource    ../../WebEM/test_resources/WebEM__System_Critical_Log_contents_via_MPlane.robot
Resource    ../../WebEM/test_resources/WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI.robot
Resource    ../../FM/test_resources/FM__FHNET_reset_counter_exceeded.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1647
${COLLECT_SNAPSHOT_FLAG}    always

*** Test Cases ***
[1]WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Tags]  QC_256570
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    TC__WebEM__Simplified_Site_View_sorting_and_ordering_capabilities
    [Teardown]    Run Keywords    WebEM__Simplified_Site_View_sorting_and_ordering_capabilities.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__UAM_Update_alias_and_password_for_local_users
    [Tags]  QC_256563
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS_RESCUE_CONSOLE_TIMEOUT}    700

    ...    AND    WebEM__UAM_Update_alias_and_password_for_local_users.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__UAM_Update_alias_and_password_for_local_users
    TC__WebEM__UAM_Update_alias_and_password_for_local_users
    [Teardown]    Run Keywords    WebEM__UAM_Update_alias_and_password_for_local_users.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Change_of_MPlane_address_and_commissioning_report
    [Tags]	QC_256572
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
    [Tags]  QC_256571
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__System_Critical_Log_contents_via_MPlane.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__System_Critical_Log_contents_via_MPlane
    TC__WebEM__System_Critical_Log_contents_via_MPlane
    [Teardown]    Run Keywords    WebEM__System_Critical_Log_contents_via_MPlane.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI
    [Tags]  QC_256569
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI
    TC__WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI
    [Teardown]    Run Keywords    WebEM__Snapshot_HealthCheck_coverage_via_ADMIN_CLI.TC Teardown
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