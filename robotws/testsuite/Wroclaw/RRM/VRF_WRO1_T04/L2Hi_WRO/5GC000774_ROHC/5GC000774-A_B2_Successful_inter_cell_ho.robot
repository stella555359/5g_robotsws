*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Library     ../resources/common_keywords.py
Library     ta5g_iphy
Library     ta5g_pm_counters
Library     keywords_ROHC.py
Documentation
...    author: Michal Brychcy
...    maintainer: Michal Brychcy (michal.brychcy@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 22R3

Suite Setup     Run Keywords    Prepare Sa Test Environement And Reach Onair
...               perform_tl_reset=${RESET_TL}
...               cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
...               cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
...               cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
...            AND    Enable Vonr And Rohc TDD FDD
...            AND    Activate Intra Gnb Ho And A3 Meas TDD FDD
...            AND    Enable Syslog Debug Prints For Rohc

Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

Test Teardown    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   10s
${srsrp_part}=    srsrp_nr=11 srsrq_nr=11 ssinr_nr=11
${nrsrp_part}=    nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30
${UE_ID_TDD}=    1
${UE_ID_FDD}=    20
${CELL_ID_FDD}=   3
${DST_CELL_FDD}=   4
${DST_PHY_CELL_FDD}=    53

*** Test Cases ***
5GC000774-A-B2_Successful_Intra_frequency_intra_DU_intra_gNB_Voice_Over_Nr_handover_With_Rohc_Profile_0x0001_Ipv4_TDD
    Attach Ue With VoNR
    Start VoNR Call
    Check DL And Ul Traffic
    Trigger Handover To Second Cell
    Check DL And Ul Traffic After Handover
    Verify Rohc Contexts Pm Counters Values
    Deregister Ue    ${UE_ID_TDD}

5GC000774-A-B2_Successful_Intra_frequency_intra_DU_intra_gNB_Voice_Over_Nr_handover_With_Rohc_Profile_0x0001_Ipv4_FDD
    Attach Ue With VoNR    ${UE_ID_FDD}
    Start VoNR Call    ${UE_ID_FDD}
    Check DL And Ul Traffic    ${UE_ID_FDD}    ${CELL_ID_FDD}
    Trigger Handover To Second Cell    ${UE_ID_FDD}    ${DST_CELL_FDD}    ${DST_PHY_CELL_FDD}
    Check DL And Ul Traffic After Handover    ${UE_ID_FDD}    ${DST_CELL_FDD}
    Verify Rohc Contexts Pm Counters Values    ${DST_CELL_FDD}
    Deregister Ue    ${UE_ID_FDD}

*** Keywords ***
Attach Ue With VoNR
    [Arguments]    ${UE_ID}=${1}
    Set Internal Traffic Type To UEs    ${UE_ID}
    Register Ue With Default Pdu Session    ${UE_ID}
    Modify Pdu Session And Wait For Regexp    ue_id=${UE_ID}    pdu_id=1    qos_id=2    qfi_id=2    5qi_id=5
    Modify Pdu Session And Wait For Regexp    ue_id=${UE_ID}    pdu_id=1    qos_id=3    qfi_id=3    5qi_id=1

Start VoNR Call
    [Arguments]    ${UE_ID}=${1}
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=dl rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=1 qfi=3 dir=ul rtp_codec=amr_wb_23_85

Check DL And Ul Traffic
    [Arguments]    ${UE_ID}=${1}    ${CELL_ID}=${1}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=0    enb_id=2    cell_id=${CELL_ID}
    Expected Throughput For Qfi Should Be Reached    ue_id=${UE_ID}    pdu_id=1    qfi_id=3
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=${UE_ID}    pdu_id=1    qfi_id=3    packet_loss=1
    ...    margin=1.0    direction=bi

Trigger Handover To Second Cell
    [Arguments]    ${UE_ID}=${1}    ${DST_CELL}=${2}    ${DST_PHY_CELL}=${51}
    Intercell Handover Trigger By A3    ue_id=${UE_ID}    dst_cell=${DST_CELL}    dst_phy_cell_id=${DST_PHY_CELL}

Check DL And Ul Traffic After Handover
    [Arguments]    ${UE_ID}=${1}    ${CELL_ID}=${2}
    Sleep    ${TRAFFIC_DURATION_SEC}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=0    enb_id=2    cell_id=${CELL_ID}
    Expected Throughput For Qfi Should Be Reached    ue_id=${UE_ID}    pdu_id=1    qfi_id=3
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=${UE_ID}    pdu_id=1    qfi_id=3    packet_loss=1
    ...    margin=1.0    direction=bi

Verify Rohc Contexts Pm Counters Values
    [Arguments]    ${CELL_ID}=${2}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_REQ_SENT}
    ...    value=4    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_RESP_RECD}
    ...    value=4    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_REQ_SENT}
    ...    value=2    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_CMP_RECD}
    ...    value=2    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}    filepath=${PM_COUNTERS}