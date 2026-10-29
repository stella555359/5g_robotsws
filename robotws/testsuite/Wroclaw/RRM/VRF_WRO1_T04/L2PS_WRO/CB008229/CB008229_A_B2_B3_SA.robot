*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_ORAN    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB008229_keywords.robot
Library     ../resources/Python/webem_alarms.py
Library     resources/CB008229_keywords.py
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Install ORAN RU
...                            iphy_path=${CURDIR}/config
...                            iphy_filename=iphy_A_B2_B3_ORAN.xml
...    AND                     Start Default Logging
...    AND                     Find Scfc And Fix And Send Full Commissioning    scfc_filename=scf_A_B2_B3_ORAN.xml
...    AND                     Check Radios Availability
...    AND                     Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_A_B2_B3_ORAN.cfg

Suite Teardown    Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB008229-A_B2_B3_Multi_UE_attach_and_traffic_SA_256QAM
    Enable PDSCH decoding in the multiplexed slots
    Set Internal Traffic Type To UE
    Set Internal Traffic Type To UE    ue=2    pdu=2
    Attach Ue    ue_id=1
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=2
    Start DL and UL Data Traffic    dl_tput=150    ul_tput=150
    Start DL and UL Data Traffic    dl_tput=150    ul_tput=150    ue=2    pdu=2
    Sleep    5s
    Verify Max Tput For UE SA    ue_id=1    dir=dl    expected_tput=144
    Verify Max Tput For UE SA    ue_id=2    dir=dl    expected_tput=144    accuracy=85
    Verify Max Tput For UE SA    ue_id=1    dir=ul    expected_tput=140
    Verify Max Tput For UE SA    ue_id=2    dir=ul    expected_tput=140
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE SA
    ...    AND    Send Configuration ID To Scout
