*** Settings ***
Documentation
...    I. Cell configuration gnb2
...    No      PCI     LCR     chBW       Band     Technology    Mplane Only
...    ------------------------------------------------------------------------------
...    1        50      1        20        n28        FDD           NO
...    2        51      2        25        n3         FDD           NO
...    3        52      3        50        n77        TDD           NO
...    4        53      4        50        n78        TDD           NO
...
...
...    II. Cell configuration gnb3
...    No      PCI     LCR     chBW       Band     Technology    Mplane Only
...    ------------------------------------------------------------------------------
...    5        54      5        15        n28        FDD           NO
...    6        55      6        15        n71        FDD           NO
...    7        56      7        20        n77        TDD           NO
...    8        57      8       100        n78        TDD           NO


Force Tags    CLOUD_5G_I_[MP][MP]_AP_[LOOO]    SBTS00    CONFIGURED    CRT    PY311   NoResUsage    RF50
...           TOOLS_PROFILE_AP_WTS    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC

Resource     ./resources/CB013152_Keywords.robot
Resource     ./resources/CB013152_Variables.robot
Library      ./resources/CB013152_Keywords.py
Library      ./resources/multignb_variables.py
Library      ta5g_pm_counters
Library      ta5g_ue_measurements
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_throughput

Suite Setup    Run Keywords    Run Keyword If    ${RESET_TL}
...                               Trigger Site Reset
...            AND             Run Keyword If    ${RESET_TL}
...                               Trigger Site Reset    remote_host=${REMOTE_HOST_1_IP}
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs    remote_host=${REMOTE_HOST_1_IP}
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_CB013152_partial_activation_ext3.json
...                               remote_host=${REMOTE_HOST_1_IP}
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_CB013152_full_activation_ext2.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_CB013152_VoNR_inter_gNB_HO.lua
...                               remote_hosts=${REMOTE_HOSTS}
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs    remote_host_list=${REMOTE_HOST_1_IP}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
@{REMOTE_HOSTS}          ${EMPTY}

${5QI_5_REGEX}    Added QosFlow with QFI:2 5QI:5
${5QI_1_REGEX}    Added QosFlow with QFI:3 5QI:1

@{pCSI_allocation_expected_list}    2    48
@{SR_allocation_expected_list}      0    51


*** Test Cases ***
[1]CB013152-SR-A_IWK2_Interworking_with_5GC002271_VoNR_UEs_inter_gNB_HO
    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...            remote_host=${REMOTE_HOST_1_IP}

    Change UE Location    ue_id=${UE1_CELL2}    dst_enb=2    dst_cell=2
    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${UE1_CELL2}    prb_check=${True}
    Establish Pdu Session With Traffic
    ...    ue_id=${UE1_CELL2}    pdu_id=1    nwslice=1    gw_id=1    direction=both    throughput=175mbps

    Log To Console    UE SA additional DL traffic 1x100Mbps
    Start Data Traffic    ues=${UE1_CELL2}    pdu=1    direction=dl    traffic_id=2    throughput=100Mbps
    Log To Console    UE SA additional UL traffic 1x100Mbps
    Start Data Traffic    ues=${UE1_CELL2}    pdu=1    direction=ul    traffic_id=2    throughput=100Mbps

    Modify PDU Session    ue_id=${UE1_CELL2}    pdu_id=1    qos_to_add=4    #5QI=5
    ...                   pass_regexp=${5QI_5_REGEX}
    Modify PDU Session    ue_id=${UE1_CELL2}    pdu_id=1    qos_to_add=5    #5QI=1
    ...                   pass_regexp=${5QI_1_REGEX}

    Start VoNR Data Traffic    ue_id=${UE1_CELL2}

    Assert pCI Allocation    ue_id=${UE1_CELL2}    expected_pCSI_values_list=@{pCSI_allocation_expected_list}   nrofPRBs=2
    Assert Scheduling Request Allocation    ue_id=${UE1_CELL2}    expected_sr_values_list=@{SR_allocation_expected_list}

    Send A2 Event For A5 Configuration    ue_id=${UE1_CELL2}    pcell_id=2
    Send A5 Event For Inter-Frequency HO    ue_id=${UE1_CELL2}    neigh_phycellid=54
    ...        nrsrp=122    nrsrq=122    nsinr=122    carrier_freq=156030

    Sleep    3s    reason=ensure A5 event for HO is sent

    Modify PDU Session    ue_id=${UE1_CELL2}    pdu_id=1    qos_to_del=4
    Modify PDU Session    ue_id=${UE1_CELL2}    pdu_id=1    qos_to_del=5

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE1_CELL2}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                               remote_host_list=${REMOTE_HOST_1_IP}