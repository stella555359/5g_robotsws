*** Settings ***
Documentation
...              author: Damian Zak, Mateusz Plinta, Mateusz Pajor, Dominik Dudek
...              maintainer: Bartlomiej Kolacz
...              contact: bartlomiej.kolacz@nokia.com
...              description: CB008294-D#B101 RRC re-establishment of FR2 SA CA UE with rrcReestabTypeSA set as deactivated or viaRRCSetup
...              topology: CLOUD_5G_I_BOO_AP_LOO

Resource         resources/common_keywords.robot

Suite Setup      Suite Environment Preparation
Test Teardown    Test Environment Teardown
Suite Teardown   Run Keyword And Ignore Error    Collect Admin Api Logs    subdir=${SUITE_NAME}
...                                                                        dir_name=admin_api_logs

*** Test Cases ***
CB008294_D_B101_01_8CC_DL_4CC_UL_RRCreastablishment_viaRRCSetup
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    delta=${DELTA_D_B101_TC1}
    Perform 5G Attach With TTI Collection
    Scells State Validation
    Perform ReEstablishment
    ReEstablishment Flow Validation    validation_type=viaRRCSetup
    Start Traffic    traffic_direction=dl    dl_mbps=800
    Start Traffic    traffic_direction=ul    ul_mbps=150
    Scells State Validation    messages_occurrences=2
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,)
    ...    dl_mbps=800
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic    traffic_direction=dl
    Validate Traffic    traffic_direction=ul
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Perform 5G Detach With TTI Collection

CB008294_D_B101_02_8CC_DL_4CC_UL_RRCreastablishment_deactivated
    [Tags]    CRT
    [Setup]    Common Test Environment Preparation    delta=${DELTA_D_B101_TC2}
    Perform 5G Attach With TTI Collection
    Scells State Validation
    Perform ReEstablishment
    ReEstablishment Flow Validation    validation_type=deactivated
    Perform 5G Detach With TTI Collection
