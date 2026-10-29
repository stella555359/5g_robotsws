*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Resource   ./resources/keywords_7517_B.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Library    ./resources/pcap_verifiers_7517.py
Library    ./resources/delta_kw.py
Library       testsuite/Wroclaw/RRM/resources/etws_cmas/counters.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB007517/resources/neighbour_gnb.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008509/resources/keywords_8509.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB007517/resources/neighbour_gnb.py

*** Variables ***
${GNB_1_CELL_1}    1_1
${GNB_1_CELL_2}    1_2
${GNB_1_CELL_4}    1_4
${GNB_2_CELL}   2_106
${SOURCE_GNB_NRCELL}    1
${TARGET_GNB_NRCELL}    106
${TDD_CELL_4}    4

*** Keywords ***
CB007517-C_08_A4_meas_triggered_Xn_HO_and_NG_HO_counters_PCMD
    Set Preferred Cell    ${SOURCE_GNB_NRCELL}
    Set Entry Attenuation 2 cells
    Enable HO Over Xn    ${SOURCE_GNB_NRCELL}    ${TARGET_GNB_NRCELL}
    counters.Wait For Pm Counters Interval
    ${pcap_file_path}=  Attach UE To Pcell    ${MTK_UE}

    Start DL Traffic For Ue    ue=${MTK_UE}  dl_tput=100Mbits/sec    duration=600s
    Start tracing on SMOD    filename=ho_over_xn    filter master=${EMPTY}

    Clear Attenuation On Cell    ${GNB_2_CELL}
    BuiltIn.Sleep    10
    ${filename_path1}=    Stop Tracing And Download Logs From Smod    filename=ho_over_xn

    Disable HO Over Xn    ${SOURCE_GNB_NRCELL}    ${TARGET_GNB_NRCELL}
    Check Cell And Signal Strength For Ue    ${MTK_UE}
    Start tracing on SMOD    filename=HO    filter master=${EMPTY}
    Gradually Increase Attenuation For Cell    ${GNB_2_CELL}    init_value=10    max_value=60
    BuiltIn.Sleep    10
    ${filename_path}=    Stop Tracing And Download Logs From Smod    filename=HO

    Check Cell And Signal Strength For Ue    ${MTK_UE}

    Start tracing on SMOD    filename=ho_over_ng    filter master=${EMPTY}
    Clear Attenuation On Cell    ${GNB_2_CELL}
    BuiltIn.Sleep    10
    ${filename_path2}=    Stop Tracing And Download Logs From Smod    filename=ho_over_ng
    Check Cell And Signal Strength For Ue    ${MTK_UE}
    Assert A4 Event Is Configured    ${pcap_file_path}
    Run Keyword And Continue On Failure   Ue Handovered After A4 Event PCMD  ${filename_path1}
    ...    from_cell=${SOURCE_GNB_NRCELL}   target_cell=${TARGET_GNB_NRCELL}
    Run Keyword And Continue On Failure   Ue Handovered After A4 Event PCMD   ${filename_path2}
    ...    from_cell=${SOURCE_GNB_NRCELL}   target_cell=${TARGET_GNB_NRCELL}
    Verify Counter Value    M55185C00003    expected_value=1    wait_for_interval=${FALSE}    cell_id=${SOURCE_GNB_NRCELL}
    Verify Counter Value    M55186C00003    expected_value=1    wait_for_interval=${TRUE}    cell_id=${SOURCE_GNB_NRCELL}

    [Teardown]  Run Keywords
    ...  Detach Ue    ${MTK_UE}    AND
    ...  Stop Tracing On Smod    AND
    ...  Set Entry Attenuation 2 cells    AND
    ...  Enable HO Over Xn    ${SOURCE_GNB_NRCELL}    ${TARGET_GNB_NRCELL}

