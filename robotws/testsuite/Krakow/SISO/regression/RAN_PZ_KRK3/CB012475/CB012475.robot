*** Settings ***
Documentation
...   author: Marcin Wojcik
...   contact: marcin.j.wojcik@nokia.com
...   Documentation: Suite for testing CB012475, verification L3 call on Supercell CBRS feature

Library         taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations           WITH NAME    Cell
Library         taf.rfrl.bts.devices.du.du_operations.GnbDuOperations               WITH NAME    Du
Library         taf.ue    WITH NAME    ue
Library         taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library         testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB012475.resources.SASsim_helper.SASsim    WITH NAME   sas
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup     CBRS Suite Setup
Suite Teardown    Run Keywords    Common Suite Teardown
...     AND    Change SASsim config for CB012475-A

Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}    CRL Update failure or certificate revoked
...                         SAS Registration Failure
...                         SAS Heartbeat Failure
...                         SAS Spectrum Deregistration Failure
...                         SAS Grant Failure
...                         RAT Service Outage
${SEND_CONFIGURATION_VALIDATION_EMAIL}      ${False}
${COLLECT_LOGS_DURING_DATA_TRANSFER}        ${False}
${ENABLE_RACH_OBSERVER}     ${False}
${cert_TA_path}             ${CURDIR}/resources/certs/
${alias}=       ANDROID_UE_1
${duration}=    100s
${protocol}=    TCP
${SAS_Sim_configs_dir}      ${CURDIR}/resources/SASsim_configs

*** Test Cases ***

CB012475_A_10_NSA_SingleUE_Attach_L3Call_IDLE_PAGING_CBRS_oneSubcell
    Prepare Ue for L3 Call for CB012475-A
    ...    capabilities=REAL_UE
    ...    alias=${alias}
    Sleep    300s
    Verify L3 Call Data Transfer DL&UL
    ...    duration=${duration}
    ...    tput_dl=590 Mbits/sec
    ...    tput_ul=40 Mbits/sec
    ...    protocol=${protocol}
    ...    deviation=80%
    ...    alias=${alias}
    Sleep  5s
    [Teardown]   Lite Postconditions

CB012475_B_09_SA_SingleUE_Attach_L3Call_IDLE_PAGING_CBRS_oneSubcell
    [Setup]      Prepare setup for CB012475-B
    Prepare Ue for L3 Call for CB012475-B
    ...    capabilities=REAL_UE
    ...    alias=${alias}
    Sleep    300s
    Verify L3 Call Data Transfer DL&UL
    ...    duration=${duration}
    ...    tput_dl=590 Mbits/sec
    ...    tput_ul=40 Mbits/sec
    ...    protocol=${protocol}
    ...    deviation=80%
    ...    alias=${alias}
    Sleep  5s
    [Teardown]   Lite Postconditions

*** Keywords ***
CBRS Suite Setup
    Change SASsim config for CB012475-A
    Run Keyword And Ignore Error    Du.Install Certificate    cert_file=${cert_TA_path}/ca-certificate.pem
    ...     cert_type=CBRSAdditionalCa      cert_format=PEM
    Common Suite Setup With OnAir Test Line Preparation
    ...     prefix_tag=CB012475_TMO_actFR_ITEM_A_B_NSA_SA_CBRS_SUPRCELL
    ...     list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
    ...     swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...     increase_timeout_for_update_sw=${2000}
    Sleep    300s       # Wait for x2 link

Change SASsim config for CB012475-A
    Stop SASsim
    Upload SASsim configuration for Item_A
    Start SASsim
    Sleep    5s

Prepare Ue for L3 Call for CB012475-A
    [Arguments]    ${capabilities}=REAL_UE    ${timeout_reboot_ue}=120  ${alias}=UE
    ue.Require Ue    ${alias}    capabilities=${capabilities}
    ue.Reboot Ue    ${alias}    timeout=${timeout_reboot_ue}
    ${actions_path_list}=    Create List
    ...    [1] BAND SELECTION
    ...    [1] BAND SELECTION SIM 1- VZW
    ...    [7] --Clear all bands
    ...    [6] NR5G Band Preference
    ...    [E] NEXT PAGE
    ...    [3] NR B48 NSA -sub6
    ...    [F] GO MAIN
    ...    [5] LTE Band Preference
    ...    [5] LTE B2
    ...    [F] GO MAIN
    ...    [9] --Apply band configuration
    ${actions_path}=    Evaluate    '/'.join(${actions_path_list})
    Set service mode    ${alias}    mmi_code=*#73#
    ...    actions_path=${actions_path}
    ue.Attach Ue    ${alias}
    Sleep    30s
    ${result} =    Run Keyword And Return Status    Validate ue info    ${alias}    NR_STATE   5G_NSA
    Run Keyword If    not ${result}    Retry Ue Recovery    ${alias}    3

Retry Ue Recovery
    [Arguments]    ${alias}    ${retries}
    FOR    ${index}    IN RANGE    ${retries}
        Log    Attempt ${index + 1} to recover UE
        ue.Detach Ue    ${alias}
        Sleep    60s
        ue.Attach Ue    ${alias}
        Sleep    60s
        ${result}=    Run Keyword And Return Status
        ...    Validate ue info    ${alias}    NR_STATE    5G_NSA
        Run Keyword If    ${result}    Exit For Loop
        Log    Attempt ${index + 1} failed, retrying...
    END
    Run Keyword Unless    ${result}
    ...    Fail    UE recovery failed after ${retries} attempts

Prepare Ue for L3 Call for CB012475-B
    [Arguments]    ${capabilities}=REAL_UE    ${alias}=UE
    ue.Require Ue    ${alias}    capabilities=${capabilities}
    ${actions_path_list}=    Create List
    ...    [1] BAND SELECTION
    ...    [1] BAND SELECTION SIM 1- VZW
    ...    [7] --Clear all bands
    ...    [6] NR5G Band Preference
    ...    [E] NEXT PAGE
    ...    [4] NR B48 SA -sub6
    ...    [F] GO MAIN
    ...    [9] --Apply band configuration
    ${actions_path}=    Evaluate    '/'.join(${actions_path_list})
    Set service mode    ${alias}    mmi_code=*#73#
    ...    actions_path=${actions_path}
    Sleep   30s

Prepare setup for CB012475-B
    Common Preconditions
    Stop SASsim
    Upload SASsim configuration for Item_B
    Start SASsim
    Sleep    60s
    Wait until keyword succeeds     5min   5sec    gnbcell.Verify All Cells Statuses    availability_status=degraded
    Sleep    60s

Lite Postconditions
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main Bts Metadata To Report
    Collect Logs After Test Finished

Start SASsim
    sas.start_sas_sim

Stop SASsim
    sas.stop_sas_sim

Upload SASsim configuration for Item_A
    sas.upload_new_config       config_path=${SAS_Sim_configs_dir}/Item_A-SAS_Sim.conf

Upload SASsim configuration for Item_B
    sas.upload_new_config       config_path=${SAS_Sim_configs_dir}/Item_B-SAS_Sim.conf