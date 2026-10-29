*** Settings ***
Documentation  This is a suite for Branch 25R3 SBTS10687
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R3  SRAN  CLOUD_SRAN_N_10687_1ASIM_2ABIP_2AVQA_1AHPB_1AHPJ  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01

Resource    ../../WebEM/test_resources/WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode.robot
Resource    ../../WebEM/test_resources/WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode.robot
Resource    ../../WebEM/test_resources/WebEM__Compare_Managed_Objects.robot
Resource    ../../WebEM/test_resources/WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells.robot
Resource    ../../WebEM/test_resources/WebEM__Loading_duration_until_runtime_view.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_availability_of_downloadSwConfig.robot
Resource    ../../FM/test_resources/FM__FHNET_reset_counter_exceeded.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1687
${COLLECT_SNAPSHOT_FLAG}    always


*** Test Cases ***
[1]WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    [Tags]  QC_227645
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    TC__WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    [Teardown]    Run Keywords    WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode
    [Tags]  QC_227639
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


[1]WebEM__Compare_Managed_Objects
    [Tags]  QC_227638
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Compare_Managed_Objects.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Compare_Managed_Objects
    TC__WebEM__Compare_Managed_Objects
    [Teardown]    Run Keywords    WebEM__Compare_Managed_Objects.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells
    [Tags]  QC_227642
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells
    TC__WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells
    [Teardown]    Run Keywords    WebEM__Collecting_L2Ps_component_traces_with_the_configured_filter_for_cells.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Loading_duration_until_runtime_view
    [Tags]  QC_227637
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TIMEOUT}    30s

    ...    AND    WebEM__Loading_duration_until_runtime_view.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Loading_duration_until_runtime_view
    TC__WebEM__Loading_duration_until_runtime_view
    [Teardown]    Run Keywords    WebEM__Loading_duration_until_runtime_view.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    [Tags]  QC_227648
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    TC__WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    [Tags]  QC_227641
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    TC__WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_availability_of_downloadSwConfig
    [Tags]  QC_227644
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_availability_of_downloadSwConfig.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_availability_of_downloadSwConfig
    TC__WebEM__Admin_CLI_availability_of_downloadSwConfig
    [Teardown]    Run Keywords    WebEM__Admin_CLI_availability_of_downloadSwConfig.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FHNET_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}     1200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}      1200

    ...    AND    FM__FHNET_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FHNET_reset_counter_exceeded
    TC__FM__FHNET_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FHNET_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a
