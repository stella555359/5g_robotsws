*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB010784_C_keywords.robot
Library     ../resources/Python/webem_alarms.py

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/iphy_CB010784_C1_C2.xml
...                            swconfig_flags_list=@{rdMccWithReducedSSBSize}
...    AND                     Start Default Logging
...    AND                     Find Scfc And Fix And Send Full Commissioning    scfc_filename=scf_CB010784_C1_C2.xml
...    AND                     Download AP MCshark Plugin
...    AND                     Check Radios Availability
...    AND                     Start AP L1l2bipLogs Collector
...    AND                     Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_CB010784_C.cfg

Suite Teardown    Run Keywords    Print Active Alarms
...    AND                        Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{rdMccWithReducedSSBSize}    0x5901FE=1000

*** Test Cases ***
CB010784-C_IWK1_UE_call_to_ring_cell_with_reducedSSBsize_disable_via_RDparam_wo_3rdPS_addDelay90
    Verify Egate Content    expected_pattern=(nrofDownlinkSymbols 8)
    Stop AP L1l2bipLogs Collector
    Convert pcap File To pdml
    Check Transmission Of SSB Is On 20PRBs On 2nd OFDM symbol
    Check guardPeriodLength Value For Cell    cell_id=1    expected_value=4Symbols
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start DL and UL Data Traffic    dl_tput=150    ul_tput=150
    Verify Average Tput For UE SA     ue_id=1    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=100    accuracy=99
    Verify Average Tput For UE SA     ue_id=1    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=85    accuracy=99
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE SA
