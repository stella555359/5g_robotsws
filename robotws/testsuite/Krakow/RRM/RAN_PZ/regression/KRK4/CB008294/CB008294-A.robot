*** Settings ***
Documentation
...              author: Damian Zak, Mateusz Plinta, Mateusz Pajor
...              maintainer: Bartlomiej Kolacz
...              contact: bartlomiej.kolacz@nokia.com
...              description: CB008294-SR-A-B302 Intra-band TDD FR2 8CC DL and 4CC UL CA UE Context delete
...                           CB008294-SR-A-B303 Intra-band TDD FR2 8CC DL and 4CC UL contiguous CA downlink data
...                                              transfer when primary cell is 1
...                           CB008294-SR-A-B304 Intra-band TDD FR2 8CC DL and 4CC UL contiguous CA downlink data
...                                              transfer when primary cell is 3rd cell
...                           CB008294-SR-A-B305 Intra-band TDD FR2 8CC DL and 4CC UL CA interwork with multiple UEs
...                                              and different UE capabilities
...                           CB008294-SR-A-B307 Intra-band TDD FR2 CA Tput without BF
...                           CB008294-SR-A-B311 Intra-band TDD FR2 CA for BufferBased Scell activation
...              topology: CLOUD_5G_I_BOO_AP_LOO

Resource         resources/common_keywords.robot

Suite Setup      Suite Environment Preparation
Test Teardown    Test Environment Teardown
Suite Teardown   Run Keyword And Ignore Error    Collect Admin Api Logs    subdir=${SUITE_NAME}
...                                                                        dir_name=admin_api_logs


*** Test Cases ***
CB008294_A_B302_01_UE_Context_Delete
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation
    Wait For Next PM Period With Advance Before Attach    advance=${60}
    Perform 5G Attach With TTI Collection
    Wait For Next PM Period    interval=${PM_PERIOD}   delay=${0}
    Scells State Validation
    Wait For Next PM Period Before Detach
    Perform 5G Detach With TTI Collection
    Perform PM Counter Validation

CB008294_A_B303_01_8CC_DL_Traffic_PCell_PCell1
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    pcell=1
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection
    Start Traffic    traffic_direction=dl    dl_mbps=800
    Start Traffic    traffic_direction=ul    ul_mbps=150
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,)
    ...    dl_mbps=800
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Wait For Traffic Stabilization
    Validate Traffic    traffic_direction=dl
    Validate Traffic    traffic_direction=ul
    Wait For Next PM Period Before Detach
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Perform 5G Detach With TTI Collection
    Perform PM Counter Validation

CB008294_A_B304_01_4CC_UL_Traffic_PCell_PCell3
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    pcell=${3}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection
    Start Traffic    traffic_direction=dl    dl_mbps=800
    Start Traffic    traffic_direction=ul    ul_mbps=150
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,)
    ...    dl_mbps=800
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic    traffic_direction=dl
    Validate Traffic    traffic_direction=ul
    Wait For Next PM Period Before Detach
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Perform 5G Detach With TTI Collection
    Perform PM Counter Validation

CB008294_A_B305_06_8CC_4CC_Caps_6DL_4UL
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    nr_ue_caps=${UE_CAPS_6DL_4UL}    pcell=6    ue_ids=(1,2,3)
    ...    cell_subcell_map={51: ['DL'], 52: ['DL'], 53: ['DL', 'UL'], 54: ['DL', 'UL'], 55: ['DL', 'UL'], 56: ['DL', 'UL'], 57: ['DL'], 58: ['DL']}
    ...    cc_dl=${6}    cc_ul=${4}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection    number_of_ues=3
    Start Traffic    number_of_ues=3    traffic_direction=dl    dl_mbps=400
    Start Traffic    number_of_ues=3    traffic_direction=ul    ul_mbps=100
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2,3)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3)
    ...    dl_mbps=400
    ...    ul_mbps=100
    Collect Traffic TTI Traces
    Validate Traffic    ue_id=1    traffic_direction=dl
    Validate Traffic    ue_id=1    traffic_direction=ul
    Validate Traffic    ue_id=2    traffic_direction=dl
    Validate Traffic    ue_id=2    traffic_direction=ul
    Validate Traffic    ue_id=3    traffic_direction=dl
    Validate Traffic    ue_id=3    traffic_direction=ul
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3)
    Perform PM Counter Validation

CB008294_A_B305_12_8CC_4CC_Caps_4DL_4UL
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    nr_ue_caps=${UE_CAPS_4DL_4UL}    pcell=1
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    cc_dl=${4}    cc_ul=${4}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection
    Start Traffic    traffic_direction=dl    dl_mbps=800
    Start Traffic    traffic_direction=ul    ul_mbps=150
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,)
    ...    dl_mbps=800
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic    ue_id=1    traffic_direction=dl
    Validate Traffic    ue_id=1    traffic_direction=ul
    Wait For Next PM Period Before Detach
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Perform 5G Detach With TTI Collection
    Perform PM Counter Validation

