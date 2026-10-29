*** Settings ***
Documentation
...    = Author =
...    _aleksandra.chudzik@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    karol.sadowski@nokia.com
...    Review link: https://wrgitlab.ext.net.nokia.com/RAN/robotlte/-/merge_requests/28656#note_3292709

*** Keywords ***
CBRS_CB008735_FeVe_19_ET_Grant_update_failed_since_TS1_2_SAS_not_support_WF_GRANT_UPDATE
    [Documentation]    Tested Requirement: OAM_REQ_CBRS_131
	...                Test case verifies if grant update procedure will not be proceeded when not supported
	...                version TS1.2 is used. CBSD receives heartbeat response message with responseCode 0 and with
	...                operationParam from SAS which not support WF_GRANT_UPDATE feature.
	...                Test Steps:
    ...                1.Start SAS Simulator v1.2
    ...                2.Check if TS Version is 1.2
    ...                3.Check SAS logs:
    ...                  - verifiy maxEirp value
    ...                  - verify if relinquishmentRequest occurred
    ...                4.Check current maxEirp value

    Log To Console    Preconditions - cbrsFreqType set to GAA
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
	${selected_grantId}   Set Variable    3550000000_3570000000

    Log To Console    Kill SAS if exists
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}

    Replace Variables In File    ${CURDIR}/Data/FeVe_19/precondition_delta.json
    ...                          ${OUTPUT_DIR}/precondition_delta.json
    ...                          enb_id=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_19/postcondition_delta.json
    ...                          ${OUTPUT_DIR}/postcondition_delta.json
    ...                          enb_id=${enb_id}

	Wait Until Keyword Succeeds    5x    30s    Run Keywords
	...                                         Wait Until BTS Is Not Busy    AND
	...                                         Perform Delta Recommissioning
    ...                                         ${OUTPUT_DIR}/precondition_delta.json
    ...                                         connection=${alias}

	Log To Console    Step 1. Start SAS Simulator v1.2
	Enable CBRS Feature On eNB
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_19/SAS_Sim.conf
	${time_start}   Get Time
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection
    ${time_stop}   Get Time

	Log To Console    Step 2. Check if TS Version is 1.2
	Check If TS Version Is As Expected    enb_id=${enb_id}
	...                                   alias=${alias}
	...                                   version=1.2

	Log To Console    Step 3. Check SAS logs
    ${parsed_log_file}   Parse SAS Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${time_start}
    ...                                          date_stop=${time_stop}
    ${grantrequest_msg}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                    data_type=grantRequest
    ...                                                    parameter=maxEirp

	Should Be Equal As Numbers    ${grantrequest_msg[0]}    27.0

    ${parsed_SAS_communication}   Communication CBSD SAS    SAS_Sim_log_file=${sas_logs_dir}
    ${count_relinquishmentRequest}    Get Match Count    ${parsed_SAS_communication}     *relinquishmentRequest
    Should Be Equal As Integers    ${count_relinquishmentRequest}    1    msg=Wrong number of relinquishmentRequest visible in SAS_Sim.log
    Log To Console    Exact one relinquishmentRequest found in SAS_Sim.log

	Log To Console    Step 4. Check current maxEirp value
	${grant_info}   Get Grant Details For Each CBSD Cell
    ${grantMaxEirp}   Get grantMaxEirp For Selected GrantId
    ...                 grant_info=${grant_info}
    ...                 selected_grantId=${selected_grantId}
    Should Be Equal As Numbers    ${grantMaxEirp}    28

    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Wait Until BTS Is Not Busy    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Delta Recommissioning
    ...                                                ${OUTPUT_DIR}/postcondition_delta.json
    ...                                                connection=${alias}    AND
    ...    Kill All SAS Processes
