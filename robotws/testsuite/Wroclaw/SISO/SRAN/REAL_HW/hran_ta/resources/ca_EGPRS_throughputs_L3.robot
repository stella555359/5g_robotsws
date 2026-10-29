*** Settings ***
Documentation
...  Resource for EGPRS data transfer

Library           taf.ue
Library           hran_bsc
Resource          ca_siso_hran.robot
Resource          ../../Resources/SiSo_L3_call.robot



*** Keywords ***

step${step_number}: Open BSC session

    Log To Console    ${\n}step${step_number}: Open BSC session
    hran_bsc.Bsc SSH Connection  host=${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}

step${step_number}: TC precondition
    [Documentation]
    ...  To use this KW please define global variables: @{SELECTED_CELLS} as a list
    ...  ex. Set Test Variable  @{SELECTED_CELLS}  <gsmSectorID_1>  <gsmSectorID_2>
    ...  ${CELLS_YAML_PATH} define cells yaml file path
    ...  It checks if defined BTS Ids exist in configuration and creates GSM BTS Ids list.
    ...  *AUTHOR*  lukasz.wystup@nokia.com  *MAINTAINER*  daniel.bartkowiak@nokia.com

    Log To Console    ${\n}step${step_number}: TC precondition
    SiSo Convert Id to Runtime Distname  gsm
    ${user_data_status}=    Run Keyword And Return Status    Should Not Be Empty    ${SELECTED_CELLS}
    Run Keyword If  not ${user_data_status}    Fail    No input data defined by user
    ${bcf_id}=    SiSo Get bcfId
    ${CELLS_FOR_CALL_DICT}=  ca_EGPRS_throughputs_L3.Preconditions For Call  ${SELECTED_CELLS}
    Set Test Variable  ${CELLS_FOR_CALL_DICT}
    ${bts_ids_list}=    Get Dictionary Keys    ${CELLS_FOR_CALL_DICT}
    ${bts_ids_list_from_BCF}=    hran_bsc.Get Sectors Ids    ${bcf_id}    ${False}
    ${status}  ${bts_ids_list_correctness}=  Run Keyword And Ignore Error  List Should Contain Sub List  ${bts_ids_list_from_BCF}  ${bts_ids_list}
    Run Keyword If    '${status}' == 'FAIL'    Fail    User defined incorrect BTS ID: ${bts_ids_list_correctness}

    ${GSM_cells_ids_list_from_BCF}=  hran_bsc.Get Gsm Cells Ids  ${bcf_id}
    ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY}  Evaluate    {key: value for key, value in zip(${bts_ids_list_from_BCF}, ${GSM_cells_ids_list_from_BCF})}
    Set Test Variable  ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY}

    Set Test Variable    ${bts_ids_list}
    ${trx_with_low_tp}=    Create List
    Set Test Variable    ${trx_with_low_tp}
    ${incorrect_bts_ids_list}    Create List
    Log To Console    BTS_ID list selected by user to data transfer procedure ${bts_ids_list}${\n}

step${step_number}: Data transfer via every TRX
    Log To Console    step${step_number}: Data transfer via every TRX${\n}
	SiSo Reject All Cells For Call
	SiSo Prepare Ues  ${CELLS_FOR_CALL_DICT}
    FOR    ${actual_bts_id}    IN    @{CELLS_FOR_CALL_DICT.keys()}  #zmiana
        Log To Console  ${\n}------------------------------
        Log To Console  Call started on cell ${actual_bts_id}
        Log To Console  ------------------------------
        ${cell_params_dict}  ${technology}  ${bts}=  SiSo Set Specific Variables For Call  ${CELLS_FOR_CALL_DICT}  ${actual_bts_id}
        Log to console  Checking if UE ${SN} is attached to proper cell...${\n}
        Run Keyword And Continue On Failure  SiSo Accept Cell For Call  ${cell_params_dict}  ${technology}  ${bts}
        Run Keyword If  '${ACCEPT_STAT}'=='FAIL'  Fail  RXP/GRXP parameter for BTS-${actual_bts_id} couldn't be set. Try again.
		${attach_status}=  Run Keyword And Continue On Failure  SiSo Attach  ${cell_params_dict}  ${technology}  ${bts}  ${actual_bts_id}
		Run Keyword If  not ${attach_status}  Fail  UE ${SN} attach error. Check logs.
        ${trx_list}=    hran_bsc.Get Trxs List By Bts Id    ${actual_bts_id}   ${False}
        Log To Console    \nStart data transfer for BTS ${actual_bts_id} via every TRX from list ${trx_list}
        ${trx_with_active_call}=    Create List
        ${trx_with_active_call}=    ca_EGPRS_throughputs_L3.Make Call    ${trx_list}    ${actual_bts_id}    ${trx_with_active_call}
        ca_EGPRS_throughputs_L3.Lock_unlock Time Slots    ${trx_with_active_call}    ${actual_bts_id}    U
        ${trx_list}=    hran_bsc.Get Trxs List By Bts Id    ${actual_bts_id}   ${False}
        ${trx_without_active_call}  Evaluate  list(set(${trx_list}) - set(${trx_with_active_call}))
        Should Be Empty    ${trx_without_active_call}    msg=No allocation active call on TRX ${trx_without_active_call}
        Log To Console    Data transfer on BTS ${actual_bts_id} via every TRX has finished with success
		Run Keyword And Continue On Failure  taf.ue.Detach Ue    ue_alias=ue_${SN}
		Run Keyword And Continue On Failure  SiSo Reject Cell For Call  ${cell_params_dict}  ${technology}  ${bts}
    END
    Should Be Empty    ${trx_with_low_tp}    msg=To low throughput value on TRX - ${trx_with_low_tp}
    [Teardown]    Run Keywords  ca_EGPRS_throughputs_L3.UnLock TimeSlots And Close BSC    ${trx_with_active_call}    ${actual_bts_id}
	...  AND  SiSo Accept All Cells For Call
    ...  AND  Run Keyword And Ignore Error  sshLibrary.Close Connection
    ...  AND  SiSo Teardown connection to Btses

