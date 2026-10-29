*** Settings ***
Documentation  This is a suite for CRT SBTS10687
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_N_10687_1ASIM_2ABIP_2AVQA_1AHPB_1AHPJ  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01

Resource    ../../WebEM/test_resources/WebEM__Compare_Managed_Objects.robot
Resource    ../../WebEM/test_resources/WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells.robot
Resource    ../../WebEM/test_resources/WebEM__Loading_duration_until_runtime_view.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_ims2ToSCF.robot
Resource    ../../WebEM/test_resources/WebEM__BER_Threshold_major_alarm_UL.robot
Resource    ../../FM/test_resources/FM__FHNET_reset_counter_exceeded.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1687
${COLLECT_SNAPSHOT_FLAG}    always


*** Test Cases ***
[1]WebEM__Compare_Managed_Objects
    [Tags]  QC_281526
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Compare_Managed_Objects.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Compare_Managed_Objects
    TC__WebEM__Compare_Managed_Objects
    [Teardown]    Run Keywords    WebEM__Compare_Managed_Objects.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    [Tags]  QC_281531
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    TC__WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    [Tags]  QC_281528
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    TC__WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_ims2ToSCF
    [Tags]  QC_281524
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_ims2ToSCF.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_ims2ToSCF
    TC__WebEM__Admin_CLI_ims2ToSCF
    [Teardown]    Run Keywords    WebEM__Admin_CLI_ims2ToSCF.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__BER_Threshold_major_alarm_UL
    [Tags]  QC_37862
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__BER_Threshold_major_alarm_UL.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__BER_Threshold_major_alarm_UL
    TC__WebEM__BER_Threshold_major_alarm_UL
    [Teardown]    Run Keywords    WebEM__BER_Threshold_major_alarm_UL.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a
