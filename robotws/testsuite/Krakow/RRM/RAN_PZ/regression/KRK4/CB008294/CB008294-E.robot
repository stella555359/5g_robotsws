*** Settings ***
Documentation
...              author: Damian Zak, Mateusz Plinta, Mateusz Pajor
...              maintainer: Bartlomiej Kolacz
...              contact: bartlomiej.kolacz@nokia.com
...              description: CB008294-E#B101 Counters for SA FR2 CA with different CC configurations
...              topology: CLOUD_5G_I_BOO_AP_LOO

Resource         resources/common_keywords.robot

Suite Setup      Run Keywords    Suite Environment Preparation
...                       AND    Setup DCAP

Test Teardown    Run Keywords    Get Results From DCAP If Test Failed
...                       AND    Test Environment Teardown

Suite Teardown   Run Keyword And Ignore Error    Collect Admin Api Logs    subdir=${SUITE_NAME}
...                                                                        dir_name=admin_api_logs

*** Test Cases ***
CB008294_E_B101_01_New_And_Legacy_CA_Counters_SA_FR2_8CC_DL_4CC_UL
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    delta=${DELTA_E_B101_TC1}    cc_dl=${8}    cc_ul=${4}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    ue_ids=(1,2,3)
    Wait For Next PM Period With Advance Before Attach    advance=${90}
    ${trace_id} =    Start Emil Collection
    Perform 5G Attach With TTI Collection    number_of_ues=3
    Stop Emil collection    trace_id=${trace_id}
    Start Traffic    number_of_ues=3    traffic_direction=dl    dl_mbps=200
    Start Traffic    number_of_ues=3    traffic_direction=ul    ul_mbps=50
    Scells State Validation
    Wait For Traffic Stabilization
    Collect Traffic TTI Traces
    Check Traffic Stability    ue_ids=(1,2,3)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3)
    ...    dl_mbps=200
    ...    ul_mbps=50
    Validate Traffic    ue_id=1    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=1    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=ul    sleep_sec=${5}
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3)
    Perform PM Counter Validation
    ${file_path} =    Extract 5gm File From DCAP Logs    trace_id=${trace_id}
    PMI Ticket Verification From Emil Decoded Data    ${file_path}

CB008294_E_B101_02_New_And_Legacy_CA_Counters_SA_FR2_7CC_DL_4CC_UL
    [Setup]    Common Test Environment Preparation    delta=${DELTA_E_B101_TC2}    cc_dl=${7}    cc_ul=${4}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    ue_ids=(1,2,3)
    Wait For Next PM Period With Advance Before Attach    advance=${90}
    ${trace_id} =    Start Emil Collection
    Perform 5G Attach With TTI Collection    number_of_ues=3
    Stop Emil collection    trace_id=${trace_id}
    Start Traffic    number_of_ues=3    traffic_direction=dl    dl_mbps=200
    Start Traffic    number_of_ues=3    traffic_direction=ul    ul_mbps=50
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2,3)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3)
    ...    dl_mbps=200
    ...    ul_mbps=50
    Validate Traffic    ue_id=1    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=1    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=ul    sleep_sec=${5}
    Collect Traffic TTI Traces
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3)
    Perform PM Counter Validation
    ${file_path} =    Extract 5gm File From DCAP Logs    trace_id=${trace_id}
    PMI Ticket Verification From Emil Decoded Data    ${file_path}

CB008294_E_B101_03_New_And_Legacy_CA_Counters_SA_FR2_6CC_DL_4CC_UL
    [Setup]    Common Test Environment Preparation    delta=${DELTA_E_B101_TC3}    cc_dl=${6}    cc_ul=${4}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    ue_ids=(1,2,3)
    Wait For Next PM Period With Advance Before Attach    advance=${90}
    ${trace_id} =    Start Emil Collection
    Perform 5G Attach With TTI Collection    number_of_ues=3
    Stop Emil collection    trace_id=${trace_id}
    Start Traffic    number_of_ues=3    traffic_direction=dl    dl_mbps=200
    Start Traffic    number_of_ues=3    traffic_direction=ul    ul_mbps=50
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2,3)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3)
    ...    dl_mbps=200
    ...    ul_mbps=50
    Validate Traffic    ue_id=1    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=1    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=ul    sleep_sec=${5}
    Collect Traffic TTI Traces
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3)
    Perform PM Counter Validation
    ${file_path} =    Extract 5gm File From DCAP Logs    trace_id=${trace_id}
    PMI Ticket Verification From Emil Decoded Data    ${file_path}

