*** Settings ***
Documentation
...              author: Damian Zak, Mateusz Plinta, Mateusz Pajor
...              maintainer: Bartlomiej Kolacz
...              contact: bartlomiej.kolacz@nokia.com
...              description: CB008294-SR-A-B7 Intra-band TDD FR2 CA with FR1 CA enabled in the same gNB
...              topology: CLOUD_5G_I_BOO_AP_LOO

Resource         resources/common_keywords.robot

Suite Setup      Suite Environment Preparation    scf_filename=scf_A_B7.xml
Test Teardown    Test Environment Teardown
Suite Teardown   Run Keyword And Ignore Error    Collect Admin Api Logs    subdir=${SUITE_NAME}
...                                                                        dir_name=admin_api_logs


*** Test Cases ***
CB008294_A_B7_03_8CC_DL_4CC_UL_Interworking_with_FR1_SA_CA_maxNumScellsUlFr2Sa
    [Tags]    CRT
    [Setup]    Test Environment Preparation For B7    delta=${DELTA_A_B7_TC3}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach For Specific UE With TTI Collection
    Perform 5G Attach For Specific UE    ue_ids=(2,)    cell_id=9
    Start Traffic    number_of_ues=2    traffic_direction=dl    dl_mbps=800
    Start Traffic    number_of_ues=2    traffic_direction=ul    ul_mbps=150
    Validate Scells State In Egate    cells_to_validate_map={0: (52, 53, 54, 55, 56, 57, 58), 1: (60,)}
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2)
    ...    dl_mbps=800
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=dl    cells_idxs_with_traffic=(0,1,2,3,4,5,6,7)
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=ul    cells_idxs_with_traffic=(0,1,2)
    Validate Traffic By Egate Cell Indexes    ue_id=2    traffic_direction=dl    cells_idxs_with_traffic=(0,1)
    Validate Traffic By Egate Cell Indexes    ue_id=2    traffic_direction=ul    cells_idxs_with_traffic=(0,)
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=2    traffic_direction=dl
    Stop Traffic    number_of_ues=2    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2)
    Perform PM Counter Validation    number_of_ues_fr2_sa=${1}    cc_dl=${8}    cc_ul=${3}

CB008294_A_B7_04_8CC_DL_4CC_UL_Interworking_with_FR1_SA_CA_maxNumScellsDl
    [Tags]    CRT
    [Setup]    Test Environment Preparation For B7
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach For Specific UE With TTI Collection
    Perform 5G Attach For Specific UE   ue_ids=(2,)    cell_id=9
    Start Traffic    number_of_ues=2    traffic_direction=dl    dl_mbps=800
    Start Traffic    number_of_ues=2    traffic_direction=ul    ul_mbps=150
    Validate Scells State In Egate    cells_to_validate_map={0: (52, 53, 54, 55, 56, 57, 58), 1: (60,)}
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2)
    ...    dl_mbps=800
    ...    ul_mbps=150
    Collect Traffic TTI Traces
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=dl    cells_idxs_with_traffic=(0,1,2,3,4,5,6,7)
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=ul    cells_idxs_with_traffic=(0,1,2,3)
    Validate Traffic By Egate Cell Indexes    ue_id=2    traffic_direction=dl    cells_idxs_with_traffic=(0,1)
    Validate Traffic By Egate Cell Indexes    ue_id=2    traffic_direction=ul    cells_idxs_with_traffic=(0,)
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=2    traffic_direction=dl
    Stop Traffic    number_of_ues=2    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2)
    Perform PM Counter Validation    number_of_ues_fr2_sa=${1}    cc_dl=${8}    cc_ul=${4}

CB008294_A_B7_06_8CC_DL_4CC_UL_Interworking_with_FR1_SA_CA_maxNumOf2CCUsersFr2Sa
    [Tags]    CRT
    [Setup]    Test Environment Preparation For B7    delta=${DELTA_A_B7_TC6}    ues_fr2_sa=(1,2,3)    ues_fr1_sa=(4,)
    ...    nr_ue_caps=${UE_CAPS_2DL_2UL}
    Wait For Next PM Period With Advance Before Attach
    Perform 5G Attach For Specific UE With TTI Collection    ue_ids=(1,2,3)
    Wait For FR2 CA Activation
    Perform 5G Attach For Specific UE    ue_ids=(4,)    cell_id=9
    Start Traffic    number_of_ues=4    traffic_direction=dl    dl_mbps=300
    Start Traffic    number_of_ues=4    traffic_direction=ul    ul_mbps=50
    Validate Scells State In Egate
    ...    cells_to_validate_map={0: (52,), 1: (52,), 3: (60,)}
    Wait For Traffic Stabilization
    Check Traffic Stability    ue_ids=(1,2,3,4)
    Check If Expected Throughput Is Reached
    ...    ue_ids=(1,2,3,4)
    ...    dl_mbps=300
    ...    ul_mbps=50
    Collect Traffic TTI Traces
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=dl    cells_idxs_with_traffic=(0,1)
    Validate Traffic By Egate Cell Indexes    ue_id=1    traffic_direction=ul    cells_idxs_with_traffic=(0,1)
    Validate Traffic By Egate Cell Indexes    ue_id=2    traffic_direction=dl    cells_idxs_with_traffic=(0,1)
    Validate Traffic By Egate Cell Indexes    ue_id=2    traffic_direction=ul    cells_idxs_with_traffic=(0,1)
    Validate Traffic By Egate Cell Indexes    ue_id=3    traffic_direction=dl    cells_idxs_with_traffic=(0,)
    Validate Traffic By Egate Cell Indexes    ue_id=3    traffic_direction=ul    cells_idxs_with_traffic=(0,)
    Validate Traffic By Egate Cell Indexes    ue_id=4    traffic_direction=dl    cells_idxs_with_traffic=(0,1)
    Validate Traffic By Egate Cell Indexes    ue_id=4    traffic_direction=ul    cells_idxs_with_traffic=(0,)
    Wait For Next PM Period Before Detach
    Stop Traffic    number_of_ues=3    traffic_direction=dl
    Stop Traffic    number_of_ues=3    traffic_direction=ul
    Perform 5G Detach With TTI Collection    ue_ids=(1,2,3,4)
    Perform PM Counter Validation For B7 TC6
