*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

*** Variables ***
${TRAFFIC_DURATION_SEC_T_B_ENDC}=   1m

*** Keywords ***
CB008717-T_B1_ENDC_preferred_path_selection_with_dlPreferredPath_F1U_initialDLTrafficRouting_initDLoverX2U_actPrioritizeX2AfterInactivity_0
    Set Data Split Params For B1
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start NSA Data Traffic 1Mbps In Dl For 100ms
    Packets Should Be Transmitted On Mcg Leg
    Start Data Traffic 5Mbps In Dl
    Data Should Be Transmitted Only on Scg Leg
    Start Data Traffic 60Mbps In Dl
    Data Should Be Splited On MCG And SCG
    Detach Ue    ue_id=11
    Set dlDataSplitBufferBuildUpThreshold To 0 For B1
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start NSA Data Traffic 1Mbps In Dl For 100ms
    Packets Should Be Transmitted On Mcg Leg
    Start Data Traffic 5Mbps In Dl
    Data Should Be Splited On MCG And SCG
    Detach Ue    ue_id=11

CB008717-T_B2_ENDC_preferred_path_selection_with_dlPreferredPath_X2U_initialDLTrafficRouting_initDLoverF1U_actPrioritizeX2AfterInactivity_0
    Set Data Split Params For B2
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start NSA Data Traffic 1Mbps In Dl For 100ms
    Packets Should Be Transmitted On Scg Leg
    Start Data Traffic 5Mbps In Dl
    Data Should Be Transmitted Only on Mcg Leg
    Start Data Traffic 60Mbps In Dl
    Data Should Be Splited On MCG And SCG
    Detach Ue    ue_id=11
    Set dlDataSplitBufferBuildUpThreshold To 0 For B2
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start NSA Data Traffic 1Mbps In Dl For 100ms
    Packets Should Be Transmitted On Scg Leg
    Start Data Traffic 5Mbps In Dl
    Data Should Be Splited On MCG And SCG
    Detach Ue    ue_id=11

CB008717-T_B3_ENDC_preferred_path_selection_with_dlPreferredPath_X2U_initialDLTrafficRouting_initDLoverF1U_actPrioritizeX2AfterInactivity_1
    Set Data Split Params For B3
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start NSA Data Traffic 1Mbps In Dl For 100ms
    Packets Should Be Transmitted On Scg Leg
    Start Data Traffic 5Mbps In Dl
    Data Should Be Transmitted Only on Mcg Leg
    Start Data Traffic 60Mbps In Dl
    Data Should Be Splited On MCG And SCG
    Detach Ue    ue_id=11

Set RD Flag For Mcs 3
    Change Rad Param With Aashell    param=${rdSupportedDl64QamMcs}    value=0x8

Packets Should Be Transmitted On Mcg Leg
    Sleep    1s
    Display Bearer Stats

Packets Should Be Transmitted On Scg Leg
    Sleep    1s
    Display Bearer Stats

Data Should Be Transmitted Only on Scg Leg
    Display Bearer Stats

Data Should Be Transmitted Only on Mcg Leg
    Display Bearer Stats

Data Should Be Splited On MCG And SCG
    Display Bearer Stats

Start NSA Data Traffic 1Mbps In Dl For 100ms
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=1 packets=10 period_ms=10 burst=1

Start Data Traffic 5Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=5
    Sleep    ${TRAFFIC_DURATION_SEC_T_B_ENDC}

Start Data Traffic 60Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=60
    Sleep    ${TRAFFIC_DURATION_SEC_T_B_ENDC}
    Display Bearer Stats

Set Data Split Params For B1
    Send Delta Commissioning   input_filepath=${DELTA_FILES_PATH}/CB008717/delta_CB008717-T_B1.json

Set Data Split Params For B2
    Send Delta Commissioning   input_filepath=${DELTA_FILES_PATH}/CB008717/delta_CB008717-T_B2.json

Set Data Split Params For B3
    Send Delta Commissioning   input_filepath=${DELTA_FILES_PATH}/CB008717/delta_CB008717-T_B3.json

Set dlDataSplitBufferBuildUpThreshold To 0 For B1
    Send Delta Commissioning   input_filepath=${DELTA_FILES_PATH}/CB008717/delta_CB008717-T_B1_dlDataSplitBufferBuildUpThreshold_0.json

Set dlDataSplitBufferBuildUpThreshold To 0 For B2
    Send Delta Commissioning   input_filepath=${DELTA_FILES_PATH}/CB008717/delta_CB008717-T_B2_dlDataSplitBufferBuildUpThreshold_0.json

Display Bearer Stats
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=dl dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=dl dc_cell_group=scg