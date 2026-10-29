*** Settings ***
Documentation  This is a suite for CRT SBTS10745
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NLWG_10745_ASIB_ABIA_ABIN_ABIO_AZNB_AEHC_FXDB  STATE_SKIP_AGENT
Library          XML  use_lxml=True
Suite Setup     Run Keywords  Set Library Search Order  ca_WebEM_general  ca_WebEM_mobile  AND  Map BuildShareTimi01

Resource    ../../WebEM/test_resources/WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.robot
Resource    ../../WebEM/test_resources/WebEM__BTS_Startup_view_show_resources.robot
Resource    ../../WebEM/test_resources/WebEM__Admin_CLI_getRmodMeasurementsById.robot
Resource    ../../WebEM/test_resources/WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.robot
Resource    ../../WebEM/test_resources/WebEM__Filtering_active_historical_BTS_alarm_list.robot
Resource    ../../WebEM/test_resources/WebEM__5G_Test_Models_Running_5G_Downlink_Test.robot
Resource    ../../WebEM/test_resources/WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.robot
Resource    ../../WebEM/test_resources/WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters.robot
Resource    ../../FM/test_resources/FM__FHNET_reset_counter_exceeded.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1745
${COLLECT_SNAPSHOT_FLAG}    always
${SCF_LWG}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1745/node1/SCF_LWG.xml
${SCF_with_LANE}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1745/node1/SCF_LANE.xml
${SCF_with_fault}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1745/node1/SCF_Fault_25.xml
${JSON_with_parameter_true}  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1745/json/CB006590.json


*** Test Cases ***
[1]WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Tags]  QC_243251
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200

    ...    AND    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    TC__WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Teardown]    Run Keywords    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Tags]  QC_243250
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${DISABLED_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${MODULE_RECOVERY_TIMEOUT_AFTER_UNLOCK}    1200

    ...    AND    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    TC__WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Teardown]    Run Keywords    WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__BTS_Startup_view_show_resources
    [Tags]  QC_243248
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SCF_NR_LTE_NA}    SCF_NR_LTE_NA.xml
    ...    AND    Set Test Variable    ${SCF_WCDMA_GSM_NA}    SCF_WCDMA_GSM_NA.xml

    ...    AND    WebEM__BTS_Startup_view_show_resources.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__BTS_Startup_view_show_resources
    TC__WebEM__BTS_Startup_view_show_resources
    [Teardown]    Run Keywords    WebEM__BTS_Startup_view_show_resources.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Tags]  QC_243244
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    @{LIST_RMODS_WITH_EPM}  AVQA  AZNA

    ...    AND    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    TC__WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Teardown]    Run Keywords    WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Filtering_active_historical_BTS_alarm_list
    [Tags]  QC_243252
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Filtering_active_historical_BTS_alarm_list.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Filtering_active_historical_BTS_alarm_list
    TC__WebEM__Filtering_active_historical_BTS_alarm_list
    [Teardown]    Run Keywords    WebEM__Filtering_active_historical_BTS_alarm_list.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__5G_Test_Models_Running_5G_Downlink_Test
    [Tags]  QC_243239
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__5G_Test_Models_Running_5G_Downlink_Test.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__5G_Test_Models_Running_5G_Downlink_Test
    TC__WebEM__5G_Test_Models_Running_5G_Downlink_Test
    [Teardown]    Run Keywords    WebEM__5G_Test_Models_Running_5G_Downlink_Test.TC Teardown
    ...    AND    Restore Resource Search Order


[1]WebEM__Admin_CLI_getRmodMeasurementsById
    [Tags]  QC_243249
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Admin_CLI_getRmodMeasurementsById.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Admin_CLI_getRmodMeasurementsById
    TC__WebEM__Admin_CLI_getRmodMeasurementsById
    [Teardown]    Run Keywords    WebEM__Admin_CLI_getRmodMeasurementsById.TC Teardown
    ...    AND    Restore Resource Search Order

 
[1]WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters
    [Tags]  QC_243246
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SCRIPT}    RU_Common_capture_register_dump

    ...    AND    WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters
    TC__WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters
    [Teardown]    Run Keywords    WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters.TC Teardown
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
