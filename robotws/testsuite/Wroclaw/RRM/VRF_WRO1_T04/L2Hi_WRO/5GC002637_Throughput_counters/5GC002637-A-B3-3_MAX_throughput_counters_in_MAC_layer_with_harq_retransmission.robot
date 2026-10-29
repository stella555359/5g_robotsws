*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library     keywords_5GC002637.py
Documentation
...    author: Mariusz Waczynski
...    maintainer: Mariusz Waczynski (mmariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 22R3

Test Setup      Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}

Test Teardown    Run Keywords    Check For An Unexpected Alarm
    ...       AND    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Test Cases ***
5GC002637-A-B3-3_MAX_throughput_counters_in_MAC_layer_with_harq_retransmission
    Set Internal Traffic Type To UEs
    Register Ue With Default Pdu Session
    Start Dl And Ul Data Traffic
    Check Troughput Counters
    Check Troughput And Packets Lost
    Deregister Ue    ue_id=1

*** Keywords ***
Start Dl And Ul Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=50
    Sleep    10s
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=50
    Sleep    ${TRAFFIC_DURATION_SEC}

Display Ue Statistics
    Display Qfi stats    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Check Troughput Counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
	${DL_COUNTER_BEFORE}=    get_pm_counter_value    counter_id=M55309C12001
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    ${UL_COUNTER_BEFORE}=    get_pm_counter_value    counter_id=M55309C12002
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Add Harq Error For Ue
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
	${DL_COUNTER_AFTER}=    get_pm_counter_value    counter_id=M55309C12001
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    ${UL_COUNTER_AFTER}=    get_pm_counter_value    counter_id=M55309C12002
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Check If Pm Counters Have The Same Value    first_counter_id=${DL_COUNTER_BEFORE}       second_counter_id=${DL_COUNTER_AFTER}
    Check If Pm Counters Have The Same Value    first_counter_id=${UL_COUNTER_BEFORE}       second_counter_id=${UL_COUNTER_AFTER}

Add Harq Error For Ue
    Execute Egate Command    cmd=ue_harq_error id=1 tb1_err_ratio=0-7:100:5:0 tb2_err_ratio=0-7:100:5:0
    Sleep    ${TRAFFIC_DURATION_SEC}

Check Troughput And Packets Lost
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=45    unit=mbps    margin=0.3    direction=bi

