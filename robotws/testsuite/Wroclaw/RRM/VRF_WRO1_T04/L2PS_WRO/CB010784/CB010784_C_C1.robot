*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010784/CB010784_keywords.robot
Library      CB010784_keywords.py

*** Keywords ***
CB010784-C_IWK1_UE_call_to_ring_cell_with_reducedSSBsize_wo_3rdPS_addDelay90
    Verify Egate Content    expected_pattern=(nrofDownlinkSymbols 8)
    Stop AP L1l2bipLogs Collector
    Convert pcap File To pdml C C1
    Check Transmission Of SSB Is On 19PRBs On 2nd OFDM symbol
    Check guardPeriodLength Value For Cell C C1    cell_id=1    expected_value=4Symbols
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start DL and UL Data Traffic C C1    dl_tput=150    ul_tput=150
    Verify Average Tput For UE SA C C1     ue_id=1    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=100    accuracy=99
    Verify Average Tput For UE SA C C1     ue_id=1    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=85    accuracy=99
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE SA C C1
    ...           AND             ADMIN Teardown Admin    alias=admin