Make Call
    [Arguments]    ${trx_list}    ${actual_bts_id}    ${trx_with_active_call}
    FOR    ${trx}    IN    @{trx_list}
        Log To Console    \nCreate data transfer Tput_${trx}
        Log To Console    Start Uplink Datatransfer ${trx}_UL
        taf.ue.Start Data Transfer  ${trx}_UL  ue_${SN}  UL  duration=4min  protocol=udp  throughput=${UL_TPUT_MAX}  packet=1300
        ${trx_to_lock_UL}=  Wait Until Keyword Succeeds  3 min  10 sec
        ...  ca_EGPRS_throughputs_L3.Find TRX With Active Call  ${trx_list}  ${actual_bts_id}
        Sleep    30s    For TP average measurement
        ${UL_throughput_status}  ${UL_throughput_return}=  Run Keyword And Ignore Error  taf.ue.Verify Average Throughput
        ...  ${trx}_UL  ${UL_TPUT_MIN}  ${UL_TPUT_MAX}
        Log To Console    Stop Uplink Datatransfer ${trx}_UL
        taf.ue.Stop Data Transfer    ${trx}_UL
        Log To Console    Start Downlink Datatransfer ${trx}_DL
        taf.ue.Start Data Transfer  ${trx}_DL  ue_${SN}  DL  duration=4min  protocol=udp  throughput=${DL_TPUT_MAX}  packet=1300
        ${trx_to_lock_DL}=  Wait Until Keyword Succeeds  3 min  10 sec
        ...  ca_EGPRS_throughputs_L3.Find TRX With Active Call  ${trx_list}  ${actual_bts_id}
        Sleep    30s    For TP average measurement
        ${DL_throughput_status}  ${DL_throughput_return}=  Run Keyword And Ignore Error  taf.ue.Verify Average Throughput
        ...  ${trx}_DL  ${DL_TPUT_MIN}  ${DL_TPUT_MAX}
        Log To Console    Stop Downlink Datatransfer ${trx}_DL
        taf.ue.Stop Data Transfer    ${trx}_DL
        Run Keyword And Ignore Error  Siso Refresh BSC Connection
        Run Keyword If  '${DL_throughput_status}'=='PASS'  Log To Console  ${trx}_DL tput is in desired range: ${DL_TPUT_MIN} <-> ${DL_TPUT_MAX}
        Run Keyword If  not '${DL_throughput_status}'=='PASS'    Run Keywords
        ...    Log To Console    ${DL_throughput_return}     AND
        ...    ca_EGPRS_throughputs_L3.Repeat Call    ${trx}    downlink   DL
        Run Keyword If  '${UL_throughput_status}'=='PASS'  Log To Console  ${trx}_UL tput is in desired range: ${UL_TPUT_MIN} <-> ${UL_TPUT_MAX}
        Run Keyword If  not '${UL_throughput_status}'=='PASS'    Run Keywords
        ...    Log To Console    ${UL_throughput_return}    AND
        ...    ca_EGPRS_throughputs_L3.Repeat Call    ${trx}    uplink    UL
        Should Be Equal    ${trx_to_lock_UL}    ${trx_to_lock_DL}    msg=TPut UL allocated on other TRX than TPut DL
        Append To List    ${trx_with_active_call}    ${trx_to_lock_UL[0]}
        Remove Values From List    ${trx_list}    ${trx_to_lock_UL[0]}
        ca_EGPRS_throughputs_L3.Lock_unlock Time Slots    ${trx_to_lock_UL}    ${actual_bts_id}    L
        Sleep    3s    Pilot allocation on next TRX
    END
    [Return]      ${trx_with_active_call}

