*** Settings ***
Documentation
...              author: Damian Zak, Mateusz Plinta, Mateusz Pajor
...              maintainer: Bartlomiej Kolacz
...              contact: bartlomiej.kolacz@nokia.com
...              description: CB008294-SR-A-B6 Intra-band TDD FR2 CA with FR2 CA NSA enabled in the same gNB
...              topology: CLOUD_5G_I_BOO_AP_LOO

Resource         resources/common_keywords.robot

Suite Setup      Suite Environment Preparation    scf_filename=scf_A_B6.xml
Test Teardown    Test Environment Teardown
Suite Teardown   Run Keyword And Ignore Error    Collect Admin Api Logs    subdir=${SUITE_NAME}
...                                                                        dir_name=admin_api_logs


*** Test Cases ***
CB008294_A_B6_02_8CC_DL_4CC_UL_Interworking_with_FR2_NSA_CA_maxNumScellsDlFr2Sa
    [Tags]    CRT
    [Setup]    Test Environment Preparation For B6    delta=${DELTA_A_B6_TC2}
    ...    mib_reception_list=[1,2,3,4,5,8,9]
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection    net_arch=SA
    Perform 5G Attach    net_arch=NSA    cell_id=9
    Start Traffic    traffic_direction=dl    dl_mbps=800
    Start Traffic    traffic_direction=ul    ul_mbps=150
    Start Traffic    traffic_direction=dl    dl_mbps=400    net_arch=NSA
    Start Traffic    traffic_direction=ul    ul_mbps=100    net_arch=NSA
    Validate Scells State In Egate    cells_to_validate_map={0: (52, 53), 10: (60,)}
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,)
    ...    dl_mbps=800
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=dl    cells_idxs_with_traffic=(0,1,2)
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=ul    cells_idxs_with_traffic=(0,1,2)
    Validate Traffic By Egate Cell Indexes    ue_id=11    traffic_direction=dl    cells_idxs_with_traffic=(8,9)
    Validate Traffic By Egate Cell Indexes    ue_id=11    traffic_direction=ul    cells_idxs_with_traffic=(8,9)
    Wait For Next PM Period Before Detach
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Stop Traffic    traffic_direction=dl    net_arch=NSA
    Stop Traffic    traffic_direction=ul    net_arch=NSA
    Perform 5G Detach With TTI Collection    ue_ids=(1,)    net_arch=SA
    Perform 5G Detach    ue_ids=(11,)    net_arch=NSA
    Perform PM Counter Validation    number_of_ues_fr2_sa=${1}    cc_dl=${3}    cc_ul=${3}

CB008294_A_B6_05_8CC_DL_4CC_UL_Interworking_with_FR2_NSA_CA_maxNumScellsUl
    [Tags]    CRT
    [Setup]    Test Environment Preparation For B6    delta=${DELTA_A_B6_TC5}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection    net_arch=SA
    Perform 5G Attach    net_arch=NSA    cell_id=9
    Start Traffic    traffic_direction=dl    dl_mbps=800
    Start Traffic    traffic_direction=ul    ul_mbps=150
    Start Traffic    traffic_direction=dl    dl_mbps=400    net_arch=NSA
    Start Traffic    traffic_direction=ul    ul_mbps=100    net_arch=NSA
    Validate Scells State In Egate    cells_to_validate_map={0: (52, 53, 54, 55, 56, 57, 58), 10: (60,)}
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,)
    ...    dl_mbps=800
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=dl    cells_idxs_with_traffic=(0,1,2,3,4,5,6,7)
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=ul    cells_idxs_with_traffic=(0,1,2,3)
    Validate Traffic By Egate Cell Indexes    ue_id=11    traffic_direction=dl    cells_idxs_with_traffic=(8,9)
    Validate Traffic By Egate Cell Indexes    ue_id=11    traffic_direction=ul    cells_idxs_with_traffic=(8,9)
    Wait For Next PM Period Before Detach
    Stop Traffic    traffic_direction=dl
    Stop Traffic    traffic_direction=ul
    Stop Traffic    traffic_direction=dl    net_arch=NSA
    Stop Traffic    traffic_direction=ul    net_arch=NSA
    Perform 5G Detach With TTI Collection    ue_ids=(1,)    net_arch=SA
    Perform 5G Detach    ue_ids=(11,)    net_arch=NSA
    Perform PM Counter Validation    number_of_ues_fr2_sa=${1}    cc_dl=${8}    cc_ul=${4}

