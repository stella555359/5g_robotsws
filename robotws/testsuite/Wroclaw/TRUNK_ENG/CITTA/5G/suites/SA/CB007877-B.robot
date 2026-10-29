*** Settings ***
Documentation
...    Test gNB behaviour when it receives A2 event for S-Cell release.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_BOO_AP_LOO
Metadata    variant    SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50

Variables    ${RESOURCES}/dist_names.py

Resource    ../../resources/main_resources.robot

# -- Setup / Teardown
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/CB007877-B.resources
${LUA}    ${RESOURCES}/sa_fdd_tdd_2cc.lua
${SCFC}    ${RESOURCES}/scfc_2cc.xml
${UE_ID}    ${1}
${NUMBER_OF_RMODS}    ${4}
${counter_ids}    M55316C05001,M55316C09000,M55124C02003,M55118C06501,M55118C06502
${M55316C05001_VALUE}    ${1}
${M55316C09000_VALUE}    ${1}
${M55124C02003_VALUE}    ${1}
${M55118C06501_VALUE}    ${1}
${M55118C06502_VALUE}    ${1}
${NUMBER_OF_MEASUREMENTS}    ${5}

*** Test Cases ***
CB007877-B_SCell_Release_Triggered_By_A2_Measurement
    [Documentation]
    ...    After receiving A2 event with RSRP measured lower than NIDD param a2MeasSCellRelSsbRsrp
    ...    (under S-Cell related NIDD object), gNB shall sent RRC Reconfiguration with command to release
    ...    current S-Cell and shall contain new A1 Measurement configuration for S-Cell addition.
    ...    A2 measurement used in this procedure should be deconfigured as well.
    [Setup]    [PRE]CB007877-B_SCell_Release_Triggered_By_A2_Measurement
    [Teardown]    [POST]CB007877-B_SCell_Release_Triggered_By_A2_Measurement

    Attach and setup PDU for UE
    Trigger A1 measurement based SCell addition
    Trigger A2 measurement based SCell release
    Get PM counters
    Verify if SCell was added correctly
    Verify if A1 event was received by gNB
    Verify if RRC reconfiguration message was sent to UE in response to A2 event
    Verify if gNB received RRC reconfiguration complete message from UE after releasing SCell

*** Keywords ***
[PRE]CB007877-B_SCell_Release_Triggered_By_A2_Measurement
    Add Flag To Swconfig    0x340000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Add Flag To Swconfig    0x9D0000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Perform Commissioning    scfc_path=${SCFC}
    Check if BTS is correctly configured    ${NUMBER_OF_RMODS}
    Start WTS    ${LUA}    check_version=False
    Check if BTS is OnAir
    Wait for counters generation to be started

[POST]CB007877-B_SCell_Release_Triggered_By_A2_Measurement
    Report miscellaneous KPIs
    SA 5G Detach UE"${UE_ID}"
    Stop WTS

# -- test steps --
Attach and setup PDU for UE
    [Tags]    DESIGNSTEP
    SA 5G Attach UE"${UE_ID}"
    SA Set Traffic Type For PDU"1" UE"${UE_ID}"
    SA Setup Primary PDU Session For PDU"1" UE"${UE_ID}" GW"1" NWSLICE"1"
    Sleep    5s

Trigger A1 measurement based SCell addition
    [Tags]    DESIGNSTEP
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} event=A1 meas_id=1 srsrq_nr=127 srsrp_nr=127 ssinr_nr=127
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    Sleep    5s

Trigger A2 measurement based SCell release
    [Tags]    DESIGNSTEP
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} event=A2 meas_id=2 scell=1 scell_rsrq=1 scell_rsrp=1 scell_sinr=1
    ...    pass_regexp=rrcReconfigurationComplete
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    Sleep    5s

Get PM counters
    [Tags]    DESIGNSTEP
    SLEEP    60    reason=Wait for generating at least one PM counter
    ${connection}=    Set Variable    get_pm_counters
    ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
    ${counters_info}=    admin.get_pm_counters    counter_ids=${counter_ids}    connection=${connection}
    SET SUITE VARIABLE    ${COUNTERS_INFO}    ${counters_info}

Verify if SCell was added correctly
    [Tags]    DESIGNSTEP
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55316C05001 counter
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55316C09000 counter

Verify if A1 event was received by gNB
    [Tags]    DESIGNSTEP
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55124C02003 counter

Verify if RRC reconfiguration message was sent to UE in response to A2 event
    [Tags]    DESIGNSTEP
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55118C06501 counter

Verify if gNB received RRC reconfiguration complete message from UE after releasing SCell
    [Tags]    DESIGNSTEP
    RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55118C06502 counter

# -- internals --
Wait for counters generation to be started
    comment    Waiting for distName creation for the counter (BTS/CELLS/NRCELL-1/NCADU/M55316C05001)
    Wait Until Keyword Succeeds    20x    15s    Get PM Counter "${M55316C05001_PATH}" Measurements

Verify M55316C05001 counter
    ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}    ${M55316C05001_PATH}   ${NUMBER_OF_MEASUREMENTS}
    ${error_msg}=    Catenate
    ...    The number of PCell UEs with 1 activated Scell in DL didn't meet expected amount.
    ...    Was: "${actual_value}", expected: "${M55316C05001_VALUE}".
    SHOULD BE TRUE    ${actual_value} == ${M55316C05001_VALUE}
    ...    msg=${error_msg}

Verify M55316C09000 counter
    ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}   ${M55316C09000_PATH}    ${NUMBER_OF_MEASUREMENTS}
    ${error_msg}=    Catenate
    ...    The number of Scell activations didn't meet expected amount.
    ...    Was: "${actual_value}", expected: "${M55316C09000_VALUE}".
    SHOULD BE TRUE    ${actual_value} == ${M55316C09000_VALUE}
    ...    msg=${error_msg}

Verify M55124C02003 counter
    ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}    ${M55124C02003_PATH}   ${NUMBER_OF_MEASUREMENTS}
    ${error_msg}=    Catenate
    ...    The number of RRC measurement report messages received with A1 measurement report didn't meet expected amount.
    ...    Was: "${actual_value}", expected: "${M55124C02003_VALUE}".
    SHOULD BE TRUE    ${actual_value} == ${M55124C02003_VALUE}
    ...    msg=${error_msg}

Verify M55118C06501 counter
    ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}    ${M55118C06501_PATH}    ${NUMBER_OF_MEASUREMENTS}
    ${error_msg}=    Catenate
    ...    RRC Reconfiguration attempts releasing SCell triggered by A2 measurement didn't meet expected amount.
    ...    Was: "${actual_value}", expected: "${M55118C06501_VALUE}".
    SHOULD BE TRUE    ${actual_value} == ${M55118C06501_VALUE}
    ...    msg=${error_msg}

Verify M55118C06502 counter
    ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}    ${M55118C06502_PATH}    ${NUMBER_OF_MEASUREMENTS}
    ${error_msg}=    Catenate
    ...    RRC Reconfigurations successful releasing SCell triggered by A2 measurement didn't meet expected amount.
    ...    Was: "${actual_value}", expected: "${M55118C06502_VALUE}".
    SHOULD BE TRUE    ${actual_value} == ${M55118C06502_VALUE}
    ...    msg=${error_msg}
