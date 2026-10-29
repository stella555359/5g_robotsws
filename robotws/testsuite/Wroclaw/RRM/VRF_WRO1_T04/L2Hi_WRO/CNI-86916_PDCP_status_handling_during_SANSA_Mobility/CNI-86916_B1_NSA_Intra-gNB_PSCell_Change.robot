*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    keywords_CNI-86916.robot
Resource    ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library    keywords_CNI-86916.py
Documentation
...    author: Bartlomiej Urbanowicz
...    maintainer: Bartlomiej Urbanowicz (bartlomiej.urbanowicz@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 23R4

Suite Setup     Run Keywords    Enable NSA HO
    ...         AND    Enable PDCP Status Handling

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
${UE_NR_CAPA}=    21000000010800000004DE4D0780720800000520800001520800002524A000034C00454000000000000054
${UE_EUTRA_NR_CAPA}=    A10180902C100389A0000008800B0400F89A000008000800080402004008
${a3_params}=    event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30

*** Test Cases ***
CNI-86916_B1_NSA_Intra-gNB_PSCell_Change-NSA_HO_with_PDCP_Data_Recovery
    Attach NSA Ue And Start Gnb Addition
    Start 5Mbps Udp Dl And Ul Traffic
    Sleep    ${TRAFFIC_DURATION_MIN}
    Display Bearer Traffic NSA
    Start L1l2bip Mirroring
    Trigger Handover to second cell
    Sleep    ${TRAFFIC_DURATION_MIN}
    Stop L1l2bip Mirroring
    Display Bearer Traffic NSA
    Check First Missing Count From L1L2 bip log
    Detach Ue    ue_id=${UE_DC_ID}

*** Keywords ***
Trigger Handover to second cell
    Execute Egate Command   cmd=ue_measurement_send_nr id=${UE_DC_ID} meas_id=1 ${a3_params}

Start 5Mbps Udp Dl And Ul Traffic
    Start Data Traffic    ues=${UE_DC_ID}    bearer_id=${SCG_BEARER_ID}    direction=dl    throughput=5mbps
    Start Data Traffic    ues=${UE_DC_ID}    bearer_id=${SCG_BEARER_ID}    direction=ul    throughput=5mbps


