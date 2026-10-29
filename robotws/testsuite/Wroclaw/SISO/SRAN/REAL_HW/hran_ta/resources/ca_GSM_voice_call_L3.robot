*** Settings ***
Documentation
...  Resource for GSM voice call

Library           taf.ue
Library           hran_bsc
Resource          ca_siso_hran.robot
Resource          ../../Resources/SiSo_L3_call.robot



*** Keywords ***

step${step_number}: Open BSC session
    Log To Console    ${\n} step${step_number}: Open BSC session
    hran_bsc.Bsc SSH Connection  host=${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}

step${step_number}: TC precondition
    [Documentation]
    ...  To use this KW please define global variables: @{SELECTED_CELLS} as a list
    ...  ex. Set Test Variable  @{SELECTED_CELLS}    <gsmSectorID_1>  <gsmSectorID_2>
    ...  ${CELLS_YAML_PATH} define cells yaml file path
    ...  It checks if defined BTS Ids exist in configuration and is deployed on proper radio module, creates GSM BTS Ids list.
    ...  *AUTHOR*  lukasz.wystup@nokia.com  *MAINTAINER*  daniel.bartkowiak@nokia.com

    Log To Console    ${\n}step${step_number}: TC precondition
    SiSo Convert Id to Runtime Distname  gsm
    ${user_data_status}=    Run Keyword And Return Status    Should Not Be Empty    ${SELECTED_CELLS}
    Run Keyword If  not ${user_data_status}    Fail    No input data defined by user
    ${bcf_id}=    SiSo Get bcfId
    ${CELLS_FOR_CALL_DICT}=  ca_GSM_voice_call_L3.Preconditions For Call  ${SELECTED_CELLS}
    Set Test Variable  ${CELLS_FOR_CALL_DICT}
    ${bts_ids_list}=    Get Dictionary Keys    ${CELLS_FOR_CALL_DICT}
    ${bts_ids_list_from_BCF}=    hran_bsc.Get Sectors Ids    ${bcf_id}    ${False}
    ${status}  ${bts_ids_list_propriety}=  Run Keyword And Ignore Error  List Should Contain Sub List  ${bts_ids_list_from_BCF}  ${bts_ids_list}
    Run Keyword If    '${status}' == 'FAIL'    Fail    User defined incorrect BTS ID: ${bts_ids_list_propriety}

    ${GSM_cells_ids_list_from_BCF}=  hran_bsc.Get Gsm Cells Ids  ${bcf_id}
    ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY}  Evaluate    {key: value for key, value in zip(${bts_ids_list_from_BCF}, ${GSM_cells_ids_list_from_BCF})}
    Set Test Variable  ${BTS_IDS_GSM_CELLS_IDS_DICTIONARY}
    Set Test Variable    ${bts_ids_list}
    Log To Console    BTS_ID list selected by user to voice call procedure ${bts_ids_list}${\n}

step${step_number}: Voice call via every TRX
    [Documentation]    This KW make AMR call via every TRX under selected BTS and find TRX with active call.
    ...  *AUTHOR*  lukasz.wystup@nokia.com

    Log To Console    step${step_number}: Voice call via every TRX${\n}
	SiSo Reject All Cells For Call
	SiSo Prepare Ues  ${CELLS_FOR_CALL_DICT}
    ${trials}=    Set Variable    3
    ${proper_call_status}=    Set Variable    False
    FOR    ${trial}    IN RANGE    1    ${trials}+1
        Sleep  10s
        ${proper_call_status}=    ca_GSM_voice_call_L3.Make Call Via Each TRX    ${proper_call_status}
        Run Keyword If    '${proper_call_status}'=='True'    Exit For Loop
        Log To Console    ${trial} repetitions of the voice call procedure
    END
    hran_bsc.Close All Connections
    Run Keyword If    '${proper_call_status}'=='False'    Fail    ${trials} attempts voice calls unsuccessful - problem with voice call realization
    [Teardown]    Run Keywords  SiSo Accept All Cells For Call
    ...  AND  Run Keyword If  '${KEYWORD STATUS}'=='FAIL'  TRX Recovery
    ...  AND  Run Keyword And Ignore Error  sshLibrary.Close Connection
    ...  AND  SiSo Teardown connection to Btses

Make Call Via Each TRX
    [Arguments]    ${proper_call_status}
    FOR    ${actual_bts_id}    IN    @{CELLS_FOR_CALL_DICT.keys()}
        ${cell_params_dict}  ${technology}  ${bts}=  SiSo Set Specific Variables For Call  ${CELLS_FOR_CALL_DICT}  ${actual_bts_id}
        Log to console  Checking if UE ${SN} is attached to proper cell...${\n}
		Run Keyword And Continue On Failure  SiSo Accept Cell For Call  ${cell_params_dict}  ${technology}  ${bts}
		Run Keyword If  '${ACCEPT_STAT}'=='FAIL'  Fail  RXP/GRXP parameter for BTS-${actual_bts_id} couldn't be set. Try again.
		${attach_status}=  Run Keyword And Continue On Failure  SiSo Attach  ${cell_params_dict}  ${technology}  ${bts}  ${actual_bts_id}
		Run Keyword If  not ${attach_status}  Fail  UE ${SN} attach error. Check logs.
        ${trx_list}=    hran_bsc.Get Trxs List By Bts Id    ${actual_bts_id}   ${False}
        Log To Console    \nStart voice call for BTS ${actual_bts_id} via every TRX from list ${trx_list}
        ${trx_with_active_call}=    Create List
        ${trx_with_active_call}=    ca_GSM_voice_call_L3.Make Call    ${trx_list}    ${actual_bts_id}    ${trx_with_active_call}
        ca_GSM_voice_call_L3.Lock_unlock Time Slots    ${trx_with_active_call}    ${actual_bts_id}    U
        ${proper_call_status}=    Run Keyword And Return Status    List Should Not Contain Value    ${trx_with_active_call}    ERROR
        Run Keyword If  not ${proper_call_status}   Exit For Loop
        List Should Not Contain Duplicates    ${trx_with_active_call}    msg=Call allocated few times on this same TRX
        ${trx_without_active_call}  Evaluate  list(set(${trx_list}) - set(${trx_with_active_call}))
        Should Be Empty    ${trx_without_active_call}    msg=No allocation active call on TRX ${trx_without_active_call}
        Log To Console    Voice call on BTS ${actual_bts_id} via every TRX has finished with success
        Remove Values From List    ${bts_ids_list}    ${actual_bts_id}
		Run Keyword And Continue On Failure  taf.ue.Detach Ue    ue_alias=ue_${SN}
		Run Keyword And Continue On Failure  SiSo Reject Cell For Call  ${cell_params_dict}  ${technology}  ${bts}
    END
    [Return]    ${proper_call_status}

