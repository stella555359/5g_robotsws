*** Settings ***
Library     CNI_97376_keywords.py

Documentation
...    author:      Michał Brychcy
...    maintainer:  Marcin Kotuła (marcin.kotula@nokia.com)
...    testline:    CLOUD_5G_I_LO_AP_LO
...    release:     24R2

*** Variables ***
${TRAFFIC_DURATION}=   60s
${UE_DC_ID}=    11
${SCG_BEARER_ID}=    2
${NUMBER_OF_PACKETS_WITH_DLDYNAMIC_ACTIVAION}=    200000

*** Keywords ***
CNI-97376-US1_Use_LTE_Leg_During_ENDC_Setup
    Attach Ue With Sgnb
    Start 60 Mbps Dl Data Traffic
    Display UE11 Bearer Statistics
    Perform Sgnb Release
    Enable Dldynamic
    Enable Msg Delay
    Clear UE11 Bearer Statistics
    Start Gnb Addition
    Display UE11 Bearer Statistics
    Check If Number Of Packets Sent Is Bigger Than Given Value    ${NUMBER_OF_PACKETS_WITH_DLDYNAMIC_ACTIVAION}
    Detach Ue    ue_id=${UE_DC_ID}

Prepare Msg Delay
    Execute Egate Command    cmd=cont_res_testmode_nr profile_id=1 missed_ra_resp=5

Start 60 Mbps Dl Data Traffic
    Execute Egate Command    cmd=debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=${UE_DC_ID} id=${SCG_BEARER_ID} dir=dl mbps=60 trf_id=1
    Sleep    ${TRAFFIC_DURATION}

Display UE11 Bearer Statistics
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=${UE_DC_ID} id=${SCG_BEARER_ID} dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=${UE_DC_ID} id=${SCG_BEARER_ID} dc_cell_group=scg

Perform Sgnb Release
    Execute Egate Command And Wait For Data    cmd=enb_ue_dc_release ue=${UE_DC_ID} bearer=${SCG_BEARER_ID} by=enb cause=off

Enable Dldynamic
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_enable_Dldynamic.json

Enable Msg Delay
    Execute Egate Command    cmd=ue_testmode_set_nr profile_id=1 id=${UE_DC_ID} testmode=contention_resolution action=activate

Clear UE11 Bearer Statistics
    Execute Egate Command    cmd=bearer_stats_clear ue=${UE_DC_ID} id=${SCG_BEARER_ID}

Start Gnb Addition
    Start Gnb Addition Procedure    ue=${UE_DC_ID}    bearer=${SCG_BEARER_ID}    target_cells=1    dc_type=split_scg
    Sleep    ${TRAFFIC_DURATION}