CB008294_A_B307_02_7CC_DL_3CC_UL_non_BF_PCell2
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    delta=${DELTA_A_B307_TC2}    nr_ue_caps=${UE_CAPS_8DL_4UL}    pcell=2
    ...    cell_subcell_map={51: ['DL', 'UL'], 52: ['DL', 'UL'], 53: ['DL', 'UL'], 54: ['DL'], 55: ['DL'], 56: ['DL'], 57: ['DL'], 58: ['DL']}
    ...    cc_dl=${7}    cc_ul=${3}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection
    Start Traffic    traffic_direction=dl    dl_mbps=800
    Start Traffic    traffic_direction=ul    ul_mbps=150
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,)
    ...    dl_mbps=800
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic    traffic_direction=dl
    Validate Traffic    traffic_direction=ul
    Wait For Next PM Period Before Detach
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Perform 5G Detach With TTI Collection
    Perform PM Counter Validation

CB008294_A_B307_04_5CC_DL_2CC_UL_non_BF_PCell4
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    delta=${DELTA_A_B307_TC4}    nr_ue_caps=${UE_CAPS_8DL_4UL}    pcell=4
    ...    cell_subcell_map={51: ['DL'], 52: ['DL'], 53: ['DL', 'UL'], 54: ['DL', 'UL'], 55: ['DL'], 56: ['DL'], 57: ['DL'], 58: ['DL']}
    ...    cc_dl=${5}    cc_ul=${2}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection
    Start Traffic    traffic_direction=dl    dl_mbps=800
    Start Traffic    traffic_direction=ul    ul_mbps=150
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,)
    ...    dl_mbps=800
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic    traffic_direction=dl
    Validate Traffic    traffic_direction=ul
    Wait For Next PM Period Before Detach
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Perform 5G Detach With TTI Collection
    Perform PM Counter Validation

CB008294_A_B311_03_3CC_DL_3CC_UL_BufferBasedAct
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    ue_ids=(1,2)    delta=${DELTA_A_B311_TC3}    nr_ue_caps=${UE_CAPS_3DL_3UL}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    cc_dl=${3}    cc_ul=${3}
    # 1st pm_period start
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection    number_of_ues=2
    Start Traffic    number_of_ues=2    traffic_direction=dl    dl_mbps=400
    Start Traffic    number_of_ues=2    traffic_direction=ul    ul_mbps=100
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2)
    ...    dl_mbps=400
    ...    ul_mbps=100
    Collect Traffic TTI Traces
    # 2nd pm_period start
    Validate Traffic    ue_id=1    traffic_direction=dl
    Validate Traffic    ue_id=1    traffic_direction=ul
    Validate Traffic    ue_id=2    traffic_direction=dl
    Validate Traffic    ue_id=2    traffic_direction=ul
    Wait For Next PM Period Before Detach
    # 3rd pm_period start
    Stop Traffic    number_of_ues=2    traffic_direction=dl
    Stop Traffic    number_of_ues=2    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2)
    # last wait for pm_period to get the 3rd pm_period data in webem
    Wait For Next PM Period    interval=${PM_PERIOD}
    Perform PM Counter Validation

CB008294_A_B311_04_2CC_DL_2CC_UL_BufferBasedAct
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    ue_ids=(1,2)    delta=${DELTA_A_B311_TC4}    nr_ue_caps=${UE_CAPS_2DL_2UL}
    ...    cell_subcell_map={51: ['DL', 'UL'], 52: ['DL', 'UL'], 53: ['DL'], 54: ['DL'], 55: ['DL'], 56: ['DL'], 57: ['DL'], 58: ['DL']}
    ...    cc_dl=${2}    cc_ul=${2}
    # 1st pm_period start
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection    number_of_ues=2
    Start Traffic    number_of_ues=2    traffic_direction=dl    dl_mbps=400
    Start Traffic    number_of_ues=2    traffic_direction=ul    ul_mbps=100
    Scells State Validation
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2)
    ...    dl_mbps=400
    ...    ul_mbps=100
    Collect Traffic TTI Traces
    # 2nd pm_period start
    Validate Traffic    ue_id=1    traffic_direction=dl
    Validate Traffic    ue_id=1    traffic_direction=ul
    Validate Traffic    ue_id=2    traffic_direction=dl
    Validate Traffic    ue_id=2    traffic_direction=ul
    Wait For Next PM Period Before Detach
    # 3rd pm_period start
    Stop Traffic    number_of_ues=2    traffic_direction=dl
    Stop Traffic    number_of_ues=2    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2)
    # last wait for pm_period to get the 3rd pm_period data in webem
    Wait For Next PM Period    interval=${PM_PERIOD}
    Perform PM Counter Validation