Make Call
    [Arguments]    ${trx_list}    ${actual_bts_id}    ${trx_with_active_call}

    FOR    ${trx}    IN    @{trx_list}
        Log To Console    Start voice call VOICE_${trx}
        Run Keyword And Ignore Error    taf.ue.Start Voice Call    VOICE_${trx}    ue_${SN}    ${AUTO_RESP_NUM}
        Sleep  5s  Wait for ue to connect
        ${trx_to_lock}=    ca_GSM_voice_call_L3.Find TRX With Active Call    ${trx_list}    ${actual_bts_id}
        Log To Console    Stop voice call VOICE_${trx}
        ${voice_call_finish_status}=    Run Keyword And Return Status    taf.ue.Stop Voice Call  VOICE_${trx}
		Run Keyword And Ignore Error  Siso Refresh BSC Connection
        Run Keyword If  not ${voice_call_finish_status}    Run Keywords
         ...    Append To List   ${trx_with_active_call}    ERROR    AND
         ...    Log To Console   There is some problem with voice call realization on TRX=${trx}    AND
         ...    Exit For Loop
        Run Keyword And Ignore Error  Append To List    ${trx_with_active_call}    ${trx_to_lock[0]}
        ${trx_with_active_call_status}=    Run Keyword And Return Status    Should Not Be Empty    ${trx_with_active_call}
        Run Keyword If  not ${trx_with_active_call_status}    Fail    No active call on BTS ${actual_bts_id} - probably defined wrong BTS_ID value
        Remove Values From List    ${trx_list}    ${trx_to_lock[0]}
        ca_GSM_voice_call_L3.Lock_unlock Time Slots    ${trx_to_lock}    ${actual_bts_id}    L
        Sleep    3s    Pilot allocation on next TRX
    END
    [Return]      ${trx_with_active_call}

Find TRX With Active Call
    [Arguments]    ${trx_list}    ${actual_bts_id}
    ${trx_to_lock}=    Create List
    FOR    ${trx}    IN    @{trx_list}
        ${actual_trx_list}=  Create List  ${trx}
        ca_GSM_voice_call_L3.Lock_unlock Time Slots    ${actual_trx_list}    ${actual_bts_id}    U
        ${existing_FR_status}=    hran_bsc.Parse Trx Timeslot Status    ${actual_bts_id}    ${trx}    FR    1    True
        Run Keyword If  not ${existing_FR_status}    ca_GSM_voice_call_L3.Lock_unlock Time Slots    ${trx_list}    ${actual_bts_id}    U
        Run Keyword If    ${existing_FR_status}    Run Keywords
        ...    Append To List  ${trx_to_lock}    ${trx}    AND
        ...    Log To Console    Voice call allocated on TRX=${trx}
    END
    [Return]    ${trx_to_lock}

Lock_unlock Time Slots
    [Arguments]    ${trx_list}    ${actual_bts_id}    ${action}
    FOR    ${trx}    IN    @{trx_list}
        Continue For Loop If  "${trx}"=="ERROR"
#        Log To Console    Start ${action} action for TRX=${trx}
        hran_bsc.Write   ZERS:BTS=${actual_bts_id},TRX=${trx},CH=0&&7:${action};
        hran_bsc.Write   ZERS:BTS=${actual_bts_id},TRX=${trx},CH=1&&7:${action};
        Sleep  5s  Wait for BSC
        hran_bsc.Get Transceiver Parameters  ${actual_bts_id}  ${trx}
    END

Preconditions For Call
    [Arguments]  ${cells_input}
    Set Test Variable  ${LOGS_DIR}  ${BTS Files}
    Import Variables  ${CELLS_YAML_PATH}
#	SiSo Restart Proxy
    SiSo Set Global Variables For Call
    SiSo Setup Connection To Btses
    SiSo Get Parameters From BTSes
    SiSo Set Connection to OMS And BSC
    ${cells_for_call_dict}=  SiSo Create Cells Dict For Call  ${cells_input}
	[Return]  ${cells_for_call_dict}

TRX Recovery
    FOR    ${actual_bts_id}    IN    @{CELLS_FOR_CALL_DICT.keys()}
      ${trx_list}=    hran_bsc.Get Trxs List By Bts Id    ${actual_bts_id}   ${False}
      ca_GSM_voice_call_L3.Lock_unlock Time Slots    ${trx_list}    ${actual_bts_id}    U
    END
