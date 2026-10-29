*** Settings ***
Resource    keywords_CB009324.robot
Resource    ../resources/common_keywords.robot
Resource    ../5GC001354/CB001354_keywords.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R2

Suite Setup     Run Keywords    Enable Burst Size Divider
    ...       AND    Update Gscn In Iphy File    GSCN_1=7832    GSCN_2=7902
    ...       AND    Enable Carrier Aggregation With Blind Scell Activation
    ...       AND    Enable Traffic Shaping TDD
    ...       AND    Adapt RLO Params

Test Setup      Run Keywords    Prepare Nsa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD_2CC}
    ...              cfg_filepath_tdd_fdd=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_2CC}
    ...       AND    Enable X2 Measurments
    ...       AND    Enable F1 Measurments
    ...       AND    Set Drxlongcycle To 320ms
    ...       AND    Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    ...       AND    Enable FSTSCH Counters
    ...       AND    Wait For Next Full Pm Interval

Test Teardown     Run Keywords    Detach Ue    ue_id=11
    ...    AND    Sleep    3s    Waiting for deregister
    ...    AND    Check For An Unexpected Alarm
    ...    AND    Send Configuration ID To Scout
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_SEC}=   30s

*** Test Cases ***
CB009324-A-US3_Single_Nsa_Ue_With_Higher_Throughput_Over_Lte_And_Interworking_With_Pdcp_Fast_Retransmissions_With_Radio_Link_Outage_TDD
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start Dl And Ul Data Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics
    Trigger Radio Link Outage
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics
    Verify If Downlink PDCP Pdu QoS Grp 6 Pm Counters Were Incremented
    Verify Pdcp Pdu Packet Lost On X2-U
    Verify Packet Drops At Transport First Level Scheduler
    Verify If 1354-C Threshld 1 Qos Grp 6 X2 Pm Counters Were Incremented
    Verify If 1354-C Threshld 2 Qos Grp 6 X2 Pm Counters Were Incremented
    Verify If 1354-C Treshold 1 Transmission Delay Bin Pm Counters Were Incremented
    Verify If 1354-C Treshold 2 Transmission Delay Bin Pm Counters Were Incremented
    Verify That Due To High Attenuation Some Dl Pdcp Pdus Exceeded Max Delay Allowed For Retransmissioncn Qos Group 06

*** Keywords ***
Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001354/delta_1354-C_PDCP_Delay_Threshold_based_PDU_retransmission.json

Set Drxlongcycle To 320ms
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_set_drxLongCycle_320ms.json

Start Dl And Ul Data Traffic
    Execute Egate Command    cmd=debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=65
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=ul mbps=10

Display Bearer Stats
    Execute Egate Command And Wait For Data   cmd=ue_stats_nr id=11 type=pdsch scell=8,9
    Execute Egate Command And Wait For Data   cmd=bearer_stats ue=11 id=2 dir=dl

Verify If 1354-C Threshld 1 Qos Grp 6 X2 Pm Counters Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_RETX_THR1_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_RETX_THR1_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-C Threshld 2 Qos Grp 6 X2 Pm Counters Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_RETX_THR2_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_RETX_THR2_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify That Due To High Attenuation Some Dl Pdcp Pdus Exceeded Max Delay Allowed For Retransmissioncn Qos Group 06
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_PDCP_PDU_NOT_RETX_MAX_DLY_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