CB007517-C_07_A4_reconfig_after_re-establishment
    Set Preferred Cell    ${SOURCE_GNB_NRCELL},${TDD_CELL_4}
    Prepare Attenuation Cell 1 Preferred
    ${pcap_file_path}=  Attach UE To Pcell    ${MTK_UE}
    Assert A4 Event Is Configured    ${pcap_file_path}
    Start tracing on SMOD    filename=reestablishment
    Start DL Traffic For Ue    ue=${MTK_UE}  dl_tput=100Mbits/sec    duration=220s
    Clear Attenuation On Cell    ${GNB_1_CELL_4}
    Attenuate Cell    ${GNB_1_CELL_1}
    BuiltIn.Sleep    60    Logs collecting
    ${reestablishment}=    Stop Tracing And Download Logs From Smod    filename=reestablishment
    Start tracing on SMOD    filename=handover
    Clear Attenuation On Cell    ${GNB_1_CELL_1}
    ${handover}=    Stop Tracing And Download Logs From Smod    filename=handover
    Assert Reestablishment Occured    ${reestablishment}
    Assert A4 Event Is Configured    ${reestablishment}
    Assert A4 Event Is Configured    ${handover}
    Ue Handovered After A4 Event  ${handover}    target_cell=${SOURCE_GNB_NRCELL}
    [Teardown]  Run Keywords
    ...  Detach Ue    ${MTK_UE}    AND
    ...  Stop Tracing On Smod    AND
    ...  Set Entry Attenuation 2 cells

CB007517-C_30_A4_meas_triggered_Xn_HO_and_NG_HO_barred_cell
    Set Preferred Cell    ${SOURCE_GNB_NRCELL}
    Set Cell To Barred    cell_id=${TARGET_GNB_NRCELL}    mrbts=${NEIGH_GNB_MRBTS_ID}    remote_host=${NEIGH_GNB_VM_IP}
    Enable HO Over Xn    ${SOURCE_GNB_NRCELL}    ${TARGET_GNB_NRCELL}
    Set Entry Attenuation 2 cells

    ${attach_pcap}=  Attach UE To Pcell    ${MTK_UE}

    Start DL Traffic For Ue    ue=${MTK_UE}  dl_tput=100Mbits/sec    duration=600s
    Start tracing on SMOD    filename=ho_over_xn_barred    filter master=${EMPTY}
    Clear Attenuation On Cell    ${GNB_2_CELL}
    BuiltIn.Sleep    10
    ${ho_over_xn_barred}=    Stop Tracing And Download Logs From Smod    filename=ho_over_xn_barred

    Detach Ue    ${MTK_UE}
    Attenuate Cell    ${GNB_2_CELL}

    Disable HO Over Xn    ${SOURCE_GNB_NRCELL}    ${TARGET_GNB_NRCELL}
    ${attach2_pcap}=  Attach UE To Pcell    ${MTK_UE}

    Start tracing on SMOD    filename=ho_over_ng_barred    filter master=${EMPTY}
    Clear Attenuation On Cell    ${GNB_2_CELL}
    BuiltIn.Sleep    10
    ${ho_over_ng_barred}=    Stop Tracing And Download Logs From Smod    filename=ho_over_ng_barred

    Assert A4 Event Is Configured    ${attach_pcap}
    Assert A4 Event Is Configured    ${attach2_pcap}
    Run Keyword And Continue On Failure   Expect Handover Failure    ${ho_over_xn_barred}    interface=xn
    Run Keyword And Continue On Failure   Expect Handover Failure    ${ho_over_ng_barred}    interface=ng

    [Teardown]  Run Keywords
    ...  Detach Ue    ${MTK_UE}    AND
    ...  Stop Tracing On Smod   AND
    ...  Set Cell To notBarred    cell_id=${TARGET_GNB_NRCELL}    mrbts=${NEIGH_GNB_MRBTS_ID}    remote_host=${NEIGH_GNB_VM_IP}    AND
    ...  Set Entry Attenuation 2 cells
