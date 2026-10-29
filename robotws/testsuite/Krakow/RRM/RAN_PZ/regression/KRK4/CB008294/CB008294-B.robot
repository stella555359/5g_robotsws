*** Settings ***
Documentation
...              author: Damian Zak
...              maintainer: Bartlomiej Kolacz
...              contact: bartlomiej.kolacz@nokia.com
...              description: CB008294-SR-A-B101 Intra-band TDD FR2 CA interwork with UE Overheating Assistance handling
...              topology: CLOUD_5G_I_BOO_AP_LOO

Library          taf.rfrl.common_resources.reporting_portal.bts_metadata
Library          taf/rfrl/procedures/resources/python/setups_and_teardowns_keywords.py
Resource         resources/common_keywords.robot

Suite Setup      Suite Environment Preparation
Test Teardown    Test Environment Teardown
Suite Teardown   Run Keyword And Ignore Error    Collect Admin Api Logs    subdir=${SUITE_NAME}
...                                                                        dir_name=admin_api_logs

*** Test Cases ***
CB008294_B_B101_02_4CC_DL_2CC_UL_UE_overheating_handling_CQI0_buffer_based_act
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    delta=${DELTA_B_B101_TC2}    nr_ue_caps=${UE_CAPS_4DL_2UL}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    cc_dl=${4}    cc_ul=${2}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection
    Start Traffic    traffic_direction=dl    dl_mbps=200
    Start Traffic    traffic_direction=ul    ul_mbps=150
    Scells State Validation    custom_cc_dl=3
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,)
    ...    dl_mbps=200
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic    traffic_direction=dl      overheated_cells=(4,)
    Validate Traffic    traffic_direction=ul
    Change Cqi Value    cqi=0
    Activate Testmode Profile    scell=3
    Start Traffic    traffic_direction=dl    dl_mbps=200    first_trf_id=10
    Wait For Traffic Stabilization
    Validate Traffic    traffic_direction=dl    overheated_cells=(4,)
    Verify Overheating In Tcpdump
    Wait For Next PM Period Before Detach
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Perform 5G Detach With TTI Collection
    Perform PM Counter Validation For B_B101 TC2

CB008294_B_B101_03_4CC_DL_4CC_UL_UE_overheating_handling_CQI0_quality_based_act
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    delta=${DELTA_B_B101_TC3}    nr_ue_caps=${UE_CAPS_4DL_4UL}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    cc_dl=${4}    cc_ul=${4}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection
    Change Cqi Value    cqi=0
    Activate Testmode Profile    scell=3
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
    Validate Traffic    traffic_direction=dl    overheated_cells=(4,)
    Validate Traffic    traffic_direction=ul    overheated_cells=(4,)
    Verify Overheating In Tcpdump
    Change Cqi Value    cqi=15
    Activate Testmode Profile    scell=3
    Wait For Traffic Stabilization
    Validate Traffic    traffic_direction=dl
    Validate Traffic    traffic_direction=ul
    Wait For Next PM Period Before Detach
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Perform 5G Detach With TTI Collection
    Perform PM Counter Validation

CB008294_B_B101_04_3CC_DL_3CC_UL_UE_overheating_handling_CQI0_buffer_based_deact
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation   delta=${DELTA_B_B101_TC4}    nr_ue_caps=${UE_CAPS_3DL_3UL}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    cc_dl=${3}    cc_ul=${3}
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
    Change Cqi Value    cqi=0
    Activate Testmode Profile    scell=1
    Verify Overheating In Tcpdump
    Wait For Next PM Period Before Detach
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Wait For SCells To Deactivate
    Scells State Validation    state=deactivation
    Perform 5G Detach With TTI Collection
    Perform PM Counter Validation

CB008294_B_B101_05_3CC_DL_2CC_UL_UE_overheating_handling_CQI0_quality_based_deact
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    delta=${DELTA_B_B101_TC5}    nr_ue_caps=${UE_CAPS_3DL_2UL}
    ...    cell_subcell_map=${DEFAULT_CELL_SUBCELL_MAP}    cc_dl=${3}    cc_ul=${2}
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
    Change Cqi Value    cqi=0
    Activate Testmode Profile    scell=1
    Verify Overheating In Tcpdump
    Wait For Next PM Period Before Detach
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Wait For SCells To Deactivate
    Scells State Validation    state=deactivation
    Perform 5G Detach With TTI Collection
    Perform PM Counter Validation
