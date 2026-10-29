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
...    elzbieta.wlodarczyk@nokia.com
...    Review link: https://l3-sim-krk-serv.dynamic.nsn-net.net/r/1445/

*** Keywords ***
CBRS_CB008735_FeVe_12_ET_Grant_update_channelType_PAL_GAA_will_not_happen_with_TS1_2
    [Documentation]    Tested Requirement: OAM_REQ_CBRS_172
    ...                Purpose: This user scenario verifies Grant Update Procedure with not supported wWINNFTSVersion 1.2.
    ...                The grant update will not happen despite of forcing channeltype group change to GAA and receiving
    ...                heartbeat response message with responseCode 0
    ...                Test Steps:
    ...                1.Change cbrsFreqType to PAL
    ...                2.Start SAS Simulator v1.2 with forcing channeltype group change to GAA
    ...                3.Verify if grantChannelType did not changed
    ...                4.Verify response code 0 in heartbeat response message

    Log To Console    Preconditions - cbrsFreqType set to GAA
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}

    Log To Console    Kill SAS if exists
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}

    Log To Console    Step 1. Change cbrsFreqType to PAL
    Wait Until Keyword Succeeds    5x    30s    Perform Parameter Recommissioning
    ...                                         dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBSD-1
    ...                                         parameter=cbrsFreqType
    ...                                         operation=update
    ...                                         value=PAL
    ...                                         connection=RAT_1ST
    Enable CBRS Feature On eNB

    Log To Console    Step 2. Start SAS Simulator v1.2
    Log To Console    Forcing channeltype to GAA
    # Force_heartbeat_channeltype_group is set for GAA update after the first heartbeat
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/Feve12/SAS_Sim.conf

    ${time_start}   Get Time
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    Log To Console    Step 3. Verify if grantChannelType did not changed
	${num_of_cells}   Get Number of Cells    ${enb_id}
    FOR    ${i}    IN RANGE    ${1}    ${num_of_cells}+1
	    ${grantChannelType_cell}   Get Channel Type For Cell    enb_id=${enb_id}    cell_number=${i}
	    Should Be Equal    ${grantChannelType_cell}    PAL
	END

    ${time_stop}   Get Time

    Log To Console    Step 4. Check SAS logs
    ${parsed_log_file}   Parse SAS Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${time_start}
    ...                                          date_stop=${time_stop}
    ${HB_response_codes}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                     data_type=heartbeatResponse
    ...                                                     parameter=responseCode
    ${code}   Convert To Integer    0
    Should Contain X Times    container=${HB_response_codes[0:4]}    item=${code}    count=4

    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Wait Until Keyword Succeeds    5x    30s    Perform Parameter Recommissioning
    ...                                                dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBSD-1
    ...                                                parameter=cbrsFreqType
    ...                                                operation=update
    ...                                                value=GAA
    ...                                                connection=RAT_1ST    AND
    ...    Kill All SAS Processes