CB008294_E_B101_04_New_And_Legacy_CA_Counters_SA_FR2_5CC_DL_4CC_UL
    [Setup]    Common Test Environment Preparation    delta=${DELTA_E_B101_TC4}    cc_dl=${5}    cc_ul=${4}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    ue_ids=(1,2,3)
    Wait For Next PM Period With Advance Before Attach    advance=${90}
    ${trace_id} =    Start Emil Collection
    Perform 5G Attach With TTI Collection    number_of_ues=3
    Stop Emil collection    trace_id=${trace_id}
    Start Traffic    number_of_ues=3    traffic_direction=dl    dl_mbps=200
    Start Traffic    number_of_ues=3    traffic_direction=ul    ul_mbps=50
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2,3)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3)
    ...    dl_mbps=200
    ...    ul_mbps=50
    Validate Traffic    ue_id=1    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=1    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=ul    sleep_sec=${5}
    Collect Traffic TTI Traces
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3)
    Perform PM Counter Validation
    ${file_path} =    Extract 5gm File From DCAP Logs    trace_id=${trace_id}
    PMI Ticket Verification From Emil Decoded Data    ${file_path}

CB008294_E_B101_05_New_And_Legacy_CA_Counters_SA_FR2_4CC_DL_4CC_UL
    [Setup]    Common Test Environment Preparation    delta=${DELTA_E_B101_TC5}    cc_dl=${4}    cc_ul=${4}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    ue_ids=(1,2,3)
    Wait For Next PM Period With Advance Before Attach    advance=${90}
    ${trace_id} =    Start Emil Collection
    Perform 5G Attach With TTI Collection    number_of_ues=3
    Stop Emil collection    trace_id=${trace_id}
    Start Traffic    number_of_ues=3    traffic_direction=dl    dl_mbps=200
    Start Traffic    number_of_ues=3    traffic_direction=ul    ul_mbps=50
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2,3)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3)
    ...    dl_mbps=200
    ...    ul_mbps=50
    Validate Traffic    ue_id=1    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=1    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=ul    sleep_sec=${5}
    Collect Traffic TTI Traces
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3)
    Perform PM Counter Validation
    ${file_path} =    Extract 5gm File From DCAP Logs    trace_id=${trace_id}
    PMI Ticket Verification From Emil Decoded Data    ${file_path}

CB008294_E_B101_06_New_And_Legacy_CA_Counters_SA_FR2_3CC_DL_3CC_UL
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    delta=${DELTA_E_B101_TC6}    cc_dl=${3}    cc_ul=${3}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    ue_ids=(1,2,3)
    Wait For Next PM Period With Advance Before Attach    advance=${90}
    ${trace_id} =    Start Emil Collection
    Perform 5G Attach With TTI Collection    number_of_ues=3
    Stop Emil collection    trace_id=${trace_id}
    Start Traffic    number_of_ues=3    traffic_direction=dl    dl_mbps=200
    Start Traffic    number_of_ues=3    traffic_direction=ul    ul_mbps=50
    Scells State Validation
    Wait For Traffic Stabilization
    Collect Traffic TTI Traces
    Check Traffic Stability    ue_ids=(1,2,3)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3)
    ...    dl_mbps=200
    ...    ul_mbps=50
    Validate Traffic    ue_id=1    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=1    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=ul    sleep_sec=${5}
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3)
    Perform PM Counter Validation
    ${file_path} =    Extract 5gm File From DCAP Logs    trace_id=${trace_id}
    PMI Ticket Verification From Emil Decoded Data    ${file_path}

