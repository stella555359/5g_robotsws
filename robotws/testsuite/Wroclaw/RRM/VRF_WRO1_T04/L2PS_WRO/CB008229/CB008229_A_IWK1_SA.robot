*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_ORAN    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Resource    ./resources/CB008229_keywords.robot
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Install ORAN RU
...                            iphy_path=${CURDIR}/config
...                            iphy_filename=iphy_A_IWK_1.xml
...            AND             Start Default Logging
...            AND             Find Scfc And Fix And Send Full Commissioning
...                            scfc_filename=scf_A_IWK1.xml
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_iwk1.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIL
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu

*** Test Cases ***
CB008229-A_IWK1_UE1_served_with_large_BWP_and_UE2_served_with_small_BWP_profiles_in_cell_simultaneously_CB007552_active_SA
    Enable PDSCH decoding in the multiplexed slots
    Set Internal Traffic Type To UE    ue=1    pdu=1
    Set Internal Traffic Type To UE    ue=2    pdu=2
    Attach Ue With Large BWP
    Attach Ue With Small BWP
    Start DL and UL Data Traffic For Both UEs
    Verify Average Tput For UE SA     ue_id=1    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=65    accuracy=86
    Verify Average Tput For UE SA     ue_id=1    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=50    accuracy=86
    Verify Average Tput For UE SA     ue_id=2    pdu=2    qfi=1    dir=dl    unit=M    expected_tput=65    accuracy=86
    Verify Average Tput For UE SA     ue_id=2    pdu=2    qfi=1    dir=ul    unit=M    expected_tput=50    accuracy=86
    Verify If PM Counters For Small and Large BWP Updated
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Attach Ue With Large BWP
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1

Attach Ue With Small BWP
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=2

Start DL and UL Data Traffic For Both UEs
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=100
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=70
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=2 pdu=2 dir=dl mbps=100
    ...    pass_regexp=UE2: Started Downlink Internal traffic Receiver on Ue:2 Pdu:2 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=2 pdu=2 dir=ul mbps=70
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:2 UpfId:1 Pdu:2 Qfi:1 TrfId:1
    Sleep    10s    reason=Wait for throughput stabilization

Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
    Execute Egate Command    cmd=trf_data_stop ue=2 pdu=2
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=2 ue_deregister_type=switch_off

Verify If PM Counters For Small and Large BWP Updated
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55139C02501
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55166C00001
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55166C00003
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55139C02502
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55166C00002
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55166C00004
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    filepath=${pm_counter_file}
