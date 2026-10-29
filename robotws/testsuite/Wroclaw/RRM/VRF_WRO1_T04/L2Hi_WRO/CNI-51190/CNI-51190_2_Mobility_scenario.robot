*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Documentation
...    author: Anna Chabik
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 22R1

Suite Setup    Enable HO
Test Setup      Run Keywords    Prepare Nsa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Wait For X2 Setup

Test Teardown    Send Configuration ID To Scout
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs
*** Variables ***
${TRAFFIC_DURATION_MIN}=   1m
${UE_DC_ID}=    11
${SCG_BEARER_ID}=    2
${EXPECTED_THROUGHPUT_DL_Mbps}=    100
${srsrp_part}=    srsrp_nr=11 srsrq_nr=11 ssinr_nr=11
${nrsrp_part}=    nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30
${UE_NR_CAPA}=    21000000010800000004DE4D0780720800000520800001520800002524A000034C00454000000000000054
${UE_EUTRA_NR_CAPA}=    A10180902C100389A0000008800B0400F89A000008000800080402004008

*** Test Cases ***
CNI-51190_2_Adaptative_solution_for_breaking_the_packet_processing_loops_in_L2-HI_Mobility_scenario
    Attach NSA Ue And Start Gnb Addition
    Start Data Traffic    ues=${UE_DC_ID}    bearer_id=${SCG_BEARER_ID}    direction=dl    throughput=50mbps    optional_parameters=trf_id=1
    Start Data Traffic    ues=${UE_DC_ID}    bearer_id=${SCG_BEARER_ID}    direction=dl    throughput=50mbps    optional_parameters=trf_id=2
    Sleep    ${TRAFFIC_DURATION_MIN}
    Check Dl Cell Traffic NSA
    Trigger Handover to second cell
    Sleep    ${TRAFFIC_DURATION_MIN}
    Check Dl Cell Traffic NSA
    Detach Ue    ue_id=${UE_DC_ID}

*** Keywords ***
Attach NSA Ue And Start Gnb Addition
    Execute Egate Command    cmd=ue_param id=${UE_DC_ID} ue_nr_capabilities=${UE_NR_CAPA}
    Execute Egate Command    cmd=ue_param id=${UE_DC_ID} ue_eutra_nr_capabilities=${UE_EUTRA_NR_CAPA}
    Attach Ue To Enb    ue_id=${UE_DC_ID}
    Start Gnb Addition Procedure    ue=${UE_DC_ID}    bearer=${SCG_BEARER_ID}    target_cells=1    dc_type=split_scg
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${SGNB_RECONFIG_COMPLETE}

Wait For X2 Setup
    Sleep    60s

Check Dl Cell Traffic NSA
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=${UE_DC_ID} id=2 dir=dl dc_cell_group=scg

Trigger Handover to second cell
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_DC_ID} meas_id=1 event=A3 ${srsrp_part} phycell_id=51 ${nrsrp_part}

Enable HO
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_intra_gnb_ho_and_a3_meas.json
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Mobility/delta_enable_NSA_mobility.json