CB008294_E_B101_07_New_And_Legacy_CA_Counters_SA_FR2_3CC_DL_2CC_UL
    [Setup]    Common Test Environment Preparation    delta=${DELTA_E_B101_TC7}    cc_dl=${3}    cc_ul=${2}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    ue_ids=(1,2,3)
    Wait For Next PM Period With Advance Before Attach    advance=${90}
    ${trace_id} =    Start Emil Collection
    Perform 5G Attach With TTI Collection    number_of_ues=3
    Stop Emil collection    trace_id=${trace_id}
    Start Traffic    number_of_ues=3    traffic_direction=dl    dl_mbps=200
    Start Traffic    number_of_ues=3    traffic_direction=ul    ul_mbps=50
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2,3)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3)
    ...    dl_mbps=200
    ...    ul_mbps=50
    Validate Traffic    ue_id=1    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=1    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=ul    sleep_sec=${5}
    Collect Traffic TTI Traces
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3)
    Perform PM Counter Validation
    ${file_path} =    Extract 5gm File From DCAP Logs    trace_id=${trace_id}
    PMI Ticket Verification From Emil Decoded Data    ${file_path}

CB008294_E_B101_08_New_And_Legacy_CA_Counters_SA_FR2_2CC_DL_2CC_UL
    [Setup]    Common Test Environment Preparation    delta=${DELTA_E_B101_TC8}    cc_dl=${2}    cc_ul=${2}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    ue_ids=(1,2,3)
    Wait For Next PM Period With Advance Before Attach    advance=${90}
    ${trace_id} =    Start Emil Collection
    Perform 5G Attach With TTI Collection    number_of_ues=3
    Stop Emil collection    trace_id=${trace_id}
    Start Traffic    number_of_ues=3    traffic_direction=dl    dl_mbps=200
    Start Traffic    number_of_ues=3    traffic_direction=ul    ul_mbps=50
    Scells State Validation
    Wait For Traffic Stabilization
    Collect Traffic TTI Traces
    Check Traffic Stability    ue_ids=(1,2,3)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3)
    ...    dl_mbps=200
    ...    ul_mbps=50
    Validate Traffic    ue_id=1    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=1    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=2    traffic_direction=ul    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=dl    sleep_sec=${5}
    Validate Traffic    ue_id=3    traffic_direction=ul    sleep_sec=${5}
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3)
    Perform PM Counter Validation
    ${file_path} =    Extract 5gm File From DCAP Logs    trace_id=${trace_id}
    PMI Ticket Verification From Emil Decoded Data    ${file_path}

CB008294_Robustness_1_Scell_deact_buffer_and_channel_state
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    delta=${DELTA_ROBUSTNESS}    nr_ue_caps=${UE_CAPS_6DL_4UL}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    cc_dl=${6}    cc_ul=${4}
    Wait For Next PM Period    interval=${5}
    Perform 5G Attach With TTI Collection
    Start Traffic    traffic_direction=dl    dl_mbps=800
    Start Traffic    traffic_direction=ul    ul_mbps=200
    Scells State Validation
    Wait For Traffic Stabilization
    Collect Traffic TTI Traces
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Wait For SCells To Deactivate    wait_time=${60}
    ${deact_scell_prints} =    Get Scells State Prints Count Per Cell
    Wait For Next PM Period    interval=${5}
    Create Bler Profile
    Change Cqi Value    profile_id=${3}    cqi=${6}
    Start Traffic    traffic_direction=dl    dl_mbps=800
    Start Traffic    traffic_direction=ul    ul_mbps=200
    Wait For Traffic Stabilization
    Validate Traffic    traffic_direction=dl
    Validate Traffic    traffic_direction=ul
    Collect Traffic TTI Traces And With Testmode Activation
    Wait For Next PM Period    interval=${5}
    Perform PM Counter Validation For Robustness    ${deact_scell_prints}
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Perform 5G Detach
    [Teardown]    Test Environment Teardown
