*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    keywords_CNI-86916.robot
Resource    ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Documentation
...    author: Bartlomiej Urbanowicz
...    maintainer: Bartlomiej Urbanowicz (bartlomiej.urbanowicz@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 23R4

Suite Setup     Run Keywords    Enable NSA HO
    ...         AND    Enable PDCP Status Handling
    ...         AND    Enable Proactive Ul Grant

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
${srsrp_part}=    srsrp_nr=11 srsrq_nr=11 ssinr_nr=11
${nrsrp_part}=    nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30
${UE_NR_CAPA}=    21000000010800000004DE4D0780720800000520800001520800002524A000034C00454000000000000054
${UE_EUTRA_NR_CAPA}=    A10180902C100389A0000008800B0400F89A000008000800080402004008


*** Test Cases ***
CNI-86916_B2_NSA_Intra_gNB_Intra_MeNB_HO_with_Security_Key_Refresh-NSA_HO_with_PDCP_Re-establishment
    Attach NSA Ue And Start Gnb Addition
    Start 5Mbps Udp Dl And Ul Traffic
    Sleep    ${TRAFFIC_DURATION_MIN}
    Display Bearer Traffic NSA
    Start L1l2bip Mirroring
    Trigger Intra gNB Intra MeNB HO with Security Key Refresh
    Sleep    ${TRAFFIC_DURATION_MIN}
    Stop L1l2bip Mirroring
    Display Bearer Traffic NSA
    Check First Missing Count From L1L2 bip log
    Detach Ue    ue_id=${UE_DC_ID}

*** Keywords ***
Trigger Intra gNB Intra MeNB HO with Security Key Refresh
    Execute Egate Command And Wait For Data
    ...    cmd=ue_reauth id=${UE_DC_ID}

Start 5Mbps Udp Dl And Ul Traffic
    Start Data Traffic    ues=${UE_DC_ID}    bearer_id=${SCG_BEARER_ID}    direction=dl    throughput=5mbps
    Start Data Traffic    ues=${UE_DC_ID}    bearer_id=${SCG_BEARER_ID}    direction=ul    throughput=5mbps

Enable Proactive Ul Grant
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_proactive_ul_grants.json
