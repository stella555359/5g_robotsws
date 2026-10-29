*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_pm_counters
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library    OperatingSystem
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
${COUNTER_ID_ACC_CELL_DL_DRB_DATA}=    M55308C26001
${COUNTER_ID_ACC_CELL_UL_DRB_DATA}=    M55308C26002
${COUNTER_ID_ACC_UE_DL_SLEEP_DATA}=    M55308C27001
${COUNTER_ID_SLOTS_UE_DRX_ACTIVE}=    M55308C11001
${COUNTER_ID_SLOTS_UE_DRX_SLEEP}=    M55308C11002

*** Test Cases ***
5GC002637-A-B3-1_MAC_counters_for_accumulated_number_of_slots_and_ues_with_data_in_buffer
    Enable Drx Counters
    Set Internal Traffic Type To UEs
    Register Ue With Default Pdu Session
    Start Data Traffic And Drx State
    Display Qfi stats    qfi_id=1
    Check Drx Counters
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=19    unit=kbps    margin=0.3    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=bi
    Deregister Ue    ue_id=1

*** Keywords ***
Enable Drx Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_drx_state.json

Start Data Traffic And Drx State
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl period_ms=4000 packets=40000 burst=40
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul period_ms=4000 packets=40000 burst=40
    Execute Egate Command    cmd=l3_set_drx id=1 long_cycle_len=sf2560 inactive_timer=psf2560
    Sleep    ${TRAFFIC_DURATION_SEC}

Check Drx Counters
    Wait For Next Full Pm Interval
	${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    ${VALUE_OF_DL_DRB_DATA}=    get_pm_counter_value    counter_id=${COUNTER_ID_ACC_CELL_DL_DRB_DATA}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    ${VALUE_OF_UL_DRB_DATA}=    get_pm_counter_value    counter_id=${COUNTER_ID_ACC_CELL_UL_DRB_DATA}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    ${VALUE_OF_DL_SLEEP_DATA}=    get_pm_counter_value    counter_id=${COUNTER_ID_ACC_UE_DL_SLEEP_DATA}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    ${VALUE_OF_UE_DRX_ACTIVE}=    get_pm_counter_value    counter_id=${COUNTER_ID_SLOTS_UE_DRX_ACTIVE}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    ${VALUE_OF_UE_DRX_SLEEP}=    get_pm_counter_value    counter_id=${COUNTER_ID_SLOTS_UE_DRX_SLEEP}
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
    Check If Pm Counter Have Value Lower Than Other    first_counter_id=${VALUE_OF_DL_SLEEP_DATA}
	...    second_counter_id=${VALUE_OF_UE_DRX_SLEEP}
	Check If Pm Counter Have Value Lower Than Other    first_counter_id=${VALUE_OF_DL_DRB_DATA}+${VALUE_OF_UL_DRB_DATA}
	...    second_counter_id=${VALUE_OF_DL_SLEEP_DATA}


