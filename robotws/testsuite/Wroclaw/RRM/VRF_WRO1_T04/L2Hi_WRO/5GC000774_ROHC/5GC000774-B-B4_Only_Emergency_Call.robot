*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library    ta5g_pm_counters
Library     keywords_ROHC.py
Library     taf.config.wts    WITH NAME    wts

Documentation
...    author: Anna Chabik
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 22R2

Suite Setup      Run Keywords    Modify Config To Emergency Call
...            AND    Prepare Sa Test Environement And Reach Onair
...               perform_tl_reset=${RESET_TL}
...               cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
...               cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
...               cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
...            AND    Enable Rohc Param For Gnb
...            AND    Enable Syslog Debug Prints For Rohc
...            AND    Wait For Next Full Pm Interval

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${UE_ID_TDD}=    1
${UE_ID_FDD}=    20
${CELL_ID_FDD}=   3

*** Test Cases ***
5GC000774-B-B4_Verification_Of_Ctx_Pm_Counters_With_Only_Emergency_Call_TDD
    Attach One 5g Ue With Emergency Session Capable Of Supporting Rohc
    Start Dl And Ul Data Traffic For Emergency Session
    Display Emergency Call Statistics
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long
    Wait For Next Full Pm Interval
    Verify Rohc Contexts Pm Counters Values
    Deregister Ue    ${UE_ID_TDD}

5GC000774-B-B4_Verification_Of_Ctx_Pm_Counters_With_Only_Emergency_Call_FDD
    Attach One 5g Ue With Emergency Session Capable Of Supporting Rohc    ${UE_ID_FDD}
    Start Dl And Ul Data Traffic For Emergency Session    ${UE_ID_FDD}
    Display Emergency Call Statistics    ${CELL_ID_FDD}
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=${CELL_ID_FDD} format=long
    Wait For Next Full Pm Interval
    Verify Rohc Contexts Pm Counters Values    ${CELL_ID_FDD}
    Deregister Ue    ${UE_ID_FDD}

*** Keywords ***
Enable Rohc Param For Gnb
    Enable Vonr And Rohc TDD FDD
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Vonr_and_Rohc/delta_enable_emergency_call.json
    Sleep    1s

Attach One 5g Ue With Emergency Session Capable Of Supporting Rohc
    [Arguments]    ${UE_ID}=${1}
    Set Internal Traffic Type To UEs    ${UE_ID}
    Attach Ue    ${UE_ID}
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${UE_ID} pdu=1 nwslice=1 gw=1 request_type=initial-emergency-request
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${ICS_SETUP_RESP_SUCCESS}
    Modify Pdu Session And Wait For Regexp    ${UE_ID}    qos_id=1    qfi_id=2    5qi_id=8
    Modify Pdu Session And Wait For Regexp    ${UE_ID}    qos_id=3    qfi_id=3    5qi_id=1
    Execute Egate Command    cmd=ue_pdu_session_modify ue=${UE_ID} pdu=1 qosflows_to_add=3 by=amf
    Sleep    3s

Start Dl And Ul Data Traffic For Emergency Session
    [Arguments]    ${UE_ID}=${1}
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 trf_id=2 kbps=10 dir=dl
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 trf_id=1 kbps=10 dir=ul
    Sleep    3s

Display Emergency Call Statistics
    [Arguments]    ${CELL_ID}=${1}
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=${CELL_ID} format=long

Verify Rohc Contexts Pm Counters Values
    [Arguments]    ${CELL_ID}=${1}
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_REQ_SENT}
    ...    value=2    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_RESP_RECD}
    ...    value=2    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_REQ_SENT}
    ...    value=2    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_CMP_RECD}
    ...    value=2    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}    filepath=${PM_COUNTERS}