Find TRX With Active Call
    [Arguments]    ${trx_list}    ${actual_bts_id}
    ${trx_to_lock}=    Create List
    FOR    ${trx}    IN    @{trx_list}
        ${existing_GP_status}  ${existing_GP_return}=  Run Keyword And Ignore Error
        ...  hran_bsc.Parse Trx Timeslot Status  ${actual_bts_id}  ${trx}  GP  4  True
        Run Keyword If    '${existing_GP_status}'=='FAIL'    ca_EGPRS_throughputs_L3.Lock_unlock Time Slots    ${trx_list}    ${actual_bts_id}    U
        Run Keyword If    '${existing_GP_return}'=='True'    Run Keywords
        ...    Log To Console    Data transfer allocated on TRX=${trx}    AND
        ...    Append To List    ${trx_to_lock}    ${trx}
    END
    Should Not Be Empty    ${trx_to_lock}    msg=No active data transfer on BTS ${actual_bts_id}
    [Return]    ${trx_to_lock}

Lock_unlock Time Slots
    [Arguments]    ${trx_list}    ${actual_bts_id}    ${action}
    FOR    ${trx}    IN    @{trx_list}
        Log To Console    Start ${action} action for TRX=${trx}
        hran_bsc.Write   ZERS:BTS=${actual_bts_id},TRX=${trx},CH=0&&7:${action};
        hran_bsc.Write   ZERS:BTS=${actual_bts_id},TRX=${trx},CH=2&&7:${action};
        Sleep  5s  Wait for BSC
    END

Repeat Call
    [Arguments]    ${trx}    ${direction}    ${direction_tp}
    Log To Console    Repeat ${trx}_${direction}
    taf.ue.Start Data Transfer  ${trx}_${direction}  ue_${SN}  ${direction_tp}  duration=60s  throughput=${${direction_tp}_TPUT_MAX}  protocol=udp
    ...  packet=1300
    Run Keyword And Ignore Error    taf.ue.Await Data Transfer Finish    ${trx}_${direction}
    ${repeat_throughput_status}  ${repeat_throughput_return}=  Run Keyword And Ignore Error
    ...  taf.ue.Verify Average Throughput  ${trx}_${direction}  ${${direction_tp}_TPUT_MIN}  ${${direction_tp}_TPUT_MAX}
    Run Keyword If    '${repeat_throughput_status}'=='PASS'
    ...  Log To Console    ${trx}_${direction} tput is in desired range: ${${direction_tp}_TPUT_MIN} <-> ${${direction_tp}_TPUT_MAX}
    Run Keyword If  not '${repeat_throughput_status}'=='PASS'    Run Keywords
    ...    Append To List    ${trx_with_low_tp}    ${trx}    AND
    ...    Log To Console    ${repeat_throughput_return}

UnLock TimeSlots And Close BSC
    [Documentation]    KW checked if after TC crash some time slots on actual BTS are in locked state and unlocked them.
    [Arguments]    ${trx_with_active_call}    ${actual_bts_id}
    FOR    ${trx}    IN    @{trx_with_active_call}
      ${existing_GP_status}  ${existing_GP_return}=  Run Keyword And Ignore Error  Parse Trx Timeslot Status  ${actual_bts_id}  ${trx}  GP  4  True
      Run Keyword If  '${existing_GP_status}'=='FAIL'  ca_EGPRS_throughputs_L3.Lock_unlock Time Slots  ${trx_with_active_call}  ${actual_bts_id}  U
    END
    hran_bsc.Close All Connections

Preconditions For Call
    [Arguments]  ${cells_input}
    Set Test Variable  ${LOGS_DIR}  ${BTS Files}
    Import Variables  ${CELLS_YAML_PATH}
#    SiSo Restart Proxy
    SiSo Set Global Variables For Call
    SiSo Setup Connection To Btses
    SiSo Get Parameters From BTSes
    SiSo Set Connection to OMS And BSC
    ${cells_for_call_dict}=  SiSo Create Cells Dict For Call  ${cells_input}
    [Return]  ${cells_for_call_dict}
