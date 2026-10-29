*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    keywords_CNI-86916.robot
Resource    ../resources/common_configuration.robot
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library     ../resources/common_keywords.py
Documentation
...    author: Bartlomiej Urbanowicz
...    maintainer: Bartlomiej Urbanowicz (bartlomiej.urbanowicz@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 23R4

Suite Setup    Run Keywords    Enable PDCP Status Handling
...            AND    Activate Intra Gnb Ho And A3 Meas

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...         AND    Set Internal Traffic Type To UEs

Test Teardown    Send Configuration ID To Scout
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_SEC}=   10s
${srsrp_part}=    srsrp_nr=11 srsrq_nr=11 ssinr_nr=11
${nrsrp_part}=    nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30


*** Test Cases ***
CNI86916_B4_SA_Intra_gNB_Intra_DU_HO-SA_HO_with_PDCP_Data_Recovery
    Register Ue With Default Pdu Session
    Start 5Mbps Udp Dl And Ul Traffic
    Check DL And Ul Traffic
    Start L1l2bip Mirroring
    Trigger Handover To Second Cell
    Stop L1l2bip Mirroring
    Check DL And Ul Traffic
    Check First Missing Count From L1L2 bip log
    Deregister Ue    ue_id=1

*** Keywords ***
Start 5Mbps Udp Dl And Ul Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=5
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=5

Check DL And Ul Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi stats    qfi_id=1

Trigger Handover To Second Cell
    Intercell Handover Trigger By A3