CB008294_A_B6_08_8CC_DL_4CC_UL_Interworking_with_FR2_NSA_CA_loadbalancing_SA_UEcap_restriction
    [Tags]    CRT
    [Setup]    Test Environment Preparation For B6    delta=${DELTA_A_B6_TC8}    ues_fr2_sa=(1,2,3)
    ...    pcell=2    nr_ue_caps=${UE_CAPS_6DL_3UL}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach With TTI Collection    net_arch=SA    number_of_ues=3
    Perform 5G Attach    net_arch=NSA    cell_id=9
    Start Traffic    number_of_ues=3    traffic_direction=dl    dl_mbps=400
    Start Traffic    number_of_ues=3    traffic_direction=ul    ul_mbps=150
    Start Traffic    traffic_direction=dl    dl_mbps=200    net_arch=NSA
    Start Traffic    traffic_direction=ul    ul_mbps=100    net_arch=NSA
    Validate Scells State In Egate
    ...    cells_to_validate_map={0: (51, 53, 54, 55, 56), 1: (53, 54, 55, 56, 57), 2: (51, 53, 54, 55, 56), 10: (60,)}
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2,3)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3)
    ...    dl_mbps=400
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=dl    cells_idxs_with_traffic=(0,1,2,3,4,5)    sleep_sec=5
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=ul    cells_idxs_with_traffic=(0,1,2)    sleep_sec=5
    Validate Traffic By Egate Cell Indexes    ue_id=2    traffic_direction=dl    cells_idxs_with_traffic=(0,1,2,3,4,5)    sleep_sec=5
    Validate Traffic By Egate Cell Indexes    ue_id=2    traffic_direction=ul    cells_idxs_with_traffic=(0,1,2)    sleep_sec=5
    Validate Traffic By Egate Cell Indexes    ue_id=3    traffic_direction=dl    cells_idxs_with_traffic=(0,1,2,3,4,5)    sleep_sec=5
    Validate Traffic By Egate Cell Indexes    ue_id=3    traffic_direction=ul    cells_idxs_with_traffic=(0,1,2)    sleep_sec=5
    Validate Traffic By Egate Cell Indexes    ue_id=11    traffic_direction=dl    cells_idxs_with_traffic=(8,9)    sleep_sec=5
    Validate Traffic By Egate Cell Indexes    ue_id=11    traffic_direction=ul    cells_idxs_with_traffic=(8,9)    sleep_sec=5
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Stop Traffic    traffic_direction=dl    net_arch=NSA
    Stop Traffic    traffic_direction=ul    net_arch=NSA
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3)    net_arch=SA
    Perform 5G Detach    ue_ids=(11,)    net_arch=NSA
    Perform PM Counter Validation    number_of_ues_fr2_sa=${3}    cc_dl=${6}    cc_ul=${3}

CB008294_A_B6_09_8CC_DL_4CC_UL_Interworking_with_FR2_NSA_CA_maxNumOf5To8CCUsersFr2Sa
    [Tags]    CRT
    [Setup]    Test Environment Preparation For B6    delta=${DELTA_A_B6_TC9}    ues_fr2_sa=(1,2,3)
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach For Specific UE With TTI Collection    ue_ids=(1,2,3)
    Perform 5G Attach    net_arch=NSA    cell_id=9
    Start Traffic    number_of_ues=3    traffic_direction=dl    dl_mbps=350
    Start Traffic    number_of_ues=3    traffic_direction=ul    ul_mbps=150
    Start Traffic    traffic_direction=dl    dl_mbps=200    net_arch=NSA
    Start Traffic    traffic_direction=ul    ul_mbps=100    net_arch=NSA
    Validate Scells State In Egate
    ...     cells_to_validate_map={0: (52, 53, 54, 55, 56, 57, 58), 1: (52, 53, 54, 55, 56, 57, 58), 2: (52, 53, 54), 10: (60,)}
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2,3)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3)
    ...    dl_mbps=350
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=dl    cells_idxs_with_traffic=(0,1,2,3,4,5,6,7)      sleep_sec=10
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=ul    cells_idxs_with_traffic=(0,1,2,3)      sleep_sec=10
    Validate Traffic By Egate Cell Indexes    ue_id=2    traffic_direction=dl    cells_idxs_with_traffic=(0,1,2,3,4,5,6,7)      sleep_sec=10
    Validate Traffic By Egate Cell Indexes    ue_id=2    traffic_direction=ul    cells_idxs_with_traffic=(0,1,2,3)      sleep_sec=10
    Validate Traffic By Egate Cell Indexes    ue_id=3    traffic_direction=dl    cells_idxs_with_traffic=(0,1,2,3)      sleep_sec=10
    Validate Traffic By Egate Cell Indexes    ue_id=3    traffic_direction=ul    cells_idxs_with_traffic=(0,1,2,3)      sleep_sec=10
    Validate Traffic By Egate Cell Indexes    ue_id=11    traffic_direction=dl    cells_idxs_with_traffic=(8,9)     sleep_sec=10
    Validate Traffic By Egate Cell Indexes    ue_id=11    traffic_direction=ul    cells_idxs_with_traffic=(8,9)     sleep_sec=10
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Stop Traffic    traffic_direction=dl    net_arch=NSA
    Stop Traffic    traffic_direction=ul    net_arch=NSA
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3)    net_arch=SA
    Perform 5G Detach    ue_ids=(11,)    net_arch=NSA
    Perform PM Counter Validation For B6 TC9
