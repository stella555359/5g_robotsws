*** Settings ***
Documentation
...    = Author =
...    _aleksandra.chudzik@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    jakub.klein@nokia.com
...    justyna.durak@nokia.com
...    katarzyna.olszewska@nokia.com

*** Keywords ***
CBRS_LTE5703_FeVe_75_Heartbeat_negotiation_after_4532_fault_and_receiving_responseCode_501-EDA
    [Documentation]    Tested Requirement: OM_GEN_SFS_CBRS.381. Purpose: This test case verifies whether the eNB continues
    ...                heartbeat negotiation with SAS after 4532 fault raised and heartbeatResponse with responseCode: 501
    ...                SUSPENDED_GRANT received. CBSD should not set the grant state to Idle.


    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarm_1}   Create Dictionary    fault_id=4532    fault_name=CBRS Power Level Violation    severity=Warning
    &{expected_alarm_2}   Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure    severity=Critical
    ...                                          reason=responseCode : 501 transmitExpireTime expires.
    ${expected_alarms_list}      Create List    ${expected_alarm_1}    ${expected_alarm_2}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}

    Log To Console    Kill SAS if exists
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Log To Console    Preconditions
    Replace Variables In File    ${CURDIR}/Data/FeVe_75/precondition_delta.json
    ...                          ${OUTPUT_DIR}/precondition_delta.json
    ...                          enb_id=${enb_id}

    Replace Variables In File    ${CURDIR}/Data/FeVe_75/postcondition_delta.json
    ...                          ${OUTPUT_DIR}/postcondition_delta.json
    ...                          enb_id=${enb_id}

    Wait Until Keyword Succeeds    12x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition_delta.json    connection=${alias}

    Log To Console    Step 1. Start SAS
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/FeVe_75/SAS_Sim.conf

    Enable CBRS Feature On eNB
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                   severity=${expected_alarm_1}[severity]    timeout=60
    Wait For All Cells To Be OnAir

    ${cbsd_id}   Wait Until Keyword Succeeds    20x    30s    Get CBSD Id From Infomodel
    ${grant_1}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=1

    Log To Console    Step 2. Grant suspension on chosen cell
    Send Command To SAS Manager    alias=default    command=grant_suspend ${cbsd_id} ${grant_1}

    Log To Console    Step 3. Verifying the grant ID after grant suspension
    Wait Until Keyword Succeeds    100x    2s    Query Infomodel
    ...    query=check /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNCEL_R-1 is [operationalState=regex"(?i)Disabled"]
    ...    alias=${alias}
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    timeout=30

	#25R3 - CBSD no longer changes state to disabled and FID6825 not raised
	Run Keyword and ignore error    Wait For Watchdog Alarm Activation
    ...    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...    severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]    timeout=30

    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                     severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]    timeout=90
    Wait For All Cells To Be OnAir

	#25R3 - added check for alarm_1
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                   severity=${expected_alarm_1}[severity]    timeout=60
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    reason=${expected_alarm_2}[reason]    timeout=60
    Sleep    30s
    #

    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                        severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]

    ${new_grant_1}   Fetch Grant ID of selected cell    enb_id=${enb_id}    cell_number=1
    Should Not Be Equal    ${grant_1}    ${new_grant_1}

    Log To Console    Checking whether heartbeat message with responseCode: 501 is presented in SAS_Sim.log
    ${heartbeatresponse_501}   Run    grep -n '"responseCode": 501' ${sas_log} | tail -n1
    Should Not Be Empty    ${heartbeatresponse_501}

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until BTS Is Not Busy    alias=${alias}    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/postcondition_delta.json    connection=${alias}    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes