*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Resource   ../CB007517/resources/keywords_7517_B.robot
Library    ../CB007517/resources/pcap_verifiers_7517.py
Library    ../CB007517/resources/delta_kw.py
Library       testsuite/Wroclaw/RRM/resources/etws_cmas/counters.py

*** Keywords ***
CB009205-B_04_Xn_HO_with_A1_meas_configured
    [Documentation]  TC covers 2 tcses from CB009205
    ...   CB009205-B_04_Xn_HO_with_A1_meas_configured
    ...   CB009205-B_05_Ng_HO_with_A1_meas_configured_and_mobilty_profile
    ...   + additional check if A4 will not be triggered when A1 event not occured
    Set Preferred Cell    ${SOURCE_GNB_NRCELL}
    Activate A1 Meas HO Pref NR Layer    rsrp=48    cell_id=${SOURCE_GNB_NRCELL}
    Set Entry Attenuation 2 cells

    Enable HO Over Xn    ${SOURCE_GNB_NRCELL}    ${TARGET_GNB_NRCELL}
    ${attach_pcap}=  Attach UE To Pcell    ${MTK_UE}
    Start tracing on SMOD    filename=ho_over_xn_a1    filter master=${EMPTY}

    Start DL Traffic For Ue    ue=${MTK_UE}  dl_tput=100Mbits/sec    duration=600s

    Clear Attenuation On Cell    ${GNB_2_CELL}
    BuiltIn.Sleep    10
    ${ho_xn_pcap}=    Stop Tracing And Download Logs From Smod    filename=ho_over_xn_a1

    Disable HO Over Xn    ${SOURCE_GNB_NRCELL}    ${TARGET_GNB_NRCELL}
    Check Cell And Signal Strength For Ue    ${MTK_UE}

    Start tracing on SMOD    filename=ho_over_ng_a1    filter master=${EMPTY}
    Gradually Increase Attenuation For Cell    ${GNB_2_CELL}    init_value=10    max_value=60
    BuiltIn.Sleep    20
    Check Cell And Signal Strength For Ue    ${MTK_UE}

    Clear Attenuation On Cell    ${GNB_2_CELL}
    BuiltIn.Sleep    20
    ${ho_ng_pcap}=    Stop Tracing And Download Logs From Smod    filename=ho_over_ng_a1

    Check Cell And Signal Strength For Ue    ${MTK_UE}

    Activate A1 Meas HO Pref NR Layer    rsrp=127    cell_id=${SOURCE_GNB_NRCELL}

    Start tracing on SMOD    filename=ho_failed    filter master=${EMPTY}
    Gradually Increase Attenuation For Cell    ${GNB_2_CELL}    init_value=10    max_value=60
    BuiltIn.Sleep    30

    Clear Attenuation On Cell    ${GNB_2_CELL}
    BuiltIn.Sleep    20
    ${ho_failed}=    Stop Tracing And Download Logs From Smod    filename=ho_failed

    Verify A1 and A4 Measurement    ${attach_pcap}    rsrp_a1=48
    Verify A1 and A4 Measurement    ${ho_ng_pcap}    rsrp_a1=48
    Run Keyword And Expect Error    At least one message is missing! Missing messages: a1,a4    Verify A1 and A4 Measurement    ${ho_failed}
    Run Keyword And Continue On Failure   Ue Handovered After A4 Event PCMD  ${ho_xn_pcap}    from_cell=${SOURCE_GNB_NRCELL}
    ...    target_cell=${TARGET_GNB_NRCELL}
    Run Keyword And Continue On Failure   Ue Handovered    ${ho_xn_pcap}    target_cell=${SOURCE_GNB_NRCELL}
    Run Keyword And Continue On Failure   Ue Handovered After A4 Event PCMD   ${ho_ng_pcap}   from_cell=${SOURCE_GNB_NRCELL}
    ...    target_cell=${TARGET_GNB_NRCELL}
    Run Keyword And Continue On Failure   Ue Handovered    ${ho_ng_pcap}    target_cell=${SOURCE_GNB_NRCELL}
    [Teardown]  Run Keywords
    ...  Detach Ue    ${MTK_UE}    AND
    ...  Stop Tracing On Smod   AND
    ...  Set Entry Attenuation 2 cells    AND
    ...  Deactivate A1 Meas HO Pref NR Layer    cell_id=${SOURCE_GNB_NRCELL}    AND
    ...  Enable HO Over Xn    ${SOURCE_GNB_NRCELL}    ${TARGET_GNB_NRCELL}
